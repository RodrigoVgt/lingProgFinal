module Interpreter where 

import Lexer 
import Parser

isValue :: Expr -> Bool 
isValue BTrue = True 
isValue BFalse = True
isValue (Num _) = True 
isValue (Lam _ _ _) = True
isValue _ = False 

subst :: String -> Expr -> Expr -> Expr 
subst x n (Var v) = if (x == v) then
                      n 
                    else 
                      (Var v)
subst x n (Lam v t b) = Lam v t (subst x n b)
subst x n (App e1 e2) = App (subst x n e1) (subst x n e2)
subst x n (Add e1 e2) = Add (subst x n e1) (subst x n e2)
subst x n (And e1 e2) = And (subst x n e1) (subst x n e2)
subst x n (If e1 e2 e3) = If (subst x n e1) (subst x n e2) (subst x n e3)
subst x n (Paren e) = Paren (subst x n e)
subst x n (Let v e1 e2) = Let v (subst x n e1) (subst x n e2)
subst x n e = e 

step :: Expr -> Expr 
step (Add (Num n1) (Num n2)) = Num (n1 + n2)
step (Add (Num n) e) = Add (Num n) (step e)
step (Add e1 e2) = Add (step e1) e2 
step (Sub (Num n1) (Num n2)) = Num (n1 - n2)
step (Sub (Num n) e) = Sub (Num n) (step e)
step (Sub e1 e2) = Sub (step e1) e2 
step (And BFalse _) = BFalse 
step (And BTrue e) = e 
step (And e1 e2) = And (step e1) e2 
step (Or BTrue _) = BTrue
step (Or BFalse e) = e
step (Or e1 e2) = Or (step e1) e2
step (If BFalse e1 e2) = e2 
step (If BTrue e1 e2) = e1 
step (If e e1 e2) = If (step e) e1 e2 
step (Paren e) = e
step (App (Lam x t b) e2) | isValue e2 = subst x e2 b 
                        | otherwise = (App (Lam x t b) (step e2))
step (App e1 e2) = App (step e1) e2
step (Let v e1 e2) | isValue e1 = subst v e1 e2 
                   | otherwise = Let v (step e1) e2

step (Gt (Num n1) (Num n2)) = if (n1 > n2) then
                                    BTrue 
                                  else 
                                    BFalse
step (Gt (Num n1) e) = Gt (Num n1) (step e)
step (Gt e1 e2) = Gt (step e1) e2
step (St (Num n1) (Num n2)) = if (n1 < n2) then
                                    BTrue 
                                  else 
                                    BFalse
step (St (Num n1) e) = St (Num n1) (step e)
step (St e1 e2) = St (step e1) e2
step (Ternary (Num n) e2 e3) = if n /= 0 then e2 else e3
step (Ternary BTrue e _) = e
step (Ternary BFalse _ e) = e
step (Ternary e1 e2 e3) = Ternary (step e1) e2 e3
step e = error (show e)

eval :: Expr -> Expr 
eval e | isValue e = e 
       | otherwise = eval (step e)