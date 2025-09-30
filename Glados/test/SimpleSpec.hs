module SimpleSpec (spec) where

import Test.Hspec
import Control.Monad.Reader
import Control.Monad.Except
import qualified Data.Map as M
import Parser
import Eval
import Types
import Text.Parsec (parse)

-- Helper function to parse and evaluate
parseAndEval :: String -> IO (Either String LispVal)
parseAndEval input = do
  case parse parseExpr "test" input of
    Left parseErr -> return $ Left (show parseErr)
    Right expr -> do
      result <- runReaderT (runExceptT (eval expr)) initialEnv
      case result of
        Left evalErr -> return $ Left (show evalErr)
        Right val -> return $ Right val

spec :: Spec
spec = do
  describe "Simple Integration Tests" $ do
    describe "Basic parsing and evaluation" $ do
      it "evaluates numbers" $ do
        result <- parseAndEval "42"
        result `shouldBe` Right (Number 42)

      it "evaluates booleans" $ do
        result1 <- parseAndEval "#t"
        result1 `shouldBe` Right (Bool True)
        result2 <- parseAndEval "#f"
        result2 `shouldBe` Right (Bool False)

      it "evaluates basic arithmetic" $ do
        result1 <- parseAndEval "(+ 1 2)"
        result1 `shouldBe` Right (Number 3)
        result2 <- parseAndEval "(- 5 3)"
        result2 `shouldBe` Right (Number 2)
        result3 <- parseAndEval "(* 3 4)"
        result3 `shouldBe` Right (Number 12)
        result4 <- parseAndEval "(div 10 2)"
        result4 `shouldBe` Right (Number 5)

      it "evaluates comparisons" $ do
        result1 <- parseAndEval "(< 1 2)"
        result1 `shouldBe` Right (Bool True)
        result2 <- parseAndEval "(< 2 1)"
        result2 `shouldBe` Right (Bool False)
        result3 <- parseAndEval "(eq? 5 5)"
        result3 `shouldBe` Right (Bool True)

      it "evaluates if expressions" $ do
        result1 <- parseAndEval "(if #t 1 2)"
        result1 `shouldBe` Right (Number 1)
        result2 <- parseAndEval "(if #f 1 2)"
        result2 `shouldBe` Right (Number 2)

      it "evaluates lambda expressions" $ do
        result <- parseAndEval "((lambda (x) x) 42)"
        result `shouldBe` Right (Number 42)

    describe "Error handling" $ do
      it "handles parse errors" $ do
        result <- parseAndEval "("
        result `shouldSatisfy` isLeft

      it "handles unbound variables" $ do
        result <- parseAndEval "undefined-var"
        result `shouldSatisfy` isLeft

      it "handles type errors" $ do
        result <- parseAndEval "(+ 1 #t)"
        result `shouldSatisfy` isLeft

-- Helper function
isLeft :: Either a b -> Bool
isLeft (Left _) = True
isLeft (Right _) = False