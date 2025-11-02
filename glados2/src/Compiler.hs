module Compiler where

import Ast
import qualified Wasm as W
import WasmGenerator
import qualified Data.Map as Map

data CompileContext = CompileContext
  { ctxVars :: Map.Map String Int
  , ctxVarTypes :: Map.Map String Type
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

getParamNames :: [Param] -> [String]
getParamNames params = map extractParamName params

createParamIndexMap :: [String] -> Map.Map String Int
createParamIndexMap names = Map.fromList (zip names [0..])

createInitialContext :: [Param] -> CompileContext
createInitialContext params = CompileContext
  { ctxVars = createParamIndexMap (getParamNames params)
  , ctxVarTypes = Map.fromList $ map (\p -> (extractParamName p, extractParamType p)) params
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
  { ctxVars = Map.insert name idx (ctxVars ctx)
  , ctxVarTypes = Map.insert name ty (ctxVarTypes ctx)
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

inferExprType :: CompileContext -> Expr -> Type
inferExprType _ (IntConst _) = TypeInt
inferExprType _ (FloatConst _) = TypeFloat
inferExprType _ (BoolConst _) = TypeBool
inferExprType ctx (Var name) = 
    case Map.lookup name (ctxVarTypes ctx) of
        Just ty -> ty
        Nothing -> error $ "Undefined variable: " ++ name
inferExprType ctx (BinOp op l r) =
    let ltype = inferExprType ctx l
        rtype = inferExprType ctx r
    in if ltype == TypeFloat || rtype == TypeFloat
           then TypeFloat
           else TypeInt
inferExprType _ e = error $ "Type inference not supported for: " ++ show e

compileExpr :: CompileContext -> Expr -> [W.WasmInstr]
compileExpr ctx (IntConst n)    = [W.I32Const n]
compileExpr ctx (FloatConst f)  = [W.F32Const f]
compileExpr ctx (BoolConst b)   = [W.I32Const $ if b then 1 else 0]
compileExpr ctx (Var name)      = maybe (error $ "Undefined variable: " ++ name) (\idx -> [W.LocalGet idx]) (Map.lookup name $ ctxVars ctx)
compileExpr ctx (BinOp op l r) = 
    let ltype = inferExprType ctx l
        rtype = inferExprType ctx r
        linstrs = compileExpr ctx l
        rinstrs = compileExpr ctx r
    in if ltype == TypeFloat || rtype == TypeFloat then
        let lfloat = if ltype == TypeInt then linstrs ++ [W.F32ConvertI32S] else linstrs
            rfloat = if rtype == TypeInt then rinstrs ++ [W.F32ConvertI32S] else rinstrs
            fop = case op of
                "+" -> W.F32Add
                "*" -> W.F32Mul
                _   -> error $ "Unsupported float operator: " ++ op
        in lfloat ++ rfloat ++ [fop]
    else
        let iop = case op of
                "+" -> W.I32Add
                "*" -> W.I32Mul
                "==" -> W.I32Eq
                _   -> error $ "Unsupported int operator: " ++ op
        in linstrs ++ rinstrs ++ [iop]
compileExpr ctx (Ast.Call f as) = concatMap (compileExpr ctx) as ++ [W.Call $ "$" ++ f]
compileExpr ctx e               = error $ "Unsupported expression: " ++ show e