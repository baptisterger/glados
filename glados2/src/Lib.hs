module Lib
    ( someFunc
    , parseFile
    , Token(..)
    , parseTokens
    ) where

import Text.Parsec
import Text.Parsec.String (Parser)
import System.Environment

data Token = 
    IntLit Int
  | FloatLit Float
  | BoolLit Bool
  | Identifier String
  | Keyword String
  | Operator String
  | Delimiter Char
  | Symbol String
  deriving (Show, Eq)

skipSpaces :: Parser ()
skipSpaces = skipMany (space <|> (comment >> return ' '))
  where
    comment = do
      _ <- string "//"
      _ <- manyTill anyChar (char '\n')
      return ()

parseInt :: Parser Token
parseInt = do
  sign <- optionMaybe (char '-')
  digits <- many1 digit
  notFollowedBy (char '.' <|> alphaNum)
  let num = read digits :: Int
  return $ IntLit (case sign of
    Just _ -> -num
    Nothing -> num)

parseFloat :: Parser Token
parseFloat = do
  sign <- optionMaybe (char '-')
  intPart <- many1 digit
  _ <- char '.'
  fracPart <- many1 digit
  notFollowedBy alphaNum
  let floatStr = intPart ++ "." ++ fracPart
  let num = read floatStr :: Float
  return $ FloatLit (case sign of
    Just _ -> -num
    Nothing -> num)

parseWord :: Parser Token
parseWord = do
  word <- many1 (alphaNum <|> char '_')
  notFollowedBy (alphaNum <|> char '_')
  return $ case word of
    "true" -> BoolLit True
    "false" -> BoolLit False
    "skibidi" -> Keyword word
    "main" -> Keyword word
    "float" -> Keyword word
    "int" -> Keyword word
    "bool" -> Keyword word
    "if" -> Keyword word
    "else" -> Keyword word
    "print" -> Keyword word
    _ -> Identifier word

parseOperator :: Parser Token
parseOperator = do
  op <- choice
    [ try (string "==")
    , try (string "!=")
    , try (string "<=")
    , try (string ">=")
    , string "+"
    , string "-"
    , string "*"
    , string "/"
    , string "="
    , string "<"
    , string ">"
    ]
  return $ Operator op

parseDelimiter :: Parser Token
parseDelimiter = do
  delim <- oneOf "(){}[];,"
  return $ Delimiter delim

parseToken :: Parser Token
parseToken = 
  try parseFloat <|>
  try parseInt <|>
  try parseWord <|>
  try parseOperator <|>
  parseDelimiter

parseTokens :: Parser [Token]
parseTokens = do
  skipSpaces
  tokens <- sepEndBy parseToken skipSpaces
  eof
  return tokens

parseFile :: String -> IO ()
parseFile filename = do
  content <- readFile filename
  case parse parseTokens filename content of
    Left err -> print err
    Right tokens -> mapM_ print tokens

someFunc :: IO ()
someFunc = do
  args <- getArgs
  case args of
    [filename] -> parseFile filename
    [] -> do
      putStrLn "Reading from stdin..."
      content <- getContents
      case parse parseTokens "stdin" content of
        Left err -> print err
        Right tokens -> mapM_ print tokens
    _ -> putStrLn "Usage: program [filename] or use redirection"