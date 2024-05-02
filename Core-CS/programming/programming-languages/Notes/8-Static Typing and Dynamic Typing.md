We've seen 2 languages so far - SML and Racket.
There are many differences and similarities between the two.
The most prominent difference is that SML has a Static Type System and while Racket doesn't.

Having a type system means that SML rejects certain programs that Racket accepts. It is designed in such a way that those programs are mostly programs with bugs or other kinds of problems we'd like to prevent, like misuse of language features. A type system checks for those at compile-time(or before), while with Dynamic Typing, we'd often have no way of telling what's wrong until something bad happens.
However, there are also perfectly fine programs which the type system rejects, like this Racket code:
```scheme
(define (f x) (if (> x 0) #t (list 1 2)))
(define xs (list 1 #t "hi"))
(define y (f (car xs)))
```
# SML and Racket
We can actually consider, in relation to having a type system, SML and Racket in terms of each other.

SML can be thought of as a subset of racket in which every SML program is a perfectly fine Racket program, but the opposite is not always true.
Racket can be thought of as SML with one big datatype which contains every datatype in use. Every value is implicitly wrapped with the appropriate constructors of that datatype.
Every construct which accepts certain datatypes can be taught of as having one big pattern-matching where the appropriate values are matched and everything else throws an exception.
The only difference would be Racket's structs, which allow dynamically adding constructors to the datatype.
Overall, this thought experiment shows that SML programs **could** write the same code as Racket does, even for the would-be-rejected programs - just that this style of coding in SML would be awkward and inconvenient.
# Static checking
Static checking means anything done to reject a program after parsing and before execution.
It is part of the language definition, although there exists various tools that perform different kinds of static checks before running the program, independent of the checks specified by the language itself - such as type hinting tools in python.

Usually static checking is defined using a *type system*.
A type system is a set of rules describing the appropriate types for all of the language constructs. Failure to adhere to those rules results in an error at compile-time, or any other stage before runtime, and the program is rejected.

There's a range of possible stages for possibly rejecting such a program - from when we type the wrong code, to compile time, run time or even later - by only returning an error once such a wrong computation is used where some behaviour is expected.
# Soundness and completeness
What kinds of programs are considered correct by a type system can be described in terms of two related concepts: *Soundness* and *completeness*.
*Soundness* and *completeness* are terms from formal logic for describing the kinds of things provable in a proof system.
*Soundness* means that everything that is provable is also true.
*Completeness* means that everything true is provable.
In the case of programming languages, a type system is *sound* if it rejects all programs that it considers wrong by definition, and it is *complete* if it rejects **only** those programs.

It turns out, and it can be proven mathematically, that the three following conditions cannot be satisfied at once for a type system that rejects the things we actually care about rejecting:
1. it is Sound
2. It is complete
3. The program always terminate

Given this choice, type systems are always designed in such a way that they are sound and that programs always terminate, meaning that there is at least *some* degree of incompleteness. Thankfully, modern languages are designed in such way that the restriction placed upon the programmer by this incompleteness is minimal.

This is an example, and also probably the most important ramification, of the idea of undecidability at the heart of the theory of computation(think of the famous *Halting problem*).

# Strong and Weak typing
What should happen once a wrong behaviour is occurring at runtime, either because it slipped past the type system or because there is no type system, is another consideration a language must take.

There are 2 possible approaches here:
one is to continue as usual until something bad happens, like the program accessing memory it shouldn't and causing security risks, and the other is to dynamically check for such errors and stop the program when they happen.
The first approach is called *Weak typing*, and the second is *Strong typing*.
Most modern languages are *Strongly typed*, and for good reasons - weak typing is often too risky and error-prone.

The most famous example of *weakly-typed* languages in use today are C and C++. It makes sense for them, as they are designed as lower-level languages with no overhead, and the checks required by *Strong typing* causes some performance and (more-so) memory overhead.

In general, through, weak typing makes a language more flexible, at the cost of introducing more potential bugs.
It should be noted that this is a separate issue from Static vs Dynamic typing, although it tends to be confused with it. Racket is one example of a language that is both Dynamically typed and Strongly typed - it just checks for errors at runtime.

Another thing that gets confused here has to do with more flexible evaluation rules for a language.
For example, whether accessing a non-existent array element should raise an error or just return some value, like null, is a design decision unrelated to Dynamic typing. 
It has the same general trade-off of more flexibility vs more potential for undetected bugs, but in this case we choose to **define** our language in such a way to allow for such behaviour - instead of choosing to prevent *X*, either at compile-time or at run-time, we choose to define *X* as legal behaviour.

# Static versus Dynamic typing
Which is better, Static or Dynamic typing?
Frankly, there's not a one sided answer - its a game of trade-offs.
Whether you should use Static or Dynamic typing in a particular case is dependant on your needs - what kind of code you're writing, what is the specification etc.
Instead, we'll discuss several aspects in favour of each.

## Which is more convenient
Dynamic typing is more convenient because it allows us to mix different types without having to worry about defining a new datatype for doing so.

On the other hand, Static typing is more convenient in that it allows us to assume the types we're getting are what we want - for example, if a function is taking an int as an argument, then it knows that every call to it would give an int. Thus we don't have to resort to run-time checks of the correct type, which clutters the code.
## Does Static typing prevents useful programs?
Because of *Incompleteness*, Static typing rejects certain perfectly fine programs. This means that it can potentially reject a useful program, causing us to have to work around this limitation in various ways such as by defining datatypes.
On the other hand, modern Statically typed languages have evolved to the point where this is hardly a problem in real-world use cases.
(And even beyond that, some languages, like Dart, allow us to define certain parts of our code as Dynamic.)
## Static typing catches bugs earlier
A type system lets us catch type-related bugs early, letting us focus on more important things, and often offers more useful information for debugging such errors than catching them Dynamically.
On the other hand, it could be argued that the kind of bugs Static typing prevents are the "easy" kind of bugs, and because we have to test our code regularly anyway(if we follow good development practices), this is less useful than it seems.
## Static typing has better performance
A static type system doesn't have to check types at runtime, and, more importantly, doesn't have to keep around tags for each value's type.
This can lead to better performance.

The counter argument is that compiler optimizations for Dynamically typed languages can often reduce those checks and tags for the more performance critical parts of our programs, and that using custom created types and other language features has this same issue in Statically typed language anyway.
## Code reuse
Because Dynamic typing doesn't place restrictions in what types use what functions, it can be easy to reuse code originally intended for other purposes. If for example, you defined in Racket both lists and trees in terms of `car`, certain list operations can also be applied to trees.
The counter argument is that it makes it harder to separate things that are different conceptually, and such uses lead to less coherent and more buggy code.
## Changing existing code
Dynamic typing allows us to modify or extends certain parts of the code without having to modify other parts. For example, if we want to extend a function so that it also works for arguments of other types we can do so without changing any of the existing calls to this function. In a statically typed language this would be much more cumbersome - We'd have to wrap it in a constructor, modify all cases to use the constructor etc.

On the other hand, Static typing is more useful when we want to modify our code in ways that can potentially break our old code, because it errs on every such change, basically giving us a to-do list of all the parts of the code we need to modify in accordance with this change.
For example, when we add a constructor to a datatype in SML, the language will give us all the case expressions where we have to add that constructor (assuming we didn't use a wildcard pattern).
## Prototyping
Often when we just begin to design our code, we're not sure what its supposed to do and how. The flexibility of dynamic typing allows us to check things out, experimenting and implementing only certain parts of the code.
The counter argument is that Static typing helps you document you code from the get-go and make sure what you're trying to do is consistent, thereby guiding you in the right direction as you design the code.