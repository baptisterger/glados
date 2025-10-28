module Compiler where

import Ast
import qualified Wasm as W
import WasmGenerator
import qualified Data.Map as Map

compileProgram :: Program -> String
compileProgram (Program decls) = moduleToWat $ W.WasmModule functions []
  where functions = [compileFuncDecl decl | decl@(FuncDecl _ _ _) <- decls]

compileFuncDecl :: TopLevelDecl -> W.WasmFunc
compileFuncDecl (FuncDecl name params body) = W.WasmFunc
  { W.funcName = name
  , W.funcParams = map (\(Param ty _) -> W.typeToWasm ty) params
  , W.funcResult = Nothing
  , W.funcLocals = []
  , W.funcBody = concatMap (compileStmt paramCtx) body
  }
  where paramCtx = Map.fromList $ zip (map (\(Param _ n) -> n) params) [0..]

compileStmt :: Map.Map String Int -> Stmt -> [W.WasmInstr]
compileStmt ctx stmt = case stmt of
  StmtExpr expr -> compileExpr ctx expr ++ [W.Drop]
  StmtVarDecl _ _ expr -> compileExpr ctx expr ++ [W.Drop]
  StmtIf cond thenStmts elseStmts -> 
    compileExpr ctx cond ++ 
    [W.If (concatMap (compileStmt ctx) thenStmts) 
        (fmap (concatMap (compileStmt ctx)) elseStmts)]
  StmtReturn Nothing -> []
  StmtReturn (Just expr) -> compileExpr ctx expr
  _ -> [] 

compileExpr :: Map.Map String Int -> Expr -> [W.WasmInstr]
compileExpr ctx expr = case expr of
  IntConst n -> [W.I32Const n]
  FloatConst f -> [W.F32Const f]
  BoolConst True -> [W.I32Const 1]
  BoolConst False -> [W.I32Const 0]
  
  Var name -> case Map.lookup name ctx of
    Just idx -> [W.LocalGet idx]
    Nothing -> error $ "Undefined variable: " ++ name
    
  BinOp "+" l r -> compileExpr ctx l ++ compileExpr ctx r ++ [W.I32Add]
  BinOp "*" l r -> compileExpr ctx l ++ compileExpr ctx r ++ [W.I32Mul]
  BinOp "==" l r -> compileExpr ctx l ++ compileExpr ctx r ++ [W.I32Eq]
    
  Ast.Call "print" [arg] -> compileExpr ctx arg ++ [W.Call "$print"]
  Ast.Call fname args -> concatMap (compileExpr ctx) args ++ [W.Call ("$" ++ fname)]
    
  _ -> error $ "Unsupported expression: " ++ show expr