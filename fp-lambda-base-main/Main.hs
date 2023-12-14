module Main where

import Lexer 
import Parser
import TypeChecker
import Interpreter

main :: IO ()
main = do
    contents <- readFile "code.mylang"
    print . eval . typecheck . parser . lexer $ contents