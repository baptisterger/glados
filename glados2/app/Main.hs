module Main (main) where

import System.Environment (getArgs)
import System.Exit (exitFailure, exitSuccess)
import Lib (parseFile, parseStringToAST, hasMain)
import Compiler (compileProgram, compileProgramToWasm)
import WasmBinary (generateWasmFile)

replaceExtension :: FilePath -> String -> FilePath
replaceExtension path newExt = 
  let (base, _) = break (== '.') (reverse path)
  in reverse base ++ newExt

main :: IO ()
main = do
  args <- getArgs
  case args of
    [filename] -> do
      content <- readFile filename
      case parseStringToAST content of
        Left err -> do
          putStrLn $ "Parse error: " ++ show err
          exitFailure
        Right ast -> do
          putStrLn $ "Parsed successfully: " ++ filename
          if hasMain ast
            then do
              putStrLn "Found main function"
              let wasmModule = compileProgramToWasm ast
              let wasmFile = replaceExtension filename ".wasm"
              
              generateWasmFile wasmModule wasmFile
              exitSuccess
            else do
              putStrLn "No main function found"
              exitFailure
    [] -> do
      putStrLn "Reading from stdin..."
      content <- getContents
      case parseStringToAST content of
        Left err -> do
          putStrLn ("Parse error: " ++ show err)
          exitFailure
        Right ast -> do
          print ast
          if hasMain ast
            then do
              let wasmCode = compileProgram ast
              exitSuccess
            else do
              putStrLn "No main function found"
              exitFailure
    _ -> do
      putStrLn "Usage: glados2 [filename]  (or run with no args to read from stdin)"
      exitFailure