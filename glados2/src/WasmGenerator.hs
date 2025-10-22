module WasmGenerator where

import Wasm

instrToWat :: WasmInstr -> String
instrToWat instr = case instr of
  I32Const n -> "i32.const " ++ show n
  F32Const f -> "f32.const " ++ show f
  LocalGet i -> "local.get " ++ show i
  LocalSet i -> "local.set " ++ show i
  I32Add -> "i32.add"
  I32Mul -> "i32.mul"
  I32Eq -> "i32.eq"
  Call fname -> "call " ++ fname
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
  [ "  (import \"env\" \"print\" (func $print (param i32)))" ] ++
  map funcToWat (wasmFunctions mod) ++
  [ "  (export \"main\" (func $main))" ] ++
  [ ")" ]