module Parser (parseExpr, LispVal(..)) where

import Text.Parsec
import Text.Parsec.String (Parser)
import Text.Read (readMaybe)
import Types (LispVal(..))

parseBool :: Parser LispVal
parseBool = char '#' >> ((char 't' >> return (Bool True)) <|> (char 'f' >> return (Bool False)))

parseNumber :: Parser LispVal
parseNumber = do
    sign <- optionMaybe (char '-')
    digits <- many1 digit
    let numStr = maybe "" (const "-") sign ++ digits
    case readMaybe numStr of
        Just n  -> return $ Number n
        Nothing -> fail $ "Invalid number: " ++ numStr

parseAtom :: Parser LispVal
parseAtom = try parseNumber <|> do
    first <- letter <|> oneOf "!$%&|*+-/:<=>?@^_~"
    rest <- many (alphaNum <|> oneOf "!$%&|*+-/:<=>?@^_~")
    return $ Atom (first:rest)

parseList :: Parser LispVal
parseList = List <$> between (char '(' >> spaces) (char ')' >> spaces) 
                             (parseExpr `sepEndBy` spaces)

parseExpr :: Parser LispVal
parseExpr = spaces >> (parseBool <|> parseAtom <|> parseList)
