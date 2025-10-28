module Compiler where

import Ast
import qualified Wasm as W
import WasmGenerator
import qualified Data.Map as Map

-- Contexte étendu pour gérer les locales
data CompileContext = CompileContext
  { ctxVars :: Map.Map String Int
  , ctxNextLocal :: Int
  , ctxLocals :: [W.WasmType]
  } deriving Show

compileProgram :: Program -> String
compileProgram (Program decls) = moduleToWat $ W.WasmModule functions []
  where functions = [compileFuncDecl decl | decl@(FuncDecl _ _ _) <- decls]

compileFuncDecl :: TopLevelDecl -> W.WasmFunc
compileFuncDecl (FuncDecl name params body) = W.WasmFunc
  { W.funcName = name
  , W.funcParams = map (\(Param ty _) -> W.typeToWasm ty) params
  , W.funcResult = Just W.I32
  , W.funcLocals = ctxLocals finalCtx
  , W.funcBody = instrs
  }
  where 
    paramCtx = CompileContext 
      { ctxVars = Map.fromList $ zip (map (\(Param _ n) -> n) params) [0..]
      , ctxNextLocal = length params
      , ctxLocals = []
      }
    (instrs, finalCtx) = compileStmts paramCtx body

compileStmts :: CompileContext -> [Stmt] -> ([W.WasmInstr], CompileContext)
compileStmts ctx [] = ([], ctx)
compileStmts ctx (stmt:rest) = 
  let (instrs1, ctx1) = compileStmt ctx stmt
      (instrs2, ctx2) = compileStmts ctx1 rest
  in (instrs1 ++ instrs2, ctx2)

compileStmt :: CompileContext -> Stmt -> ([W.WasmInstr], CompileContext)
compileStmt ctx stmt = case stmt of
  StmtExpr expr -> (compileExpr ctx expr ++ [W.Drop], ctx)
  
  StmtVarDecl ty name expr -> 
    let localIdx = ctxNextLocal ctx
        newCtx = ctx 
          { ctxVars = Map.insert name localIdx (ctxVars ctx)
          , ctxNextLocal = localIdx + 1
          , ctxLocals = ctxLocals ctx ++ [W.typeToWasm ty]
          }
        instrs = compileExpr ctx expr ++ [W.LocalSet localIdx]
    in (instrs, newCtx)
  
  StmtIf cond thenStmts elseStmts -> 
    let condInstrs = compileExpr ctx cond
        (thenInstrs', _) = compileStmts ctx thenStmts
        elseInstrs' = case elseStmts of
          Nothing -> Nothing
          Just stmts -> let (instrs, _) = compileStmts ctx stmts in Just instrs
    in (condInstrs ++ [W.If thenInstrs' elseInstrs'], ctx)
  
  StmtReturn Nothing -> ([W.I32Const 0, W.Return], ctx)
  StmtReturn (Just expr) -> (compileExpr ctx expr ++ [W.Return], ctx)
  
  _ -> ([], ctx)

compileExpr :: CompileContext -> Expr -> [W.WasmInstr]
compileExpr ctx expr = case expr of
  IntConst n -> [W.I32Const n]
  FloatConst f -> [W.F32Const f]
  BoolConst True -> [W.I32Const 1]
  BoolConst False -> [W.I32Const 0]
  
  Var name -> case Map.lookup name (ctxVars ctx) of
    Just idx -> [W.LocalGet idx]
    Nothing -> error $ "Undefined variable: " ++ name
    
  BinOp "+" l r -> compileExpr ctx l ++ compileExpr ctx r ++ [W.I32Add]
  BinOp "*" l r -> compileExpr ctx l ++ compileExpr ctx r ++ [W.I32Mul]
  BinOp "==" l r -> compileExpr ctx l ++ compileExpr ctx r ++ [W.I32Eq]
    
  Ast.Call fname args -> concatMap (compileExpr ctx) args ++ [W.Call ("$" ++ fname)]
    
  _ -> error $ "Unsupported expression: " ++ show expr