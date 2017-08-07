---
layout: page
---

# Style Guide

## Why?

Watt is Volt's standard library. While it is hoped that there are many libraries written by many people that are widely available, the importance of the library that is always available cannot be understated. Every other piece of code is written with the capabilities and style of the standard library in mind. In addition, languages and standard libraries are criticised as a single unit; as always, leaving a good impression is important.

With that in mind we have produced this document to guide the design of Watt's modules. These are guidelines, not rules. However, if there is an egregious break, bug reports and patches are most welcome.

## Formatting

There is no need to go in depth here, as looking at any of the existing modules should tell you everything you need to know. Emulate their style. Briefly, then: hard tabs indentation, opening braces for function bodies and aggregates go on a new line, otherwise they go on the same line as the statement keyword (`if`, `while`, etc). Spaces precede parens in statements, but not in casts and functions. The following code example is provided as an illustration.

    class Class
    {
        fn aFunction(n: i32) i32
        {
            if (n > 3) {
                return cast(i32)pow(n, 2);
            }
            return n + 2;
        }
    }

## Organisation

The two main units of organisation to keep in mind are the module and the package. Modules should be potentially useful without needing support from another module in the same package to work. Use packages liberally. Every module in a package should be related somehow.

For example, a file parsing package might have a module for reading and a module for writing its file type. Be sure to make use of package modules if you think all the modules will be commonly used at the same time.

## Naming

Use English for naming things (British, if it comes up). Use a spellchecker. That goes for comments too -- they should use correct punctuation and spelling.

Top level types, like `class`es, `enum`s, `struct`s, and so on, should start with an uppercase letter, and be a noun. `InputFile` is okay. `inputFile`,  or `FileRead` is not. 

Functions should be verbs, and start with a lower case letter. Be as specific as possible. Avoid vague verbs like `do` or `handle` where possible. Not `handleXml`, but `parseXml`.

Functions that start with the verb 'get' should not mutate the object they're associated with.

Avoid anything resembling Hungarian typing. In particular, don't start interfaces with an 'I' (e.g. 'IDisplay'), and they don't need the word 'Interface' in them (although they can if that works best).

## Comments

Every public facing function and type should be documented with a DocComment. As far as code explanatory comments, use when needed, but not to excess.

## Specific Code Points

Every time you write ~=, a Swedish angel loses its wings. Use `watt.text.sink.StringSink`.
