module NewEvalSpec (spec) where

import Test.Hspec
import Control.Monad.Reader
import Control.Monad.Except
import qualified Data.Map as M
import Eval
import Types

-- Helper function to run evaluation
evalTest :: LispVal -> IO (Either LispError LispVal)
evalTest expr = runReaderT (runExceptT (eval expr)) initialEnv

-- Helper to run with custom environment
evalWithEnv :: Env -> LispVal -> IO (Either LispError LispVal)
evalWithEnv env expr = runReaderT (runExceptT (eval expr)) env

spec :: Spec
spec = do
  describe "Evaluator Tests" $ do
    describe "Literal values" $ do
      it "evaluates numbers to themselves" $ do
        result1 <- evalTest (Number 42)
        result1 `shouldBe` Right (Number 42)
        result2 <- evalTest (Number 0)
        result2 `shouldBe` Right (Number 0)
        result3 <- evalTest (Number (-1))
        result3 `shouldBe` Right (Number (-1))

      it "evaluates booleans to themselves" $ do
        result1 <- evalTest (Bool True)
        result1 `shouldBe` Right (Bool True)
        result2 <- evalTest (Bool False)
        result2 `shouldBe` Right (Bool False)

      it "evaluates empty list to itself" $ do
        result <- evalTest (List [])
        result `shouldBe` Right (List [])

    describe "Variable lookup" $ do
      it "looks up builtin functions" $ do
        result <- evalTest (Atom "+")
        result `shouldSatisfy` isBuiltin

      it "throws UnboundVar for unbound variables" $ do
        result <- evalTest (Atom "unbound")
        result `shouldSatisfy` isUnboundVar

    describe "Arithmetic operations" $ do
      it "evaluates addition" $ do
        result1 <- evalTest (List [Atom "+", Number 1, Number 2])
        result1 `shouldBe` Right (Number 3)
        result2 <- evalTest (List [Atom "+", Number 0, Number 0])
        result2 `shouldBe` Right (Number 0)
        result3 <- evalTest (List [Atom "+", Number (-5), Number 10])
        result3 `shouldBe` Right (Number 5)

      it "evaluates subtraction" $ do
        result1 <- evalTest (List [Atom "-", Number 5, Number 3])
        result1 `shouldBe` Right (Number 2)
        result2 <- evalTest (List [Atom "-", Number 0, Number 1])
        result2 `shouldBe` Right (Number (-1))

      it "evaluates multiplication" $ do
        result1 <- evalTest (List [Atom "*", Number 3, Number 4])
        result1 `shouldBe` Right (Number 12)
        result2 <- evalTest (List [Atom "*", Number 0, Number 100])
        result2 `shouldBe` Right (Number 0)

      it "evaluates division" $ do
        result1 <- evalTest (List [Atom "div", Number 10, Number 2])
        result1 `shouldBe` Right (Number 5)
        result2 <- evalTest (List [Atom "div", Number 7, Number 3])
        result2 `shouldBe` Right (Number 2)

      it "evaluates modulo" $ do
        result1 <- evalTest (List [Atom "mod", Number 10, Number 3])
        result1 `shouldBe` Right (Number 1)
        result2 <- evalTest (List [Atom "mod", Number 8, Number 4])
        result2 `shouldBe` Right (Number 0)

    describe "Comparison operations" $ do
      it "evaluates less-than comparison" $ do
        result1 <- evalTest (List [Atom "<", Number 1, Number 2])
        result1 `shouldBe` Right (Bool True)
        result2 <- evalTest (List [Atom "<", Number 2, Number 1])
        result2 `shouldBe` Right (Bool False)
        result3 <- evalTest (List [Atom "<", Number 5, Number 5])
        result3 `shouldBe` Right (Bool False)

      it "evaluates equality comparison" $ do
        result1 <- evalTest (List [Atom "eq?", Number 42, Number 42])
        result1 `shouldBe` Right (Bool True)
        result2 <- evalTest (List [Atom "eq?", Number 1, Number 2])
        result2 `shouldBe` Right (Bool False)
        result3 <- evalTest (List [Atom "eq?", Bool True, Bool True])
        result3 `shouldBe` Right (Bool True)
        result4 <- evalTest (List [Atom "eq?", Bool True, Bool False])
        result4 `shouldBe` Right (Bool False)

    describe "Define expressions" $ do
      it "evaluates simple define" $ do
        result <- evalTest (List [Atom "define", Atom "x", Number 42])
        result `shouldBe` Right (Number 42)

      it "evaluates define with expression" $ do
        result <- evalTest (List [Atom "define", Atom "x", List [Atom "+", Number 1, Number 2]])
        result `shouldBe` Right (Number 3)

    describe "Lambda expressions" $ do
      it "creates lambda procedures" $ do
        result <- evalTest (List [Atom "lambda", List [Atom "x"], Atom "x"])
        result `shouldSatisfy` isProcedure

      it "creates lambda with multiple parameters" $ do
        result <- evalTest (List [Atom "lambda", List [Atom "x", Atom "y"], List [Atom "+", Atom "x", Atom "y"]])
        result `shouldSatisfy` isProcedure

      it "creates lambda with no parameters" $ do
        result <- evalTest (List [Atom "lambda", List [], Number 42])
        result `shouldSatisfy` isProcedure

    describe "Function application" $ do
      it "applies lambda functions" $ do
        let identityLambda = List [Atom "lambda", List [Atom "x"], Atom "x"]
        let application = List [identityLambda, Number 42]
        result <- evalTest application
        result `shouldBe` Right (Number 42)

      it "applies lambda with multiple arguments" $ do
        let addLambda = List [Atom "lambda", List [Atom "x", Atom "y"], List [Atom "+", Atom "x", Atom "y"]]
        let application = List [addLambda, Number 1, Number 2]
        result <- evalTest application
        result `shouldBe` Right (Number 3)

    describe "Conditional expressions" $ do
      it "evaluates if with true condition" $ do
        result <- evalTest (List [Atom "if", Bool True, Number 1, Number 2])
        result `shouldBe` Right (Number 1)

      it "evaluates if with false condition" $ do
        result <- evalTest (List [Atom "if", Bool False, Number 1, Number 2])
        result `shouldBe` Right (Number 2)

      it "evaluates condition expression" $ do
        result <- evalTest (List [Atom "if", List [Atom "<", Number 1, Number 2], Atom "yes", Atom "no"])
        result `shouldBe` Right (Atom "yes")

    describe "Error handling" $ do
      it "throws TypeError for wrong argument types" $ do
        result1 <- evalTest (List [Atom "+", Number 1, Bool True])
        result1 `shouldSatisfy` isTypeError
        result2 <- evalTest (List [Atom "*", Atom "foo", Number 2])
        result2 `shouldSatisfy` isTypeError

      it "throws TypeError for wrong number of arguments" $ do
        result1 <- evalTest (List [Atom "+", Number 1])
        result1 `shouldSatisfy` isTypeError
        result2 <- evalTest (List [Atom "+", Number 1, Number 2, Number 3])
        result2 `shouldSatisfy` isTypeError

      it "throws TypeError for non-boolean condition in if" $ do
        result <- evalTest (List [Atom "if", Number 1, Number 2, Number 3])
        result `shouldSatisfy` isTypeError

      it "throws TypeError for invalid function application" $ do
        result <- evalTest (List [Number 42, Number 1])
        result `shouldSatisfy` isTypeError

-- Helper functions for testing
isLeft :: Either a b -> Bool
isLeft (Left _) = True
isLeft (Right _) = False

isTypeError :: Either LispError a -> Bool
isTypeError (Left (TypeError _)) = True
isTypeError _ = False

isUnboundVar :: Either LispError a -> Bool
isUnboundVar (Left (UnboundVar _)) = True
isUnboundVar _ = False

isProcedure :: Either LispError LispVal -> Bool
isProcedure (Right (Proc _)) = True
isProcedure _ = False

isBuiltin :: Either LispError LispVal -> Bool
isBuiltin (Right (Builtin _)) = True
isBuiltin _ = False