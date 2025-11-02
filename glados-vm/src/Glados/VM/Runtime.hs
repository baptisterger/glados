{-
-- EPITECH PROJECT, 2025
-- glados-vm [WSL: Ubuntu]
-- File description:
-- Runtime
-}

module Glados.VM.Runtime
  ( instantiate
  , getExportedFunc
  , funcCount
  ) where

import Glados.VM.Types
import qualified Data.Map.Strict as M
import qualified Data.Vector as V

instantiate :: Module -> Store
instantiate = Store

getExportedFunc :: Store -> String -> Maybe FuncIdx
getExportedFunc st nm = case M.lookup nm (exports $ sModule st) of
  Just (ExportFunc _ idx) -> Just idx
  _ -> Nothing

funcCount :: Module -> Int
funcCount = V.length . funcs