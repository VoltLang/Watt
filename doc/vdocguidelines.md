# VDoc Style Guide

Volt, by default, provides you with VDoc for automatic documentation generation. VDoc is an unholy combination of doxygen and markdown. This document won't get into the details of either; see the existing documentation for real world examples. What we're concerned with here is consitency amongst official Volt projects. Independent projects can follow these, but are certainly under no compulsion to do so.

The biggest source of comments will be Watt, so most of this document will be written with that in mind. Let's break it all down!

## Document What Needs To Be Documented, But No More Than That

This may sound a little vague. When writing a module for Watt, the documentation is primarily for someone unfamiliar with the module. Anything that an external user would want to know should be covered, and they should not be required to read the source code to discover how to use it, or the particulars of a given function.

At the same time, don't put useless information into the documentation. Don't use documentation comments (`/*!` or `//!`) on private members or implementation details. These can be documented with regular comments, but the VDoc comments should be for things that are needed to use the module.

Always try and think about what kind of questions someone unfamiliar with the module might have, and answer them. For example, if you have a path handling function that takes an 'extension' parameter, does it include the '.' in the string they give, or is it added automatically? These kind of details are often well with examples, which segues nicely into the next point.

## Use Examples

If a function is complicated, or even if it isn't, one of the most useful forms of documentation can be a few simple examples. Use markdown's headings to denote these, and then place a codeblock after that heading:

    ### Examples
        doubleOpposite(32, "cat");  // Returns "64 dog"
        doubleOpposite(6, "red");   // Returns "12 blue"

The heading should always be "Examples", (or "Example" if there is only one), and always use third level headings. Don't over do examples, but don't be afraid to add them. Use your best judgement.

## Documentation Is At Least A Brief Or Return Documentation

The shortest form of acceptable documentation (other than none) is a single sentence that describes what a function does. If this is all the documentation is, then use of single line comments is acceptable.

    //! Double an integer and get the opposite of a word.

For simple query functions, you can often get away with no brief; just an `@returns` command.

    //! @returns `true` if gravity applies to this object.
    fn isAffectedByGravity() bool { ...

If there is additional documentation, use a block comment (`/*!`) and the additional content doesn't come in the form of doxygen commands (`@return`, `@throw`, etc), end the first sentence line with two trailing spaces and continue writing on the next line.

    /*!
     * Double an integer and get the opposite of a word.  
     * The word must be a simple English word, and the integer less than `834`.
     */

This forces a hard linebreak and stops the entire comment from running together into some eldritch monstrosity. Write as many paragraphs as is needed (using double spaces as above to insert linebreaks as appropriate). Then show any examples you want to, as demonstrated in the last section. After that, document side effects (`@SideEffects`), parameters (`@param`), return types (`@returns`), then throws (`@throws`), in that order.

    /*!
     * Double an integer and get the opposite of a word.  
     * The word must be a simple English word, and the integer less than `834`.
     * ### Examples
     *    doubleOpposite(32, "cat");  // Returns "64 dog"
     *    doubleOpposite(6, "red");   // Returns "12 blue"
     * @SideEffects Minor bleeding.
     * @Param i The integer to double.
     * @Param word The word to make opposite.
     * @Returns A string formatted with the integer and word separated by
     * a single space.
     * @Throws A `ThisIntegerIsTooBigToDoubleException` if `i` is greater than `834`.
     */

## Documentation Is Made Of Sentences, And Sentences Start With A Capital And End With A Full Stop

This one sounds simple, and it is. Documentation is a series of sentences, and sentences follow the standard English form. In particular, this includes after commands.

    @param i An integer to double.
    @returns A mysterious value.

There is never an exception to ending with a fullstop, but there is one exception to capital letters starting a sentence, and that's if the sentence starts with an inline code word. (Which includes all references to other functions and types, and all literals).

    @returns `true` if you're cool, `false` otherwise.

Speaking of...

## All Literals, Functions, and Types Are Wrapped In Backticks

In Markdown, if you \`wrap\` a word in backticks, it gets turned into a `<code>` block, and uses a fixed width font. Any reference to a parameter, a literal (`true`, `32`, `"hello"`, etc), another function/type etc ("calls `exit`") will use this.

## Use Correct Grammar And Spelling

Try your best, at least. Prefer British English spelling/grammar where possible, for uniformity with the rest of Volt.

## Assorted Tips

- Don't restate the type of a thing in the comment documenting that thing.