module WasmBinary where

import Data.Word
import Data.Bits
import qualified Data.ByteString as BS
import qualified Data.ByteString.Lazy as BL
import Data.Binary.Put
import Wasm

wasmMagic, wasmVersion :: [Word8]
wasmMagic = [0x00, 0x61, 0x73, 0x6D]
wasmVersion = [0x01, 0x00, 0x00, 0x00]

encodeULEB128 :: Int -> [Word8]
encodeULEB128 n
  | n < 128 = [fromIntegral n]
  | otherwise = fromIntegral (n .&. 0x7F .|. 0x80) : encodeULEB128 (n `shiftR` 7)

encodeSLEB128 :: Int -> [Word8]
encodeSLEB128 n
  | n >= -64 && n < 64 = [fromIntegral (n .&. 0x7F)]
  | otherwise = fromIntegral (n .&. 0x7F .|. 0x80) : encodeSLEB128 (n `shiftR` 7)

encodeString :: String -> [Word8]
encodeString s = encodeULEB128 (length s) ++ map (fromIntegral . fromEnum) s

encodeType :: WasmType -> Word8
encodeType I32 = 0x7F
encodeType F32 = 0x7D

encodeInstr :: WasmInstr -> [Word8]
encodeInstr (I32Const n) = 0x41 : encodeSLEB128 n
encodeInstr (F32Const f) = 0x43 : BL.unpack (runPut (putFloatle f))
encodeInstr (LocalGet i) = 0x20 : encodeULEB128 i
encodeInstr (LocalSet i) = 0x21 : encodeULEB128 i
encodeInstr I32Add = [0x6A]
encodeInstr I32Sub = [0x6B]
encodeInstr I32Mul = [0x6C]
encodeInstr I32Div = [0x6D]
encodeInstr I32Eq = [0x46]
encodeInstr I32Lt = [0x48]
encodeInstr I32Gt = [0x4A]
encodeInstr I32Le = [0x4C]
encodeInstr I32Ge = [0x4E]
encodeInstr (Call _) = [0x10, 0x00]
encodeInstr Return = [0x0F]
encodeInstr Drop = [0x1A]
encodeInstr (If thenInstrs elseInstrs) = 
  [0x04, 0x40] ++ concatMap encodeInstr thenInstrs ++ 
  maybe [] ((0x05 :) . concatMap encodeInstr) elseInstrs ++ [0x0B]
encodeInstr _ = []

encodeFuncType :: [WasmType] -> Maybe WasmType -> [Word8]
encodeFuncType params result =
  0x60 : encodeULEB128 (length params) ++ map encodeType params ++ 
  maybe [0x00] (\t -> [0x01, encodeType t]) result

encodeSection :: Word8 -> [Word8] -> [Word8]
encodeSection sid content = sid : encodeULEB128 (length content) ++ content

encodeWasmModule :: WasmModule -> BS.ByteString
encodeWasmModule mod = BS.pack $ wasmMagic ++ wasmVersion ++ concat [typeSection, funcSection, exportSection, codeSection]
  where
    funcs = wasmFunctions mod
    typeSection = encodeSection 0x01 $ encodeULEB128 (length funcs) ++ concatMap (uncurry encodeFuncType . (\f -> (funcParams f, funcResult f))) funcs
    funcSection = encodeSection 0x03 $ encodeULEB128 (length funcs) ++ replicate (length funcs) 0x00
    exportSection = encodeSection 0x07 $ encodeULEB128 1 ++ encodeString "main" ++ [0x00, 0x00]
    codeSection = encodeSection 0x0A $ encodeULEB128 (length funcs) ++ concatMap encodeFuncBody funcs

encodeFuncBody :: WasmFunc -> [Word8]
encodeFuncBody func = let body = encodeLocals (funcLocals func) ++ concatMap encodeInstr (funcBody func) ++ [0x0B]
                      in encodeULEB128 (length body) ++ body

encodeLocals :: [WasmType] -> [Word8]
encodeLocals locals = let groups = groupConsecutive locals
                      in encodeULEB128 (length groups) ++ concatMap encodeGroup groups
  where
    encodeGroup (count, ty) = encodeULEB128 count ++ [encodeType ty]

groupConsecutive :: Eq a => [a] -> [(Int, a)]
groupConsecutive [] = []
groupConsecutive (x:xs) = let (same, rest) = span (== x) xs 
                          in (1 + length same, x) : groupConsecutive rest

generateWasmFile :: WasmModule -> FilePath -> IO ()
generateWasmFile wasmMod filepath = 
  BS.writeFile filepath (encodeWasmModule wasmMod) >> 
  putStrLn ("WASM binary generated: " ++ filepath)
