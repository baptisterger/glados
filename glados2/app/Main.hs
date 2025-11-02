module Main (main) where

import System.Environment (getArgs)
import System.Exit (exitFailure, exitSuccess)
import System.IO (hFlush, stdout)
import Lib (parseFile, parseStringToAST, hasMain)
import Data.List (nub)
import qualified Ast as Ast
import Compiler (compileProgram, compileProgramToWasm)
import WasmBinary (generateWasmFile)

-- collect operators from AST for debugging
collectOpsFromProgram :: Ast.Program -> [String]
collectOpsFromProgram (Ast.Program decls) = concatMap collectDecl decls
  where
    collectDecl (Ast.FuncDecl _ _ stmts) = concatMap collectStmt stmts
    collectDecl _ = []

    collectStmt (Ast.StmtExpr e) = collectExpr e
    collectStmt (Ast.StmtVarDecl _ _ e) = collectExpr e
    collectStmt (Ast.StmtIf cond thenStmts maybeElse) = collectExpr cond ++ concatMap collectStmt thenStmts ++ maybe [] (concatMap collectStmt) maybeElse
    collectStmt (Ast.StmtWhile cond body) = collectExpr cond ++ concatMap collectStmt body
    collectStmt (Ast.StmtReturn me) = maybe [] collectExpr me

    collectExpr (Ast.BinOp op l r) = [op] ++ collectExpr l ++ collectExpr r
    collectExpr (Ast.Assign _ e) = collectExpr e
    collectExpr (Ast.Call _ args) = concatMap collectExpr args
    collectExpr _ = []

replaceExtension :: FilePath -> String -> FilePath
replaceExtension path newExt = 
  let (base, _) = break (== '.') (reverse path)
  in reverse base ++ newExt

main :: IO ()
main = do
  args <- getArgs
  case args of
    [filename] -> do
      content <- readFile filename
      case parseStringToAST content of
        Left err -> do
          putStrLn $ "Parse error: " ++ show err
          exitFailure
        Right ast -> do
          putStrLn $ "Parsed successfully: " ++ filename
          putStrLn (show ast)
          hFlush stdout
          putStrLn $ "Operators found in AST: " ++ show (nub $ collectOpsFromProgram ast)
          hFlush stdout
          if hasMain ast
            then do
              putStrLn "Found main function"
              let wasmModule = compileProgramToWasm ast
              let wasmFile = replaceExtension filename ".wasm"
              
              generateWasmFile wasmModule wasmFile
              exitSuccess
            else do
              putStrLn "No main function found"
              exitFailure
    [] -> do
      putStrLn "Reading from stdin..."
      content <- getContents
      case parseStringToAST content of
        Left err -> do
          putStrLn ("Parse error: " ++ show err)
          exitFailure
        Right ast -> do
          print ast
          if hasMain ast
            then do
              let wasmCode = compileProgram ast
              exitSuccess
            else do
              putStrLn "No main function found"
              exitFailure
    _ -> do
      putStrLn "Usage: glados2 [filename]  (or run with no args to read from stdin)"
      exitFailure