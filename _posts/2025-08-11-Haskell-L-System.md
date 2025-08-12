---
title: Simple L-Systems in Haskell
description: A basic text-based L-System in Haskell based on a Coding Train episode
date: 2025-08-11 19:00:00 -0500
categories: [Haskell]
tags: [haskell, l-system]
---

# Inspiration

This article is based on Daniel Shiffman's coding challenge on YouTube: [Coding Challenge #16: L-System Fractal Trees](https://www.youtube.com/watch?v=E1B4UoSQMFw).

## Simple L-Systems in Haskell

The following Haskell implementation is based on the original L-System example from the video linked above:

Axiom: "A"

Rules:
 - A -> AB
 - B -> A

```haskell

import Data.Maybe

type Rule = (Char, String)

-- Rules for the L-System
-- A -> AB
-- B -> A
myRules :: [Rule]
myRules =
  [ ('A', "AB"),
    ('B', "A")
  ]

-- Take a given character and set of rules, if the character is found in the rules
-- the corresponding replacement String is returned.
-- Otherwise return the original input character as a String.
applyRule :: [Rule] -> Char -> String
applyRule rules c = fromMaybe [c] $ lookup c rules

-- Apply the rules to each character in the original axiom
apply :: [Rule] -> String -> String
apply rules = concatMap (applyRule rules)

-- Show the first 5 iterations of running apply on the axiom "A"
main :: IO ()
main = print $ take 5 $ iterate (apply myRules) "A"
```

