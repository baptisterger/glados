module Main where

import Compiler (compileBinOp)

main :: IO ()
main = print (compileBinOp ">")
