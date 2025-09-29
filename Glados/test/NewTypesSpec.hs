module NewTypesSpec (spec) where

import Test.Hspec
import Types
import qualified Data.Map as M

spec :: Spec
spec = do
  describe "Types Tests" $ do
    describe "LispVal Equality" $ do
      it "compares Atoms correctly" $ do
        Atom "foo" `shouldBe` Atom "foo"
        Atom "foo" `shouldNotBe` Atom "bar"

      it "compares Numbers correctly" $ do
        Number 42 `shouldBe` Number 42
        Number 1 `shouldNotBe` Number 2
        Number (-5) `shouldBe` Number (-5)

      it "compares Bools correctly" $ do
        Bool True `shouldBe` Bool True
        Bool False `shouldBe` Bool False
        Bool True `shouldNotBe` Bool False

      it "compares Lists correctly" $ do
        List [] `shouldBe` List []
        List [Number 1, Number 2] `shouldBe` List [Number 1, Number 2]
        List [Number 1] `shouldNotBe` List [Number 2]
        List [Atom "a", Bool True] `shouldBe` List [Atom "a", Bool True]

      it "different types are not equal" $ do
        Atom "42" `shouldNotBe` Number 42
        Bool True `shouldNotBe` Number 1
        List [] `shouldNotBe` Atom "nil"
        Number 0 `shouldNotBe` Bool False

    describe "LispVal Show" $ do
      it "shows Atoms correctly" $ do
        show (Atom "hello") `shouldBe` "hello"
        show (Atom "foo-bar") `shouldBe` "foo-bar"
        show (Atom "+") `shouldBe` "+"
        show (Atom "eq?") `shouldBe` "eq?"

      it "shows Numbers correctly" $ do
        show (Number 42) `shouldBe` "42"
        show (Number (-1)) `shouldBe` "-1"
        show (Number 0) `shouldBe` "0"
        show (Number 999999) `shouldBe` "999999"

      it "shows Bools correctly" $ do
        show (Bool True) `shouldBe` "#t"
        show (Bool False) `shouldBe` "#f"

      it "shows Lists correctly" $ do
        show (List []) `shouldBe` "()"
        show (List [Number 1]) `shouldBe` "(1)"
        show (List [Number 1, Number 2, Number 3]) `shouldBe` "(1 2 3)"
        show (List [Atom "foo", Number 42]) `shouldBe` "(foo 42)"
        show (List [Bool True, Atom "test"]) `shouldBe` "(#t test)"

      it "shows nested Lists correctly" $ do
        show (List [List [Number 1, Number 2], Number 3]) `shouldBe` "((1 2) 3)"
        show (List [Atom "+", List [Atom "*", Number 2, Number 3]]) `shouldBe` "(+ (* 2 3))"

      it "shows Procedures and Builtins" $ do
        let proc = Proc (Procedure [] (Number 1) M.empty)
        show proc `shouldBe` "#<procedure>"

    describe "LispError Show" $ do
      it "shows UnboundVar errors" $ do
        show (UnboundVar "x") `shouldContain` "x"

      it "shows TypeError errors" $ do
        show (TypeError "test message") `shouldContain` "test message"

      it "shows NumArgs errors" $ do
        show (NumArgs 2 [Number 1]) `shouldContain` "2"

    describe "Procedure type" $ do
      it "shows procedures consistently" $ do
        let proc1 = Procedure [] (Number 1) M.empty
        let proc2 = Procedure ["x"] (Atom "x") M.empty
        show proc1 `shouldBe` "#<procedure>"
        show proc2 `shouldBe` "#<procedure>"