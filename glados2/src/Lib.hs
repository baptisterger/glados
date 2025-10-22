module Lib
  ( parseFile
  , parseStringToAST
  , hasMain
  ) where

import Text.Parsec
import Text.Parsec.String (Parser)
import Text.Parsec.Expr
import Control.Monad (void)
import Data.Functor.Identity (Identity)
import System.IO

import Ast
  ( Program(..)
  , TopLevelDecl(..)
  , Type(..)
  , Param(..)
  , Stmt(..)
  , Expr(..)
  )

spaceChar :: Parser ()
spaceChar = void $ oneOf " \t\r\n"

lineComment :: Parser ()
lineComment = try (string "//" >> void (manyTill anyChar (void newline <|> eof)))

spacesOrComments :: Parser ()
spacesOrComments = skipMany (spaceChar <|> lineComment)

lexeme :: Parser a -> Parser a
lexeme p = p <* spacesOrComments

symbol :: String -> Parser String
symbol = lexeme . string

parens :: Parser a -> Parser a
parens = between (symbol "(") (symbol ")")

braces :: Parser a -> Parser a
braces = between (symbol "{") (symbol "}")

commaSep :: Parser a -> Parser [a]
commaSep p = sepBy p (symbol ",")

reservedWords :: [String]
reservedWords =
  [ "skibidi", "if", "else", "while", "return"
  , "int", "float", "bool"
  , "true", "false"
  ]

identifier :: Parser String
identifier = lexeme $ try $ do
  first <- letter <|> char '_'
  rest <- many (alphaNum <|> char '_')
  let name = first:rest
  if name `elem` reservedWords
    then unexpected ("reserved word " ++ show name)
    else return name

nameAllowed :: Parser String
nameAllowed = lexeme $ try $ do
  first <- letter <|> char '_'
  rest <- many (alphaNum <|> char '_')
  return (first:rest)

pInt :: Parser Expr
pInt = lexeme $ try $ do
  sign <- optionMaybe (char '-')
  ds <- many1 digit
  notFollowedBy (char '.' <|> alphaNum <|> char '_')
  let n = read ds :: Int
  return $ IntConst (case sign of Just _ -> -n; Nothing -> n)

pFloat :: Parser Expr
pFloat = lexeme $ try $ do
  sign <- optionMaybe (char '-')
  intPart <- many1 digit
  _ <- char '.'
  frac <- many1 digit
  notFollowedBy (alphaNum <|> char '_')
  let s = intPart ++ "." ++ frac
  let f = read s :: Float
  return $ FloatConst (case sign of Just _ -> -f; Nothing -> f)

pBool :: Parser Expr
pBool = lexeme $ try $ do
  b <- (string "true" >> return True) <|> (string "false" >> return False)
  notFollowedBy alphaNum
  return $ BoolConst b

operator :: String -> Parser String
operator op = lexeme (try (string op))

pCall :: Parser Expr
pCall = try $ do
  nm <- nameAllowed
  args <- parens (commaSep pExpr)
  return $ Call nm args

pVar :: Parser Expr
pVar = Var <$> identifier

pTerm :: Parser Expr
pTerm =
      try pFloat
  <|> try pInt
  <|> try pBool
  <|> try pCall
  <|> try pVar
  <|> parens pExpr

binary name assoc = Infix (operator name >> return (\a b -> BinOp name a b)) assoc

assignOp :: Operator String () Identity Expr
assignOp = Infix (operator "=" >> return assignHandler) AssocRight
  where
    assignHandler a b = case a of
      Var v -> Assign v b
      _     -> error "assignment LHS must be a variable"

operatorTable :: [[Operator String () Identity Expr]]
operatorTable =
  [ [binary "*" AssocLeft, binary "/" AssocLeft]
  , [binary "+" AssocLeft, binary "-" AssocLeft]
  , [binary "==" AssocNone, binary "!=" AssocNone, binary "<" AssocNone, binary ">" AssocNone, binary "<=" AssocNone, binary ">=" AssocNone]
  , [assignOp]
  ]

pExpr :: Parser Expr
pExpr = buildExpressionParser operatorTable pTerm

pType :: Parser Type
pType = lexeme $ try $ (string "int" >> return TypeInt)
                   <|> (string "float" >> return TypeFloat)
                   <|> (string "bool" >> return TypeBool)

pParam :: Parser Param
pParam = do
  ty <- pType
  name <- identifier
  return $ Param ty name

pVarDecl :: Parser Stmt
pVarDecl = try $ do
  ty <- pType
  name <- identifier
  _ <- operator "="
  e <- pExpr
  _ <- lexeme (char ';')
  return $ StmtVarDecl ty name e

pStmtExpr :: Parser Stmt
pStmtExpr = do
  e <- pExpr
  _ <- lexeme (char ';')
  return $ StmtExpr e

pIf :: Parser Stmt
pIf = do
  _ <- lexeme (string "if")
  cond <- parens pExpr
  thenBlock <- pBlock
  elseBlock <- optionMaybe (lexeme (string "else") >> pBlock)
  return $ StmtIf cond thenBlock elseBlock

pWhile :: Parser Stmt
pWhile = do
  _ <- lexeme (string "while")
  cond <- parens pExpr
  body <- pBlock
  return $ StmtWhile cond body

pReturn :: Parser Stmt
pReturn = do
  _ <- lexeme (string "return")
  me <- optionMaybe pExpr
  _ <- lexeme (char ';')
  return $ StmtReturn me

pStmt :: Parser Stmt
pStmt = try pVarDecl
    <|> try pIf
    <|> try pWhile
    <|> try pReturn
    <|> pStmtExpr

pBlock :: Parser [Stmt]
pBlock = braces (many pStmt)

pFuncDecl :: Parser TopLevelDecl
pFuncDecl = do
  (void (lexeme (string "skibidi")) <|> void (lexeme (string "fun")) <|> return ())
  name <- nameAllowed
  _ <- symbol "("
  params <- commaSep pParam
  _ <- symbol ")"
  body <- pBlock
  return $ FuncDecl name params body

pGlobalVarDecl :: Parser TopLevelDecl
pGlobalVarDecl = do
  ty <- pType
  name <- identifier
  _ <- operator "="
  e <- pExpr
  _ <- lexeme (char ';')
  return $ GlobalVarDecl ty name e

pTopLevel :: Parser TopLevelDecl
pTopLevel = try pFuncDecl <|> pGlobalVarDecl

pProgram :: Parser Program
pProgram = spacesOrComments *> (Program <$> many pTopLevel) <* eof

parseStringToAST :: String -> Either ParseError Program
parseStringToAST = parse pProgram "<input>"

parseFile :: FilePath -> IO ()
parseFile filename = do
  content <- readFile filename
  case parseStringToAST content of
    Left err -> putStrLn $ "Parse error: " ++ show err
    Right prog -> do
      print prog
      if hasMain prog then putStrLn "Found main" else putStrLn "No main function found"

hasMain :: Program -> Bool
hasMain (Program decls) = any isMain decls
  where
    isMain (FuncDecl name _ _) = name == "main"
    isMain _ = False
