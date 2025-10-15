module Main (main) where

import Parser
import Eval
import Text.Parsec (parse, sepEndBy, spaces)
import System.Exit (exitWith, ExitCode(..))
import System.IO (hPutStrLn, stderr)
import Control.Monad.Reader
import Control.Monad.Except
import qualified Data.Map as M
import System.Environment (getArgs)

printResult :: LispVal -> IO ()
printResult (Bool True) = putStrLn "#t"
printResult (Bool False) = putStrLn "#f"
printResult (Proc _) = putStrLn "#<procedure>"
printResult (Number n) = print n
printResult (Atom s) = putStrLn s
printResult (List xs) = putStrLn $ show xs

runEval :: Env -> LispVal -> IO ()
runEval env expr = do
    res <- runReaderT (runExceptT (eval expr)) env
    case res of
        Left err -> do
            hPutStrLn stderr ("*** ERROR : " ++ show err)
            exitWith (ExitFailure 84)
        Right val -> printResult val

evalSeq :: Env -> [LispVal] -> IO ()
evalSeq _ [] = return ()
evalSeq env (e:es) = do
    res <- runReaderT (runExceptT (eval e)) env
    case res of
        Left err -> do
            hPutStrLn stderr ("*** ERROR : " ++ show err)
            exitWith (ExitFailure 84)
        Right val -> do
            let newEnv = case e of
                    List [Atom "define", Atom var, _] -> M.insert var val env
                    List [Atom "define", List (Atom fname:_), _] -> M.insert fname val env
                    _ -> env
            if null es then printResult val else evalSeq newEnv es

main :: IO ()
main = do
    args <- getArgs
    (input, srcName) <- case args of
        [filename] -> do
            contents <- readFile filename
            return (contents, filename)
        [] -> do
            contents <- getContents
            return (contents, "stdin")
        _ -> do
            hPutStrLn stderr "Usage: Glados <file.scm>"
            exitWith (ExitFailure 84)
    
    case parse (parseExpr `sepEndBy` spaces) srcName input of
        Left err -> do
            hPutStrLn stderr ("*** ERROR : parse error: " ++ show err)
            exitWith (ExitFailure 84)
        Right exprs -> evalSeq initialEnv exprs
