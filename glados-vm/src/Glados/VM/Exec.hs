module Glados.VM.Exec
  ( runExported
  , runFunction
  ) where

import Glados.VM.Types
import Glados.VM.Runtime
import Control.Monad.Except
import qualified Data.Vector as V
import Data.Int

type VM a = ExceptT String IO a

data Frame = Frame { locals :: V.Vector Value } deriving (Show)
type Stack = [Value]

data Ctx = Ctx
  { store  :: Store
  , frames :: [Frame]
  , stack  :: Stack
  } deriving (Show)

push :: Value -> Ctx -> Ctx
push v c = c { stack = v : stack c }

popV :: Ctx -> VM (Value, Ctx)
popV c = case stack c of
  v:vs -> pure (v, c { stack = vs })
  []   -> throwError "stack underflow"

popI32 :: Ctx -> VM (Int32, Ctx)
popI32 c = do
  (v, c') <- popV c
  case v of
    I32 x -> pure (x, c')
    _     -> throwError ("type error: expected i32, got " <> show v)

popF32 :: Ctx -> VM (Float, Ctx)
popF32 c = do
  (v, c') <- popV c
  case v of
    F32 x -> pure (x, c')
    _     -> throwError ("type error: expected f32, got " <> show v)

getLocal :: Integral i => i -> Ctx -> VM Value
getLocal ix c = case frames c of
  fr:_ -> maybe (throwError "bad local idx") pure (locals fr V.!? fromIntegral ix)
  []   -> throwError "no frame"

setLocal :: Integral i => i -> Value -> Ctx -> VM Ctx
setLocal ix v c = case frames c of
  fr:rest ->
    let ls = locals fr
    in case ls V.!? fromIntegral ix of
        Nothing -> throwError "bad local idx"
        Just _  ->
          let fr' = fr { locals = ls V.// [(fromIntegral ix, v)] }
          in pure c { frames = fr':rest }
  [] -> throwError "no frame"

runExported :: Store -> String -> [Value] -> VM (Maybe Value, Store)
runExported st nm args = do
  fidx <- maybe (throwError $ "export not found: " <> nm) pure (getExportedFunc st nm)
  runFunction st fidx args

runFunction :: Store -> FuncIdx -> [Value] -> VM (Maybe Value, Store)
runFunction st (FuncIdx i) args = do
  let m = sModule st
      total = funcCount m
  if i < 0 || i >= total
    then throwError "bad function index"
    else do
      let fn = funcs m V.! i
          FuncType ps rs = fType fn
      if length ps /= length args then throwError "arity mismatch" else pure ()
      let paramLocals = V.fromList args
          extraLocals = V.fromList (map zeroOf (fLocals fn))
          frame = Frame { locals = paramLocals V.++ extraLocals }
          ctx0 = Ctx { store = st, frames = [frame], stack = [] }
      (retVal, ctxF) <- execInstrs (fBody fn) ctx0
      case rs of
        []   -> pure (Nothing, store ctxF)
        [_]  -> case retVal of
                  Just v  -> pure (Just v, store ctxF)
                  Nothing -> case stack ctxF of
                               v':_ -> pure (Just v', store ctxF)
                               []   -> throwError "missing return value"
        _    -> throwError "multi-value returns not supported"

zeroOf :: ValueType -> Value
zeroOf T_i32 = I32 0
zeroOf T_f32 = F32 0

execInstrs :: [Instr] -> Ctx -> VM (Maybe Value, Ctx)
execInstrs [] c = pure (Nothing, c)
execInstrs (instr:is) c0 = case instr of
  End     -> pure (Nothing, c0)
  Return  -> do
    let ret = case stack c0 of
                v:_ -> Just v
                []  -> Nothing
    pure (ret, c0)

  I32Const n -> execInstrs is (push (I32 n) c0)
  F32Const x -> execInstrs is (push (F32 x) c0)

  LocalGet ix -> do
    v <- getLocal ix c0
    execInstrs is (push v c0)

  LocalSet ix -> do
    (v, c1) <- popV c0
    c2 <- setLocal ix v c1
    execInstrs is c2

  I32Add -> do
    (b, c1) <- popI32 c0
    (a, c2) <- popI32 c1
    execInstrs is (push (I32 (a + b)) c2)

  I32Mul -> do
    (b, c1) <- popI32 c0
    (a, c2) <- popI32 c1
    execInstrs is (push (I32 (a * b)) c2)

  I32Eq -> do
    (b, c1) <- popI32 c0
    (a, c2) <- popI32 c1
    execInstrs is (push (I32 (if a == b then 1 else 0)) c2)

  F32Add -> do
    (b, c1) <- popF32 c0
    (a, c2) <- popF32 c1
    execInstrs is (push (F32 (a + b)) c2)

  F32Mul -> do
    (b, c1) <- popF32 c0
    (a, c2) <- popF32 c1
    execInstrs is (push (F32 (a * b)) c2)

  F32ConvertI32S -> do
    (n, c1) <- popI32 c0
    execInstrs is (push (F32 (fromIntegral n)) c1)

  Drop -> do
    (_v, c1) <- popV c0
    execInstrs is c1

  If t e -> do
    (cond, c1) <- popI32 c0
    let chosen = if cond /= 0 then t else e
    (retB, c2) <- execInstrs chosen c1
    case retB of
      Just v  -> pure (Just v, c2)
      Nothing -> execInstrs is c2

  Call idxW -> do
    let idx = fromIntegral idxW :: Int
        m   = sModule (store c0)
        callee = funcs m V.! idx
        nParams = length (params (fType callee))
    (argsRev, cAfter) <- popN nParams c0
    (ret, st') <- runFunction (store cAfter) (FuncIdx idx) (reverse argsRev)
    let c' = cAfter { store = st' }
    case ret of
      Just v  -> execInstrs is (push v c')
      Nothing -> execInstrs is c'

popN :: Int -> Ctx -> VM ([Value], Ctx)
popN 0 c = pure ([], c)
popN n c = do
  (v, c1) <- popV c
  (vs, c2) <- popN (n-1) c1
  pure (v:vs, c2)