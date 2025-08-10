---
title: Reading Motorola S-records with Haskell
description: Initial steps to parsing and reading Motorola S-records using Haskell
date: 2025-07-30 10:00:00 -0500
categories: [Haskell]
tags: [haskell, srec, parsing]
---

# Brief introduction to S-record format

A wonderful and detailed description of the full SREC format is available on [Wikipedia](https://en.wikipedia.org/wiki/SREC_(file_format)).

A summary of the record structure is:

| S | Type | Byte Count | Address | Data | Checksum |
| --- | --- | --- | --- | --- | --- |
| Record start - "S" | Record Type - "0" to "9" | Byte Count - **two** *hex* bytes indicating the number of bytes that follow (address + data + checksum) | Address - four, six or eight big-endian hex bytes | Data - 2*n* hex digits | Checksum - **two** hex digits |

## Calculating the checksum

This is also a simplified version of the full [Wikipedia example](https://en.wikipedia.org/wiki/SREC_(file_format)#Checksum_calculation):
  1. Sum all of the bytes in the Byte Count, Address, and Data fields.
  2. Discard the most significant byte.
  3. Subtract the least significant byte of the sum from 255.

```haskell
import Data.Bits
import Data.Char
import Data.List.Split

-- Give Int the name Byte, i.e. typedef or #define in c
type Byte = Int

-- Take a String containing the byte count, address and data fields and calculate the srec checksum
checksum' :: String -> Byte
checksum' bytes = 0xFF - (sumBytes bytes .&. 0xFF)

-- 1. Split the string into chunks of 2
-- 2. Parse each hex byte from a String to a Byte
-- 3. Sum the results
sumBytes :: String -> Byte
sumBytes = sum . map parseByte . chunksOf 2

-- Note: parseByte of an empty list returns -1, this is a *bit* of a hack to ensure that
-- the checksum comparision will fail when given an empty string ("") and a string with an
-- odd number of digits ("FFF").
parseByte :: String -> Byte
parseByte [msb, lsb] = digitToInt msb * 16 + digitToInt lsb
parseByte []         = -1
parseByte _          = 0

splitChecksum :: String -> (String, String)
splitChecksum raw = splitAt count raw
  where
    -- The 'Byte Count field is the first to char of the S-record (take 2)
    -- count is the number of two hex digits (2 *).
    count = 2 * sumBytes (take 2 raw)

compareChecksum :: (String, String) -> Bool
compareChecksum (bytes, checksum) = parseByte checksum == checksum' bytes

-- Drop 2 since the type of Srec is not relevant
validateChecksum :: String -> Bool
validateChecksum = compareChecksum . splitChecksum . drop 2

prettyValid :: Bool -> String
prettyValid True = "valid"
prettyValid False = "invalid"

testChecksum :: IO ()
testChecksum = 
  let
    input = "S00F000068656C6C6F202020202000003C"
    valid = validateChecksum input
  in
    putStrLn ("Checksum is: " ++ prettyValid valid)

```
