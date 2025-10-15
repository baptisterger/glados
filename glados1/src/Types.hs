module Types where
import qualified Data.Map as M
import Control.Monad.Except
import Control.Monad.Reader

type Env = M.Map String LispVal
type EvalM = ExceptT LispError (ReaderT Env IO)

data LispError = UnboundVar String | TypeError String | NumArgs Int [LispVal]
               deriving (Show, Eq)

data Procedure = Procedure [String] LispVal Env
instance Show Procedure where show _ = "#<procedure>"

data LispVal = Atom String | Number Integer | Bool Bool | List [LispVal] 
             | Proc Procedure | Builtin ([LispVal] -> EvalM LispVal)

instance Eq LispVal where
    (Atom a)   == (Atom b)   = a == b
    (Number a) == (Number b) = a == b
    (Bool a)   == (Bool b)   = a == b
    (List a)   == (List b)   = a == b
    _          == _          = False

instance Show LispVal where
    show (Atom s)     = s
    show (Number n)   = show n
    show (Bool True)  = "#t"
    show (Bool False) = "#f"
    show (List xs)    = "(" ++ unwords (map show xs) ++ ")"
    show (Proc _)     = "#<procedure>"
    show (Builtin _)  = "#<builtin>"
