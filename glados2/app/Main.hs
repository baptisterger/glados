module Main (main) where

import System.Environment (getArgs)
import System.Exit (exitFailure, exitSuccess)
import Lib (parseFile, parseStringToAST, hasMain)

main :: IO ()
main = do
  args <- getArgs
  case args of
    [filename] -> parseFile filename
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
            then putStrLn "Found main" >> exitSuccess
            else putStrLn "No main function found" >> exitFailure
    _ -> do
      putStrLn "Usage: glados2 [filename]  (or run with no args to read from stdin)"
      exitFailure
