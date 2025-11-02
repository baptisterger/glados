{-
-- EPITECH PROJECT, 2025
-- glados-vm [WSL: Ubuntu]
-- File description:
-- WasmDecodeSubset
-}

module Glados.VM.WasmDecodeSubset
  ( decodeModuleFromFile
  ) where

import Glados.VM.Types
import qualified Data.Vector as V
import qualified Data.Map.Strict as M
import qualified Data.ByteString as BS
import qualified Data.ByteString.Char8 as BC
import Data.Bits
import Data.Int
import Data.Word
import GHC.Float (castWord32ToFloat)



data P = P { buf :: BS.ByteString, off :: Int }

eof :: P -> Bool
eof (P b i) = i >= BS.length b

slice :: Int -> P -> Either String (P, P)
slice n (P b i)
  | i + n <= BS.length b = Right (P (BS.take n (BS.drop i b)) 0, P b (i+n))
  | otherwise            = Left "unexpected EOF (slice)"

getU8 :: P -> Either String (Word8, P)
getU8 (P b i)
  | i < BS.length b = Right (BS.index b i, P b (i+1))
  | otherwise       = Left "unexpected EOF (u8)"

getBytes :: Int -> P -> Either String (BS.ByteString, P)
getBytes n (P b i)
  | i + n <= BS.length b = Right (BS.take n (BS.drop i b), P b (i+n))
  | otherwise            = Left "unexpected EOF (bytes)"

getULEB32 :: P -> Either String (Word32, P)
getULEB32 p0 = go 0 0 p0
  where
    go :: Int -> Word32 -> P -> Either String (Word32, P)
    go sh acc p = do
      (b, p') <- getU8 p
      let val = acc .|. (fromIntegral (b .&. 0x7F) `shiftL` sh)
      if (b .&. 0x80) /= 0
        then go (sh + 7) val p'
        else Right (val, p')

getSLEB32 :: P -> Either String (Int32, P)
getSLEB32 p0 = go 0 0 p0
  where
    go :: Int -> Int32 -> P -> Either String (Int32, P)
    go sh acc p = do
      (b, p') <- getU8 p
      let acc' = acc .|. (fromIntegral (b .&. 0x7F) `shiftL` sh)
      if (b .&. 0x80) /= 0
        then go (sh + 7) acc' p'
        else do
          let size = 32
              signBitSet = (b .&. 0x40) /= 0
              acc'' = if signBitSet && sh < size
                        then acc' .|. (complement 0 `shiftL` sh)
                        else acc'
          pure (acc'', p')

getName :: P -> Either String (String, P)
getName p0 = do
  (len, p1) <- getULEB32 p0
  let n = fromIntegral len
  (bs, p2) <- getBytes n p1
  pure (BC.unpack bs, p2)

getMagic :: P -> Either String ((), P)
getMagic p0 = do
  (b0, p1) <- getU8 p0
  (b1, p2) <- getU8 p1
  (b2, p3) <- getU8 p2
  (b3, p4) <- getU8 p3
  if (b0,b1,b2,b3) == (0x00,0x61,0x73,0x6d) then Right ((), p4) else Left "bad magic"

getVersion :: P -> Either String P
getVersion p0 = do
  (b0, p1) <- getU8 p0
  (b1, p2) <- getU8 p1
  (b2, p3) <- getU8 p2
  (b3, p4) <- getU8 p3
  if (b0,b1,b2,b3) == (0x01,0x00,0x00,0x00) then Right p4 else Left "bad version"

data Sections = Sections
  { sTypes        :: [FuncType]
  , sFuncTypeIdxs :: [Int]
  , sExports      :: [(String, Int)]
  , sCodes        :: [CodeBody]
  }

emptySections :: Sections
emptySections = Sections [] [] [] []

data CodeBody = CodeBody
  { cLocals :: [ValueType]
  , cInstrs :: [Instr]
  } deriving (Show, Eq)

decodeModuleFromFile :: FilePath -> IO Module
decodeModuleFromFile path = do
  bs <- BS.readFile path
  case runDecode bs of
    Left err -> ioError (userError ("WASM decode error: " <> err))
    Right m  -> pure m

runDecode :: BS.ByteString -> Either String Module
runDecode bs = do
  let p0 = P bs 0
  (_, p1) <- getMagic p0
  p <- getVersion p1
  (sects, _) <- parseSections p emptySections
  let typesV = V.fromList (sTypes sects)
      funcTypeIdxs = sFuncTypeIdxs sects
      codes = sCodes sects
  if length funcTypeIdxs /= length codes
    then Left "function and code section count mismatch"
    else pure ()
  let funcsV = V.fromList $ zipWith (\tidx code ->
                    let fty = typesV V.! tidx
                    in Function { fType = fty, fLocals = cLocals code, fBody = cInstrs code }
                ) funcTypeIdxs codes
      exportsM = M.fromList $ map (\(nm, i) -> (nm, ExportFunc nm (FuncIdx i))) (sExports sects)
  pure Module
    { types   = typesV
    , funcs   = funcsV
    , exports = exportsM
    }

parseSections :: P -> Sections -> Either String (Sections, P)
parseSections p0 acc
  | eof p0 = Right (acc, p0)
  | otherwise = do
      (sid, p1) <- getU8 p0
      (sz, p2)  <- getULEB32 p1
      let n = fromIntegral sz
      (sp, pNext) <- slice n p2
      case sid of
        0 -> parseSections pNext acc
        1 -> do (tys, _) <- parseTypeSection sp
                parseSections pNext acc { sTypes = tys }
        3 -> do (fs, _) <- parseFunctionSection sp
                parseSections pNext acc { sFuncTypeIdxs = fs }
        7 -> do (exps, _) <- parseExportSection sp
                parseSections pNext acc { sExports = exps }
        10 -> do (codes, _) <- parseCodeSection sp
                 parseSections pNext acc { sCodes = codes }
        _ -> Left ("unsupported section id: " <> show sid)

parseTypeSection :: P -> Either String ([FuncType], P)
parseTypeSection p0 = do
  (n, p1) <- getULEB32 p0
  go (fromIntegral n) p1 []
  where
    go :: Int -> P -> [FuncType] -> Either String ([FuncType], P)
    go 0 p acc = Right (reverse acc, p)
    go k p acc = do
      (tag, p1) <- getU8 p
      if tag /= 0x60 then Left "expected functype 0x60" else pure ()
      (ps, p2) <- parseValTypeVec p1
      (rs, p3) <- parseValTypeVec p2
      go (k-1) p3 (FuncType ps rs : acc)

parseValType :: P -> Either String (ValueType, P)
parseValType p = do
  (b, p1) <- getU8 p
  case b of
    0x7F -> Right (T_i32, p1)
    0x7D -> Right (T_f32, p1)
    _    -> Left ("unsupported valtype: " <> show b)

parseValTypeVec :: P -> Either String ([ValueType], P)
parseValTypeVec p0 = do
  (n, p1) <- getULEB32 p0
  go (fromIntegral n) p1 []
  where
    go :: Int -> P -> [ValueType] -> Either String ([ValueType], P)
    go 0 p acc = Right (reverse acc, p)
    go k p acc = do
      (t, p1) <- parseValType p
      go (k-1) p1 (t:acc)

parseFunctionSection :: P -> Either String ([Int], P)
parseFunctionSection p0 = do
  (n, p1) <- getULEB32 p0
  go (fromIntegral n) p1 []
  where
    go :: Int -> P -> [Int] -> Either String ([Int], P)
    go 0 p acc = Right (reverse acc, p)
    go k p acc = do
      (tidx, p1) <- getULEB32 p
      go (k-1) p1 (fromIntegral tidx : acc)

parseExportSection :: P -> Either String ([(String, Int)], P)
parseExportSection p0 = do
  (n, p1) <- getULEB32 p0
  go (fromIntegral n) p1 []
  where
    go :: Int -> P -> [(String, Int)] -> Either String ([(String, Int)], P)
    go 0 p acc = Right (reverse acc, p)
    go k p acc = do
      (nm, p1) <- getName p
      (dtag, p2) <- getU8 p1
      case dtag of
        0x00 -> do
          (idx, p3) <- getULEB32 p2
          go (k-1) p3 ((nm, fromIntegral idx):acc)
        _ -> Left "unsupported export desc (only func)"

parseCodeSection :: P -> Either String ([CodeBody], P)
parseCodeSection p0 = do
  (n, p1) <- getULEB32 p0
  go (fromIntegral n) p1 []
  where
    go :: Int -> P -> [CodeBody] -> Either String ([CodeBody], P)
    go 0 p acc = Right (reverse acc, p)
    go k p acc = do
      (bodySize, p1) <- getULEB32 p
      let n = fromIntegral bodySize
      (bp, pRest) <- slice n p1
      (locals, p2) <- parseLocals bp
      (instrs, _p3) <- parseInstrsUntilEnd p2
      go (k-1) pRest (CodeBody locals instrs : acc)

parseLocals :: P -> Either String ([ValueType], P)
parseLocals p0 = do
  (n, p1) <- getULEB32 p0
  go (fromIntegral n) p1 []
  where
    go :: Int -> P -> [[ValueType]] -> Either String ([ValueType], P)
    go 0 p acc = Right (concat (reverse acc), p)
    go k p acc = do
      (cnt, p1) <- getULEB32 p
      (vt, p2)  <- parseValType p1
      let vts = replicate (fromIntegral cnt) vt
      go (k-1) p2 (vts:acc)


parseInstrsUntilEnd :: P -> Either String ([Instr], P)
parseInstrsUntilEnd = go []
  where
    go acc p0 = do
      (opc, p1) <- getU8 p0
      case opc of
        0x0B -> Right (reverse acc, p1)
        0x0F -> go (Return : acc) p1
        0x41 -> do (imm, p2) <- getSLEB32 p1
                   go (I32Const imm : acc) p2
        0x43 -> do (bs, p2) <- getBytes 4 p1
                   let w :: Word32
                       w =  fromIntegral (BS.index bs 0)
                        .|. (fromIntegral (BS.index bs 1) `shiftL` 8)
                        .|. (fromIntegral (BS.index bs 2) `shiftL` 16)
                        .|. (fromIntegral (BS.index bs 3) `shiftL` 24)
                       x = castWord32ToFloat w
                   go (F32Const x : acc) p2
        0x20 -> do (i, p2) <- getULEB32 p1
                   go (LocalGet (fromIntegral i) : acc) p2
        0x21 -> do (i, p2) <- getULEB32 p1
                   go (LocalSet (fromIntegral i) : acc) p2
        0x6A -> go (I32Add : acc) p1
        0x6C -> go (I32Mul : acc) p1
        0x46 -> go (I32Eq : acc) p1
        0x1A -> go (Drop : acc) p1
        0x10 -> do (i, p2) <- getULEB32 p1
                   go (Call (fromIntegral i) : acc) p2
        0x04 -> do
          
          (_bt, p2) <- getU8 p1
          (thenInstrs, hasElse, p3) <- parseThenUntilElseOrEnd p2
          if hasElse
            then do
              (elseInstrs, p4) <- parseInstrsUntilEnd p3
              go (If thenInstrs elseInstrs : acc) p4
            else
              go (If thenInstrs [] : acc) p3
        0x05 -> Left "unexpected else outside of if"
        _    -> Left ("unsupported opcode: 0x" <> showHex2 opc)

parseThenUntilElseOrEnd :: P -> Either String ([Instr], Bool, P)
parseThenUntilElseOrEnd = go []
  where
    go acc p0 = do
      (opc, p1) <- getU8 p0
      case opc of
        0x05 -> Right (reverse acc, True, p1)
        0x0B -> Right (reverse acc, False, p1)
        0x0F -> go (Return : acc) p1
        0x41 -> do (imm, p2) <- getSLEB32 p1
                   go (I32Const imm : acc) p2
        0x43 -> do (bs, p2) <- getBytes 4 p1
                   let w :: Word32
                       w =  fromIntegral (BS.index bs 0)
                        .|. (fromIntegral (BS.index bs 1) `shiftL` 8)
                        .|. (fromIntegral (BS.index bs 2) `shiftL` 16)
                        .|. (fromIntegral (BS.index bs 3) `shiftL` 24)
                       x = castWord32ToFloat w
                   go (F32Const x : acc) p2
        0x20 -> do (i, p2) <- getULEB32 p1
                   go (LocalGet (fromIntegral i) : acc) p2
        0x21 -> do (i, p2) <- getULEB32 p1
                   go (LocalSet (fromIntegral i) : acc) p2
        0x6A -> go (I32Add : acc) p1
        0x6C -> go (I32Mul : acc) p1
        0x46 -> go (I32Eq : acc) p1
        0x1A -> go (Drop : acc) p1
        0x10 -> do (i, p2) <- getULEB32 p1
                   go (Call (fromIntegral i) : acc) p2
        0x04 -> do (_bt, p2) <- getU8 p1
                   (t2, hasElse2, p3) <- parseThenUntilElseOrEnd p2
                   if hasElse2
                     then do
                       (e2, p4) <- parseInstrsUntilEnd p3
                       go (If t2 e2 : acc) p4
                     else
                       go (If t2 [] : acc) p3
        _    -> Left ("unsupported opcode in then-branch: 0x" <> showHex2 opc)

showHex2 :: Word8 -> String
showHex2 b =
  let h = "0123456789abcdef"
      hi = fromIntegral ((b `shiftR` 4) .&. 0xF) :: Int
      lo = fromIntegral (b .&. 0xF) :: Int
  in [h !! hi, h !! lo]