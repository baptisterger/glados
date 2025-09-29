import Test.Hspec

import qualified SimpleSpec
import qualified NewParserSpec
import qualified NewTypesSpec
import qualified NewEvalSpec

main :: IO ()
main = hspec $ do
  describe "GLaDOS LISP Interpreter Tests" $ do
    SimpleSpec.spec
    NewParserSpec.spec
    NewTypesSpec.spec
    NewEvalSpec.spec