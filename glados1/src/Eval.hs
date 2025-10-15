module Eval (eval, Env, LispVal(..), Procedure(..), initialEnv, LispError(..)) where

import Types
import qualified Data.Map as M
import Control.Monad.Except
import Control.Monad.Reader
import Data.Function (fix)

builtins :: [(String, [LispVal] -> EvalM LispVal)]
builtins = [("+", numOp (+)), ("-", numOp (-)), ("*", numOp (*)), 
            ("div", numOp div), ("mod", numOp mod), ("<", boolOp (<)), ("eq?", eqOp)]

numOp :: (Integer -> Integer -> Integer) -> [LispVal] -> EvalM LispVal
numOp op [Number a, Number b] = return $ Number (op a b)
numOp _ args = throwError $ TypeError $ "Expected 2 numbers, got: " ++ show args

boolOp :: (Integer -> Integer -> Bool) -> [LispVal] -> EvalM LispVal
boolOp op [Number a, Number b] = return $ Bool (op a b)
boolOp _ args = throwError $ TypeError $ "Expected 2 numbers, got: " ++ show args

eqOp :: [LispVal] -> EvalM LispVal
eqOp [a, b] = return $ Bool (a == b)
eqOp args = throwError $ TypeError $ "eq? expects 2 arguments, got: " ++ show args

initialEnv :: Env
initialEnv = M.fromList [(name, Builtin f) | (name, f) <- builtins]

eval :: LispVal -> EvalM LispVal
eval val@(Number _) = return val
eval val@(Bool _) = return val
eval val@(Proc _) = return val
eval val@(Builtin _) = return val

eval (Atom name) = do
    env <- ask
    case M.lookup name env of
        Just v -> return v
        Nothing -> throwError $ UnboundVar name

eval (List [Atom "define", Atom var, expr]) = do
    val <- eval expr
    return val

eval (List [Atom "define", List (Atom fname:params), body]) = do
    env <- ask
    let paramNames = [n | Atom n <- params]
        proc = fix $ \recursiveProc -> Proc $ Procedure paramNames body (M.insert fname recursiveProc env)
    return proc

eval (List [Atom "lambda", List params, body]) = do
    env <- ask
    let paramNames = [n | Atom n <- params]
    return $ Proc $ Procedure paramNames body env

eval (List [Atom "if", cond, texp, fexp]) = do
    c <- eval cond
    case c of
        Bool True -> eval texp
        Bool False -> eval fexp
        _ -> throwError $ TypeError "Condition must be boolean"

eval (List (f:args)) = do
    funVal <- eval f
    case funVal of
        Proc (Procedure params body closure) ->
            if length params /= length args
            then throwError $ NumArgs (length params) args
            else do
                argVals <- mapM eval args
                currentEnv <- ask
                let newEnv = M.fromList (zip params argVals) `M.union` closure `M.union` currentEnv
                local (const newEnv) (eval body)
        Builtin builtin -> do
            argVals <- mapM eval args
            builtin argVals
        _ -> throwError $ TypeError "First element is not a function"

eval (List []) = return $ List []
eval expr = throwError $ TypeError $ "Unknown expression: " ++ show expr
