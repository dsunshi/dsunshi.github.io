---
title: RAM/ROM Optimization
description: Detailed ideas for intensive RAM/ROM optimization for embedded devices
date: 2025-08-10 18:00:00 -0500
categories: [C]
tags: [ram, rom, c]
---

# RAM/ROM Optimization Theories

This article is meant to list some more advanced or unusual methods for finding and optimizing RAM and ROM usage in embedded C projects.

## "Oversized" ROM data

Since in C we must declare the data type it is possible to "oversize" the data. For example if we declare the type as
`int`, but the value of the data is always less than 255 (i.e. where '`char`' would suffice), then we are losing 3 bytes per
variable. While this may not sound like much, for large projects with large data tables or data structures this can quickly amount to
kilobytes of storage.

To find such oversized ROM data we need a few inputs:
* the size and address of variables - this can normally be found in the generated MAP file
* the compiled binary file

The pseudo code is as simple as:
```
for each variable (from the map file):
    read it from the compiled binary
    compute the % of bytes in the raw data are equal to 0x00
```

### Interpreting the Results

If more that 50% of a variable stored in the binary file is 0x00, than this problem exists. It **can also** exist for
variables that are less that 50% if they are structures, where not all elements have this problem. For example:
```c
struct
{
   unsigned int too_big;
   unsigned int correct;
   unsigned char also_ok;
};
```
For this structure if only `too_big` is improperly sized the overall result will be less than 50%. Therefore cases with
less than 50% have to be manually checked. This will of course depend on how many instances of the structure there are.

## const v. #define

This hint is compiler specific, but is also a simple test. In an ideal world any variables that are declared as `const` should
not be present in the binary (at least not more than absolutely necessary). However, it is possible that changing `const`
variables to `#defines` will result in a different binary.

Personally, I have seen a project that used auto-generated code that had several hundred `const` variables all with the value of
`0`. Changing these from `unsigned char` to `#define` saved over 1kb of ROM. And yes every possible optimization for
ROM saving was already set (in conjunction with application engineers from the compiler's company).

The moral of the story is to try it, and see what happens - the answer may surprise you.

## Array Initialization

A second example of how different compilers will generate different code (even with the "correct" optimization setting).

The code
```c
unsigned char x[1024] = {0};
```
should allocate 1kb of RAM, and should *hopefully* be optimized do a `memset` call (to reduce ROM). This may not always
be the case. And if this pattern is used inside functions to initialize variables than the same data in ROM can be
needlessly repeated.

## Finding "repeated" ROM data

This is another possibility for large projects with large amounts of auto-generated code. In these types of projects it
is not uncomment to have large "tables" of configuration values:
```c
unsigned int register_configuration[100] = {
  0xDEADBEEF,
  0xDEADBEEF,
  0xDEADBEEF,
  0xDEADBEEF,
  0xDEADBEEF,
  ...
  0xCAFEBEEF,
};
```
In these cases the tables can be very large, but the number of unique values can be relatively small, i.e. a table with
100 values may only have 3 unique settings.

For this case we can create a second look up table of only the unique values:
```c
unsigned int register_configuration_unique[100] = {
  0xDEADBEEF,
  0xCAFEBEEF,
};
```
and the original tables then becomes:
```c
unsigned char register_configuration[100] = {
  0,
  0,
  0,
  0,
  0,
  ...
  1,
};
```
and accessing the variables is finally:
```c
register_configuration_unique[register_configuratino[ORIGINAL_INDEX]];
```

This will save space equal to: $number of duplicates * reduced variable size - sizeof(new lookup table)$
where:
* $number of duplicates$  = the number of duplicate items in the original table
* $reduced variable size$ = the size difference in bytes between the original datatype and the size required to store
    just an offset.

## Are all NULL pointer checks necessary?

If NULL pointers can be avoided or verified at run time, they may not be required. This can save significant space if
they are present in macros or in `inline` functions.

## Are all static variables inside functions necessary?

If there are unused `static` variables inside functions this can waste significant amounts of RAM. This can be from
things marked incorrectly as `static` of from legacy code that was not deleted.

Normally `static` variables have a special name or marker in a MAP file since they are not globally visible.

**Generally** the only use for a `static` variable inside a c-function is to act as a counter, therefore if the map
file shows any `static` functions larger than `sizof(unsigned int)` this is definitely a place worth investigating.

## Searching for unused structure variables

It is *somewhat* possible to search for unused structure variables. This is not normally something a complier is able
to generate a warning for. However it is possible to create a rough estimate with minimal effort:
1. Use `ctags` to generate a list of variable names
2. Use `GNU Global` to count variable references

Cross referencing these two lists will generate a list of variables that have no reference. This is not 100% accurate
because c allows so many various ways to read/write to variables, but the results are usually at least 80% accurate.

## Are padding bytes (for alignment) needed?

Sometimes out of habit (or lack of understanding) `stuct`s can be marked for padding when not absolutely needed. If the
code does not specifically require padding, than this is an easy space saver.

### Manual padding v. compiler padding

Further to the point of padding, it can be added by the compiler. However if padding has been manually specified by a
directive in the code it is *possible* that the same exact variable can be padded again when the compile option takes
effect. This is compiler dependent.

## Duplicate or redundant ROM data

When using third party code or simply a large enough project there is the possibility that code is redundant. For
example a CRC calculation that uses a look up table in two different parts of the code - one implemented by a third
party library - and the other by the application project.

Finding these issues is relatively straight forward. Simply read out all of the variables from the binary (as specified
in the MAP file) and compare them to one another.

