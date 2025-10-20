module Main (main) where

import Lib
import Text.Parsec
import Text.Parsec.String (Parser)
import System.Environment

main :: IO ()
main = do
  args <- getArgs
  case args of
    [filename] -> parseFile filename
    [] -> do
      putStrLn "Reading from stdin..."
      content <- getContents
      case parse parseTokens "stdin" content of
        Left err -> print err
        Right tokens -> do
          if checkMain tokens
            then mapM_ print tokens
            else putStrLn "Error: No 'main' function found"
    _ -> putStrLn "Usage: program [filename] or use redirection"