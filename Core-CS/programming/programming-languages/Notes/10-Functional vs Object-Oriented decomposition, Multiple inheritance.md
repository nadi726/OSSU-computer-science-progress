One key difference between Functional and Object-Oriented programming is in the way they break down programs. In fact, looking at it this way, we can say that Functional and Object-Oriented programming are so similar that they break programs down in exactly opposite ways.

Functional Programming thinks in terms of operations, where inside of each operation we may handle all the different datatype combinations we need.
On the other hand, Object-Oriented Programming thinks in terms of classes and their objects, and for each class we define all necessary operations for the kind of data that the class represents.
Choosing which to use is largely a matter of personal opinion, but as we'll see, depending on circumstances one style may be preferable.
# The problem
Suppose we want to implement a language for describing a small arithmetic "language", like we've done before.
Our language is made up of 2 components: *expressions*, such as integers and negation, and *operators* that acts on those.
We can therefore view the problem as a 2 dimensional grid:

|            | eval | toString | hasZero |
| ---------- | ---- | -------- | ------- |
| **Int**    |      |          |         |
| **Add**    |      |          |         |
| **Negate** |      |          |         |
Decomposing our program has to do with filling this grid in a specific order. FP does so column-by-column, while OOP does so row-by-row.
## The Functional approach
Using the Functional approach, we'd first define the datatype for an expression, with one constructor for each kind of expression.
Then, we'll define a function for each operation.
Finally, in each function, we'll use pattern matching to define the behavior for each combination of constructors according to our specification. We can use wild card patterns for taking care of defaults and avoiding repetition.

Of course, not all Functional languages have datatypes, constructors or pattern matching, but it doesn't really matter - we'll still think of the problem in the same way, we'll just use existing language features to simulate this behavior.
## The object-oriented approach
Using the Object-Oriented approach, we'd start by defining an abstract class for an expression, with abstract methods for each operation.
Then, for each expression we'll define a class that implement this abstract class.
Finally, in each class, we'll define methods for all different operations that the expression should support. We can define methods in the superclass and override them as necessary in order to take care of defaults.

Not all Object-Oriented languages need abstract classes, and we may use duck typing instead, but even then we'll still think of this in a similar way.
## Planning for extensibility
Because of this difference of going "by rows" vs "by columns", the way by which we may wish to extend our program is impacted by the paradigm we use.

In FP, it is easy to add new columns - new operations. We just define a new function, and define the behavior for each datatype. Adding new types of data, however, is more cumbersome - after adding the constructors, we'll have to go into each of our existing functions for the operations and add the new datatype to the pattern matching.
In OOP, it's the opposite. Adding new operations is difficult - we have to go into each class for expression and add a method for the new operation. Adding new expressions is easy - we just need to make a new class for the expression and implement the methods for the operations.

Therefore, if we can determine that our program is more likely to be extended in a certain way, choosing the more appropriate approach can be beneficial.
## Binary methods
If we need support for operations that take 2 expressions, also called binary operations, the choice between FP and OOP becomes much less subjective. The FP approach for binary operations is pretty straightforward, where the OOP approach is more cumbersome - although, using a certain language feature supported by certain OOP languages, that complication can be avoided.

A binary operation has to take into account all of the different datatype combinations. Therefore it is already more complex than we've seen before, no matter our approach.
We can view this as a 2 dimensional grid, for example:

|              | Int | String | Rational |
| ------------ | --- | ------ | -------- |
| **Int**      |     |        |          |
| **String**   |     |        |          |
| **Rational** |     |        |          |
### The Functional approach
Using the functional approach, each operation simply fills the whole grid.
We'll probably find it makes more sense to split the operation into a new function, which simply covers all combinations with pattern matching.
### The Object-Oriented approach
Here the grid is spread out across all expressions, in a more complicated manner.
We'd have to use a technique called *double dispatch*, which relies on *dynamic dispatch*, and basically uses it twice - once for each expression.

Let's say we have an operator `f` and 2 expressions, `e1` and `e2`.
After evaluating `e1` and `e2`, `f` calls the appropriate method for evaluating `f` on `e1`. So far, this is just like before, using dynamic dispatch to "determine" the type of `e1` and how it should be handled.
Now, the problem is that `e1` doesn't "know" the type of `e2`. In a full OOP approach, we don't use any helper functions for determining the type of the object - we should communicate with it by sending messages.
What we **do** know is the type of `e1`. So in the next step, we call a method on `e2` that knows how to handle operator `f` on the type of `e1`. That's the second dispatch, and hence the name double dispatch.
### Mutlimethods
Some OOP languages can completely avoid the need for dynamic dispatch by letting the language determine "who to call" at runtime, via a feature called *multimethods*. The idea is to define multiple methods with the same name, where each method differs in the types of argument it takes. At runtime, when a method with such name is called, the language implementation determines the types of the arguments passed and decides which method to use accordingly.
Note that this is **different** than *static overloading*, offered by languages like Java - which is where we determine what method to call based on the arguments types at **compile time**, not at **runtime**.

# Multiple inheritance and alternatives
We've seen how essential subclassing is in OOP. So far, we've only seen examples with one immediate superclass. Different approaches in OOP languages extend this in different ways.
Those approaches all have different degrees of restriction, where more restrictions means simpler semantics.
There are 3 main ones: *multiple inheritance*, *mixins* and *interfaces*.

## Multiple inheritance
*Multiple inheritance* is just as it sounds: instead of allowing only one superclass, each class can have many.
By allowing more superclasses, each class can be very easily extended in powerful ways. The drawback is that the semantics for subclassing and method lookup become complicated, as we have to deal with situations such as: what happens when 2 superclasses share the same method name?
The most notable language with multiple inheritance is probably C++. Ruby does not have it.
## Mixins
*Mixins* are chunks of code that define methods and/or fields. They can be included in classes and thus provide that behavior, and each class can have any number of mixins. A mixin is **not** a class and thus avoids a lot of the semantic problems that multiple inheritance has. We still have to decide what happens when 2 mixins share the same method name, or when a mixin and the class using it does. 

Ruby supports mixins, and it slightly complicates method lookup: we first look for the method in the class, then its mixins, then the superclass, then its mixins, etc. Mixins are very useful in ruby and there are many mixins in the standard library.
A useful mixin idiom, also used in the standard library, is for a mixin to assume that certain methods exist in the class and use them in the method it defines. This allows it to extend to class in a way that integrates more seamlessly with the class's behavior.
## Interfaces
*Interfaces* are the most restrictive of the 3. Like mixins, they are not classes. Interfaces don't implement any method - they just declare the signatures for the methods that a class implementing the interface must implement. As such they don't provide much of the flexibility of the other approaches, but their semantics are much simpler.
Interfaces are really only necessary in languages with static typing, because they allow any class that implements the interface to also inherit its type. Thus, its more similar to duck typing than multiple inheritance in this way. Dynamic languages like Ruby don't need them and don't benefit from having them - we just use duck typing in those languages.
## Abstract classes and methods
Sometimes we may want to define a class that should not be instantiated directly. For example, we may want to create several subclasses and it only makes sense for those to implement certain methods of the parent class.
In those cases, in statically typed languages at least, we need some way to signify to the language that those classes should not be instantiated, in order for the type checker to detect those cases.
This kind of class is called an *abstract class*. Abstract classes are classes that cannot be instantiated, only subclassed. They can have regular methods as well as *abstract methods*, which don't include an implementation, much like mixins.
In fact, languages like C++ can implement "mixins" by simply defining an abstract class with only abstract methods, and rely on the fact that subclassing it doesn't restrict us in any way because of multiple inheritance.