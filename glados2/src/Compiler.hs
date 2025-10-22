module Compiler where

import Ast
import Wasm
import WasmGenerator
import qualified Data.Map as Map

compileProgram :: Program -> String
compileProgram (Program decls) = moduleToWat $ WasmModule functions []
  where functions = [compileFuncDecl decl | FuncDecl _ _ _ <- decls]

compileFuncDecl :: TopLevelDecl -> WasmFunc
compileFuncDecl (FuncDecl name params body) = WasmFunc
  { funcName = name
  , funcParams = map (\(Param ty _) -> typeToWasm ty) params
  , funcResult = Nothing
  , funcLocals = []
  , funcBody = concatMap (compileStmt paramCtx) body
  }
  where paramCtx = Map.fromList $ zip (map (\(Param _ n) -> n) params) [0..]

compileStmt :: Map.Map String Int -> Stmt -> [WasmInstr]
compileStmt ctx stmt = case stmt of
  StmtExpr expr -> compileExpr ctx expr ++ [Drop]
  StmtVarDecl _ _ expr -> compileExpr ctx expr ++ [Drop]
  StmtIf cond thenStmts elseStmts -> 
    compileExpr ctx cond ++ 
    [If (concatMap (compileStmt ctx) thenStmts) 
        (fmap (concatMap (compileStmt ctx)) elseStmts)]
  StmtReturn Nothing -> []
  StmtReturn (Just expr) -> compileExpr ctx expr
  _ -> [] 

compileExpr :: Map.Map String Int -> Expr -> [WasmInstr]
compileExpr ctx expr = case expr of
  IntConst n -> [I32Const n]
  FloatConst f -> [F32Const f]
  BoolConst True -> [I32Const 1]
  BoolConst False -> [I32Const 0]
  
  Var name -> case Map.lookup name ctx of
    Just idx -> [LocalGet idx]
    Nothing -> error $ "Undefined variable: " ++ name
    
  BinOp "+" l r -> compileExpr ctx l ++ compileExpr ctx r ++ [I32Add]
  BinOp "*" l r -> compileExpr ctx l ++ compileExpr ctx r ++ [I32Mul]
  BinOp "==" l r -> compileExpr ctx l ++ compileExpr ctx r ++ [I32Eq]
    
  Call "print" [arg] -> compileExpr ctx arg ++ [Call "$print"]
  Call fname args -> concatMap (compileExpr ctx) args ++ [Call ("$" ++ fname)]
    
  _ -> error $ "Unsupported expression: " ++ show expr