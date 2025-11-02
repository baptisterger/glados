module Glados.VM.Types where

import Data.Int
import Data.Word (Word)
import qualified Data.Map.Strict as M
import qualified Data.Vector as V

data Value
  = I32 Int32
  | F32 Float
  deriving (Show, Eq)

data ValueType = T_i32 | T_f32
  deriving (Show, Eq)

data FuncType = FuncType
  { params  :: [ValueType]
  , results :: [ValueType]
  } deriving (Show, Eq)

data Instr
  = I32Const Int32
  | F32Const Float
  | LocalGet Word
  | LocalSet Word
  | I32Add
  | I32Mul
  | I32Eq
  | F32Add
  | F32Mul
  | F32ConvertI32S
  | Drop
  | If [Instr] [Instr]
  | Call Word
  | Return
  | End
  deriving (Show, Eq)

data Function = Function
  { fType   :: FuncType
  , fLocals :: [ValueType]
  , fBody   :: [Instr]
  } deriving (Show, Eq)

newtype FuncIdx = FuncIdx { unFuncIdx :: Int } deriving (Show, Eq, Ord)

data Export
  = ExportFunc { exportName :: String, exportFunc :: FuncIdx }
  deriving (Show, Eq)

data Module = Module
  { types   :: V.Vector FuncType
  , funcs   :: V.Vector Function
  , exports :: M.Map String Export
  } deriving (Show, Eq)

newtype Store = Store
  { sModule :: Module
  } deriving (Show, Eq)