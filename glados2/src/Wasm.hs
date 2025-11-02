module Wasm where

import Ast
import qualified Data.Map as Map

data WasmType = I32 | F32 deriving (Show, Eq)

data WasmInstr = 
    I32Const Int
  | F32Const Float
  | LocalGet Int
  | LocalSet Int
  | GlobalGet Int
  | GlobalSet Int
  | I32Add | I32Sub | I32Mul | I32Div
  | F32Add | F32Sub | F32Mul | F32Div
  | I32Eq | I32Ne | I32Lt | I32Gt
  | F32ConvertI32S
  | Call String
  | Return
  | Drop
  | Block [WasmInstr]
  | If [WasmInstr] (Maybe [WasmInstr])
  deriving Show

data WasmFunc = WasmFunc 
  { funcName :: String
  , funcParams :: [WasmType]
  , funcResult :: Maybe WasmType
  , funcLocals :: [WasmType]
  , funcBody :: [WasmInstr]
  } deriving Show

data WasmModule = WasmModule
  { wasmFunctions :: [WasmFunc]
  , wasmGlobals :: [(String, WasmType)]
  } deriving Show

typeToWasm :: Type -> WasmType
typeToWasm TypeInt = I32
typeToWasm TypeFloat = F32
typeToWasm TypeBool = I32

data Context = Context
  { localVars :: Map.Map String Int
  , globalVars :: Map.Map String Int
  , nextLocal :: Int
  } deriving Show

emptyContext :: Context
emptyContext = Context Map.empty Map.empty 0

addLocal :: String -> Type -> Context -> Context
addLocal name ty ctx = ctx
  { localVars = Map.insert name (nextLocal ctx) (localVars ctx)
  , nextLocal = nextLocal ctx + 1
  }