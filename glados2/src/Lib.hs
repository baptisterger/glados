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