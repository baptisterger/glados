module NewParserSpec (spec) where

import Test.Hspec
import Text.Parsec (parse)
import Parser
import Types

-- Helper function to run parser
parseTest :: String -> Either String LispVal
parseTest input = case parse parseExpr "test" input of
  Left err -> Left (show err)
  Right val -> Right val

spec :: Spec
spec = do
  describe "Parser Tests" $ do
    describe "Atom parsing" $ do
      it "parses simple symbols" $ do
        parseTest "foo" `shouldBe` Right (Atom "foo")
        parseTest "bar" `shouldBe` Right (Atom "bar")
        parseTest "+" `shouldBe` Right (Atom "+")
        parseTest "-" `shouldBe` Right (Atom "-")
        parseTest "*" `shouldBe` Right (Atom "*")
        parseTest "div" `shouldBe` Right (Atom "div")
        parseTest "mod" `shouldBe` Right (Atom "mod")
        parseTest "eq?" `shouldBe` Right (Atom "eq?")

    describe "Number parsing" $ do
      it "parses positive integers" $ do
        parseTest "42" `shouldBe` Right (Number 42)
        parseTest "0" `shouldBe` Right (Number 0)
        parseTest "123456" `shouldBe` Right (Number 123456)

      it "parses negative integers" $ do
        parseTest "-1" `shouldBe` Right (Number (-1))
        parseTest "-42" `shouldBe` Right (Number (-42))
        parseTest "-999" `shouldBe` Right (Number (-999))

    describe "Boolean parsing" $ do
      it "parses true and false" $ do
        parseTest "#t" `shouldBe` Right (Bool True)
        parseTest "#f" `shouldBe` Right (Bool False)

    describe "List parsing" $ do
      it "parses empty list" $ do
        parseTest "()" `shouldBe` Right (List [])

      it "parses single element lists" $ do
        parseTest "(42)" `shouldBe` Right (List [Number 42])
        parseTest "(foo)" `shouldBe` Right (List [Atom "foo"])
        parseTest "(#t)" `shouldBe` Right (List [Bool True])

      it "parses multi-element lists" $ do
        parseTest "(1 2 3)" `shouldBe` Right (List [Number 1, Number 2, Number 3])
        parseTest "(+ 1 2)" `shouldBe` Right (List [Atom "+", Number 1, Number 2])
        parseTest "(foo bar baz)" `shouldBe` Right (List [Atom "foo", Atom "bar", Atom "baz"])

      it "parses nested lists" $ do
        parseTest "((1 2) (3 4))" `shouldBe`
          Right (List [List [Number 1, Number 2], List [Number 3, Number 4]])
        parseTest "(+ (* 2 3) (div 10 2))" `shouldBe`
          Right (List [Atom "+",
                      List [Atom "*", Number 2, Number 3],
                      List [Atom "div", Number 10, Number 2]])

    describe "Complex expressions" $ do
      it "parses define expressions" $ do
        parseTest "(define x 42)" `shouldBe`
          Right (List [Atom "define", Atom "x", Number 42])

      it "parses lambda expressions" $ do
        parseTest "(lambda (x y) (+ x y))" `shouldBe`
          Right (List [Atom "lambda", List [Atom "x", Atom "y"],
                      List [Atom "+", Atom "x", Atom "y"]])

      it "parses if expressions" $ do
        parseTest "(if #t 1 2)" `shouldBe`
          Right (List [Atom "if", Bool True, Number 1, Number 2])

    describe "Error cases" $ do
      it "rejects invalid booleans" $ do
        parseTest "#x" `shouldSatisfy` isLeft
        parseTest "#" `shouldSatisfy` isLeft

-- Helper function
isLeft :: Either a b -> Bool
isLeft (Left _) = True
isLeft (Right _) = False