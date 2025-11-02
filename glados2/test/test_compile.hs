module Main where

import Lib (parseStringToAST)
import Compiler (compileProgramToWasm)
import Wasm (WasmInstr(..), WasmModule(..), WasmFunc(..), WasmType(..))
import System.Environment (getArgs)
import Data.List (intercalate)

main :: IO ()
main = do
  args <- getArgs
  case args of
    (f:_) -> do
      content <- readFile f
      case parseStringToAST content of
        Left err -> putStrLn $ "Parse error: " ++ show err
        Right ast -> do
          let wasm = compileProgramToWasm ast
              funcs = wasmFunctions wasm
          putStrLn $ "Compiled funcs: " ++ show (map funcName funcs)
          mapM_ (printFuncInstrs) funcs
    _ -> putStrLn "Usage: runhaskell test_compile.hs <file>"

printFuncInstrs :: WasmFunc -> IO ()
printFuncInstrs f = do
  putStrLn $ "Function: " ++ funcName f
  putStrLn $ "Instrs: " ++ intercalate ", " (map show (funcBody f))
