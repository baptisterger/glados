module WasmGenerator where

import Wasm

instrToWat :: WasmInstr -> String
instrToWat instr = case instr of
  I32Const n -> "i32.const " ++ show n
  F32Const f -> "f32.const " ++ show f
  LocalGet i -> "local.get " ++ show i
  LocalSet i -> "local.set " ++ show i
  I32Add -> "i32.add"
  I32Sub -> "i32.sub"
  I32Div -> "i32.div_s"
  I32Mul -> "i32.mul"
  F32Le -> "f32.le"
  F32Gt -> "f32.gt"
  F32Ge -> "f32.ge"
  F32Add -> "f32.add"
  I32Le -> "i32.le_s"
  I32Gt -> "i32.gt_s"
  I32Ge -> "i32.ge_s"
  F32Mul -> "f32.mul"
  F32Sub -> "f32.sub"
  F32Div -> "f32.div"
  F32Eq -> "f32.eq"
  F32Lt -> "f32.lt"
  F32Gt -> "f32.gt"
  I32Lt -> "i32.lt_s"
  I32Gt -> "i32.gt_s"
  I32Eq -> "i32.eq"
  Call fname -> "call " ++ fname
  Return -> "return"
  Drop -> "drop"
  If thenInstrs Nothing -> 
    "if\n" ++ unlines (map ("  " ++) (map instrToWat thenInstrs)) ++ "end"
  If thenInstrs (Just elseInstrs) ->
    "if\n" ++ 
    unlines (map ("  " ++) (map instrToWat thenInstrs)) ++
    "else\n" ++
    unlines (map ("  " ++) (map instrToWat elseInstrs)) ++
    "end"

funcToWat :: WasmFunc -> String
funcToWat func = unlines $
  [ "(func $" ++ funcName func ] ++
  map (\t -> "  (param " ++ wasmTypeToWat t ++ ")") (funcParams func) ++
  maybe [] (\t -> ["  (result " ++ wasmTypeToWat t ++ ")"]) (funcResult func) ++
  map (\t -> "  (local " ++ wasmTypeToWat t ++ ")") (funcLocals func) ++
  map ("  " ++) (map instrToWat (funcBody func)) ++
  [ ")" ]

wasmTypeToWat :: WasmType -> String
wasmTypeToWat I32 = "i32"
wasmTypeToWat F32 = "f32"

moduleToWat :: WasmModule -> String
moduleToWat mod = unlines $
  [ "(module" ] ++
  map funcToWat (wasmFunctions mod) ++
  [ "  (export \"main\" (func $main))" ] ++
  [ ")" ]