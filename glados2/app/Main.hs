module Main (main) where

import System.Environment (getArgs)
import System.Exit (exitFailure, exitSuccess)
import System.FilePath (takeExtension)
import Lib (parseFile, parseStringToAST, hasMain)
import Compiler (compileProgram)

replaceExtension :: FilePath -> String -> FilePath
replaceExtension path newExt = 
  let (base, _) = break (== '.') (reverse path)
  in reverse base ++ newExt

hasExtension :: FilePath -> String -> Bool
hasExtension filepath ext = 
  takeExtension filepath == ext

main :: IO ()
main = do
  args <- getArgs
  case args of
    [filename] -> do
      if hasExtension filename ".cedric"
        then do
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
                  let wasmCode = compileProgram ast
                  let outputFile = replaceExtension filename ".wat"
                  writeFile outputFile wasmCode
                  putStrLn $ "WebAssembly generated: " ++ outputFile
                  exitSuccess
                else do
                  putStrLn "No main function found"
                  exitFailure
        else do
          putStrLn $ "Error: File must have the extension '.cedric', but got: " ++ filename
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
              putStrLn "=== Generated WebAssembly ==="
              putStrLn wasmCode
              exitSuccess
            else do
              putStrLn "No main function found"
              exitFailure
              
    _ -> do
      putStrLn "Usage: glados2 [filename.cedric]  (or run with no args to read from stdin)"
      exitFailure