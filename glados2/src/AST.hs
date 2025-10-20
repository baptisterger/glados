data Program = Program [TopLevelDecl]
  deriving (Show, Eq)

data TopLevelDecl
  = FuncDecl String [Param] [Stmt]
  | GlobalVarDecl Type String Expr
  deriving (Show, Eq)

data Type = TypeInt | TypeFloat | TypeBool
  deriving (Show, Eq)

data Param = Param Type String
  deriving (Show, Eq)

data Stmt
  = StmtExpr Expr
  | StmtVarDecl Type String Expr
  | StmtIf Expr [Stmt] (Maybe [Stmt])
  | StmtWhile Expr [Stmt]
  | StmtReturn (Maybe Expr)
  deriving (Show, Eq)

data Expr
  = IntConst Int
  | FloatConst Float
  | BoolConst Bool
  | Var String
  | BinOp String Expr Expr
  | Assign String Expr
  | Call String [Expr]
  deriving (Show, Eq)
