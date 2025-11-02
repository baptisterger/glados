module Main where

import System.Environment (getArgs)
import Lib (parseStringToAST)

main :: IO ()
main = do
  args <- getArgs
  case args of
    (f:_) -> do
      content <- readFile f
      print (parseStringToAST content)
    _ -> putStrLn "Usage: debug_parse.hs <file>"
