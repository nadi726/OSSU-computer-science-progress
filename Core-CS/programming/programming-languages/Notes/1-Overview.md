A programming language is an interface to interacting with a computer. There are many different programming languages, and so there are many different interfaces. Why do we need so much? because the perfect programming language doesn't exits. Different programming languages make different design decisions, and each decision has drawbacks, which makes it impossible to have one tool that is the best at all different programming tasks. 
# The pieces of a programming language
It is important to study the concepts that are at the core of programming languages, because it allows us to understand programming on a deeper level.

Each programming language has 5 essential pieces for defining and learning it:
1. Syntax - how to write things in the language
2. Semantics - what do the various parts of the language mean and how they fit together
3. Idioms - what are the common approaches to using language features to express computations
4. Libraries - what code is already given to you, including operations that can only be achieved by libraries, like writing to files
5. Tools - various ways to manipulate and view programs in the language, like compiler, debugger and REPL.

In this course we focus on 2 kinds of concepts: semantics and idioms
1. Semantics - This is very important, because interacting with the computer is all about precise definitions. Only by understanding the constructs we can use them correctly
2. Idioms - They allow us to adopt a certain way of thinking about programs, and thus, seeing them in action and in different contexts enhances our skill as programmers overall.
# main topics
Most of the course focuses on functional programming, instead of the more popular object-oriented programming.
Why? because functional programming offers a great way to think about computation and enforce good coding practices, even outside of a FP-language domain. But also because FP has always been ahead of its time, and as time passes it transitions from a niche paradigm advocated by dusty old computer science professors into the mainstream of programming. This happens in 2 ways: some modern FP languages are well-used in the industry(like Clojure), and major programming languages integrate more-and-more functional features as core language features.

The 2 main topics of the course are: Functional vs. OOP programming, statically typed vs. dynamically typed languages.
Those are 2 important and orthogonal topics, and seeing how they intersect with each other will give us great insight about them.

|                     | dynamically typed | statically typed |
| ------------------- | ----------------- | ---------------- |
| **functional**      | Racket            | SML              |
| **object-oriented** | Ruby              | Java/C#/Dart     |
We study 3 languages (SML, racket and ruby), which cover 3 of the 4 grids. due to how long the course already is, we really are missing a 4th one - a statically typed OOP language. We will still study about OOP concepts in a statically typed setting, but we don't go about it as deeply and won't be able to apply them directly during the course. the bright side is that those languages are well-known, and using what we'll learn it isn't hard to complete the picture.