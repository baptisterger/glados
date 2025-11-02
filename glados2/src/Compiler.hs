module Compiler where

import Ast
import Data.Maybe (fromMaybe)
import Control.Applicative ((<|>))
import qualified Wasm as W
import WasmGenerator
import qualified Data.Map as Map

data CompileContext = CompileContext
  { ctxVars :: Map.Map String (Int, Type)
  , ctxNextLocal :: Int
  , ctxLocals :: [W.WasmType]
  } deriving Show

compileProgram :: Program -> String
compileProgram (Program decls) = moduleToWat $ W.WasmModule (map compileFuncDecl (filter isFuncDecl decls)) []
  where
    isFuncDecl (FuncDecl _ _ _) = True
    isFuncDecl _ = False

compileProgramToWasm :: Program -> W.WasmModule
compileProgramToWasm (Program decls) = W.WasmModule (map compileFuncDecl (filter isFuncDecl decls)) []
  where
    isFuncDecl (FuncDecl _ _ _) = True
    isFuncDecl _ = False

extractParamType (Param ty _) = ty

extractParamName :: Param -> String
extractParamName (Param _ name) = name

getWasmParamTypes :: [Param] -> [W.WasmType]
getWasmParamTypes params = map (W.typeToWasm . extractParamType) params

createParamIndexMap :: [Param] -> Map.Map String (Int, Type)
createParamIndexMap params = Map.fromList $ zipWith (\r i -> let (Param ty name) = r in (name, (i, ty))) params [0..]

createInitialContext :: [Param] -> CompileContext
createInitialContext params = CompileContext
  { ctxVars = createParamIndexMap params
  , ctxNextLocal = length params
  , ctxLocals = []
  }

compileFuncDecl :: TopLevelDecl -> W.WasmFunc
compileFuncDecl (FuncDecl name params body) = 
  let initialContext = createInitialContext params
      (instructions, finalContext) = compileStmts initialContext body
  in W.WasmFunc
    { W.funcName = name
    , W.funcParams = getWasmParamTypes params
    , W.funcResult = Just W.I32
    , W.funcLocals = ctxLocals finalContext
    , W.funcBody = instructions
    }

compileStmts :: CompileContext -> [Stmt] -> ([W.WasmInstr], CompileContext)
compileStmts ctx stmts = foldl step ([], ctx) stmts
  where step (accInstrs, accCtx) stmt = 
          let (newInstrs, newCtx) = compileStmt accCtx stmt
          in (accInstrs ++ newInstrs, newCtx)

compileStmt :: CompileContext -> Stmt -> ([W.WasmInstr], CompileContext)
compileStmt ctx (StmtExpr expr) = 
  compileExprStmt ctx expr

compileStmt ctx (StmtVarDecl ty name expr) = 
  compileVarDecl ctx ty name expr

compileStmt ctx (StmtIf cond thenStmts elseStmts) = 
  compileIfStmt ctx cond thenStmts elseStmts

compileStmt ctx (StmtReturn mexpr) = 
  compileReturnStmt ctx mexpr

compileStmt ctx (StmtWhile _ _) = 
  ([], ctx)

compileExprStmt :: CompileContext -> Expr -> ([W.WasmInstr], CompileContext)
compileExprStmt ctx expr = 
  (compileExpr ctx expr ++ [W.Drop], ctx)

compileVarDecl :: CompileContext -> Type -> String -> Expr -> ([W.WasmInstr], CompileContext)
compileVarDecl ctx ty name expr = 
  let idx = ctxNextLocal ctx
      instrs = compileExpr ctx expr ++ [W.LocalSet idx]
      newCtx = addLocalVar ctx name idx ty
  in (instrs, newCtx)

addLocalVar :: CompileContext -> String -> Int -> Type -> CompileContext
addLocalVar ctx name idx ty = ctx
  { ctxVars = Map.insert name (idx, ty) (ctxVars ctx)
  , ctxNextLocal = idx + 1
  , ctxLocals = ctxLocals ctx ++ [W.typeToWasm ty]
  }

compileIfStmt :: CompileContext -> Expr -> [Stmt] -> Maybe [Stmt] -> ([W.WasmInstr], CompileContext)
compileIfStmt ctx cond thenStmts elseStmts = 
  let condInstrs = compileExpr ctx cond
      thenInstrs = fst $ compileStmts ctx thenStmts
      elseInstrs = case elseStmts of
        Just stmts -> Just (fst $ compileStmts ctx stmts)
        Nothing -> Nothing
      ifInstr = W.If thenInstrs elseInstrs
  in (condInstrs ++ [ifInstr], ctx)

compileReturnStmt :: CompileContext -> Maybe Expr -> ([W.WasmInstr], CompileContext)
compileReturnStmt ctx mexpr = 
  let valueInstrs = case mexpr of
        Just expr -> compileExpr ctx expr
        Nothing -> [W.I32Const 0]
  in (valueInstrs ++ [W.Return], ctx)

compileExpr :: CompileContext -> Expr -> [W.WasmInstr]
compileExpr ctx (IntConst n)    = [W.I32Const n]
compileExpr ctx (FloatConst f)  = [W.F32Const f]
compileExpr ctx (BoolConst b)   = [W.I32Const $ if b then 1 else 0]
compileExpr ctx (Var name)      = case Map.lookup name (ctxVars ctx) of
  Just (idx, _) -> [W.LocalGet idx]
  Nothing -> error $ "Undefined variable: " ++ name

compileExpr ctx (BinOp op l r)  =
  let t = inferExprType ctx l <|> inferExprType ctx r
      wasmTy = case t of
        Just TypeFloat -> W.F32
        _ -> W.I32
  in compileExpr ctx l ++ compileExpr ctx r ++ [compileBinOp op wasmTy]

compileExpr ctx (Ast.Call f as) = concatMap (compileExpr ctx) as ++ [W.Call $ "$" ++ f]
compileExpr ctx e               = error $ "Unsupported expression: " ++ show e

-- Infer expression type when possible
inferExprType :: CompileContext -> Expr -> Maybe Type
inferExprType _ (IntConst _) = Just TypeInt
inferExprType _ (FloatConst _) = Just TypeFloat
inferExprType _ (BoolConst _) = Just TypeBool
inferExprType ctx (Var name) = snd <$> Map.lookup name (ctxVars ctx)
inferExprType ctx (BinOp _ l r) =
  case (inferExprType ctx l, inferExprType ctx r) of
    (Just TypeFloat, _) -> Just TypeFloat
    (_, Just TypeFloat) -> Just TypeFloat
    (Just TypeInt, Just TypeInt) -> Just TypeInt
    _ -> Nothing
inferExprType _ _ = Nothing

compileBinOp :: String -> W.WasmType -> W.WasmInstr
compileBinOp op W.I32
  | op == "+" = W.I32Add
  | op == "*" = W.I32Mul
  | op == "-" = W.I32Sub
  | op == "/" = W.I32Div
  | op == "==" = W.I32Eq
  | op == "<" = W.I32Lt
  | op == ">" = W.I32Gt
  | op == "<=" = W.I32Le
  | op == ">=" = W.I32Ge
  | otherwise = error $ "Unsupported integer operator: " ++ op

compileBinOp op W.F32
  | op == "+" = W.F32Add
  | op == "*" = W.F32Mul
  | op == "-" = W.F32Sub
  | op == "/" = W.F32Div
  | op == "==" = W.F32Eq
  | op == "<" = W.F32Lt
  | op == ">" = W.F32Gt
  | op == "<=" = W.F32Le
  | op == ">=" = W.F32Ge
  | otherwise = error $ "Unsupported float operator: " ++ op