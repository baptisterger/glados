{-
-- EPITECH PROJECT, 2025
-- glados-vm [WSL: Ubuntu]
-- File description:
-- Main
-}

module Main (main) where

import System.Environment (getArgs)
import System.Exit (exitFailure, exitSuccess)
import Control.Monad.Except
import Glados.VM.Types
import Glados.VM.Runtime
import Glados.VM.Exec
import Glados.VM.WasmDecodeSubset (decodeModuleFromFile)

usage :: IO ()
usage = putStrLn "Usage: glados-vm <module.wasm>"

main :: IO ()
main = do
  args <- getArgs
  case args of
    [wasmFile] -> do
      mod0 <- decodeModuleFromFile wasmFile
      let st0 = instantiate mod0
      r <- runExceptT $ runExported st0 "main" []
      case r of
        Left err -> putStrLn ("Runtime error: " <> err) >> exitFailure
        Right (ret, _st) -> do
          case ret of
            Just (I32 n) -> putStrLn ("WASM returned i32 " <> show n)
            Just (F32 x) -> putStrLn ("WASM returned f32 " <> show x)
            Nothing      -> putStrLn "WASM returned no value"
          exitSuccess
    _ -> usage >> exitFailure