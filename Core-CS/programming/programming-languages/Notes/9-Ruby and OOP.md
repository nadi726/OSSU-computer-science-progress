We've seen Statically typed and Dynamically typed functional languages, and in order to complete the picture(as much as possible, under the constraints), we're now going to focus on Ruby - a Dynamically typed Object-Oriented language.

Ruby is a modern and reasonably popular programming language with many interesting features, some key ones relevant to us and others are out of scope of our discussion. Those include:

* Pure Object oriented language -  all values are objects.
* Class based - every object is an instance of a class. Not all OOP languages are class based - for example, JavaScript.
* Mixins - we'll get into them later, but basically they are one approach to the problem of sharing code between classes
* Dynamically typed - in an OOP setting, this mainly means that every object can call any method and if it doesn't exist we'll get an error at run-time.
* Many dynamic features - for example, methods and instance variables can be added and removed at runtime.
* reflection - built-in methods allow to check things about our code on runtime.
* blocks and closures - blocks are almost-closures and used everywhere in ruby, and there's also support for fully-fledged closures when we need them.
* A scripting language.
* Popular for building web applications with Ruby On Rails.
* Rich - there are many different ways to do things. As opposed to SML and Racket, which are more minimal by design, Ruby has a "why not" attitude towards convenient language features.

Our main focus will be on Ruby as an OOP language. We won't go at all, for example, into the uses of Ruby for web applications.

# Rules of Class-based OOP
* Every value is a reference to an *object*
* We "do stuff" with an *object* by calling its *methods*. This is also known as *sending a message*. Inside of a *method*, we can invoke other *methods* of the *object* itself and other *objects*.
* Each *object* has its own private *state*, defined by *instance variables*, also known as *fields*.
* Each *object* is an *instance* of a *class*
* The *class* determines the object's behaviour. it contains method definitions and fields.

Ruby is, unlike some other OOP language, a pure OOP langauge. In languages like Java, some special values are not objects, and there are ways to override some of those rules, like changing an object's state outside of its methods.
# OOP in Ruby
Let's look at the syntax of OOP in Ruby:
## Classes and methods
Here's how to define a class and its methods:

```ruby
class Foo
	def m1
	end
	def m2 (x, y)
	end
	def m3 x
	end
	def m4 (x, y=2, z=3)
	end
end
```

A method can take 0 or more arguments.
A method implicitly returns its last expression.
An argument can have a default value, which makes specifying such a value optional. Arguments with defaults must be on the right of the argument list.
## Calling methods
a method call looks like this: `e0.m(e1, ..., en)`.
`e0`, `e1`... `en` all evaluate to objects. Then we call the method `m` of the object `e0` evaluated to with arguments `e1`, ... `en`.
The parenthesis are optional. We tend to avoid them on method calls with no arguments.
To refrence methods of the object itself we use the keyword *self* beore the method name. It is optional, unless there's a naming conflict with something defined outside of the class.
A more OOP terminology for this is *sending message*. The *client* - the code sending the *message* - doesn't care what the *receiver* - the code processing the message, the object - is doing with that message.
## Instance variables
An object's state is stored in variables called instance variables.
Those are typically defined in the class and its methods for each object,
but we can actually define new ones for each object.
Instance variables are declared by `@foo` and modified with `@foo = e`. They can't be directly accessed outside of the object.
There are also class variables, shared by all of the class's objects, written like `@@foo`.
## Creating an object
Objects are created with `ClassName.new`.
`new` references a special method `initialize` which is invoked each time an object is created. Typical behaviour for `new` is to take arguments that give initial values to the class's fields, which are then (typically) not defined elsewhere.
## Expressions
Most expressions are actually method calls. For example, `a + b` is `a.+ b`.
Not all of them are, through. The most common kind of those that are not method calls are conditionals.
## Local variables
Variables local to a method don't have to be declared. Creating a variable inside of a method simply makes it local. Referencing such a variable before creation is a runtime error, unlike instance variables where you get `nil`.
## Class constants and methods
Class constants are immutable and can be accessed outside of the class.
They start with a capital letter, and can be accessed by `C::Foo`.
Class methods are like regular methods, but they don't have access to anything method-specific and can be accessed from outside the class.
One way to define them is: `def self.method_name args end`
## Getters and setters
Unlike fields, which are private, methods can have different levels of visibility.

`public` is the default, `private` makes a method private, and `protected` means it can only be accessed by the object itself or by other objects of the same class(or of its sub-classes).
One way to specify the visibility is by simply writing it over the set of methods which should have that visibility.
If a method `m` is private, it can only be accessed by its name - calling `self.m` is wrong, for example.

If we want to access and modify fields outside of an object, we can do so indirectly by writing getters and setters methods, which are just methods that modify or return a field's value:
```ruby
def foo
	@foo
end
def foo= x
	@foo = x
end
```
(As a bit of syntactic sugar, putting a `=` at the end of a method's name makes it so that in calling the method we can separate it by space: `obj.foo = e'` is just `obj.foo= e`)

The benefit of this is that we add a layer of abstraction between the client and the receiver. For all we know, `foo` doesn't have to return a field and instead can just return some value. The receiver can also do some stuff before or after setting or getting the value:
```ruby
def celsius_temp= x
	@kelvin_temp = x + 273.15
end
```

"Regular" getters and setters can be defined by:
```ruby
attr_reader :y, :z # defines getters
attr_accessor :x # defines getters and setters
```
## The top level
Everything other than a class defined at top level is part of the `object` class, which all classes inherit from. Thus, every object is really an instance of some class.
Top level expressions are evaluated in order. We don't have to create a special `main` class like in other languages.
## Class definitions are dynamic
We can change class definitions while the program is running.
Changing a class definitions also affects objects of the class previously created.
This can easily break stuff in our code, but makes implementation easier.
## Duck Typing
Duck typing is a style of programming in which we treat objects based on what they "do"(what methods they implement), not on what they "are"(their type).
It comes from the phrase "if it walks like a duck and quacks like a duck then its a duck". More accurate would be to say that it doesn't matter if its not a duck - because for all our purposes, it behaves in exactly the same way.
Duck typing is common in Ruby and other dynamic languages(like scripting languages) because it makes development simpler and makes it easy to extend our code.

The major tradeoff that comes with the convenience of duck typing is that because we don't assume anything about what the type of the object is, we need to assume everything relevant to us about its behavior - we have to assume certain aspects of its **implementation**.
We have to be very specific about the methods of the object we use, and often seemingly equivalent things might not work correctly because we've ended up assuming too much. For example, The expression `pt.x * 2` is not **necessarily** equivalent to `pt.x + pt.x`, because `pt.x` may return an object that is not a number and behaves differently in addition and multiplication.
## Arrays
Generally speaking, arrays are data types that maps numbers to values.
Arrays in Ruby are extremely common, as they are very versatile datatypes that can be used for a lot of purposes.
Arrays in ruby are very dynamic - they have dynamic size, can hold objects of different types, and instead of array-bound errors we just get `nil`. The downside is performance, but that's less of a concern in languages like Ruby.
Arrays come with a lot of built in methods, and are also used as replacement for other common datatypes like stacks and tuples by having all the appropriate methods.
We can create an array either by explicitly specifying its arguments, like `[a, b, c]` or by calling `array.new(x)` to programmatically create a new array (The default behavior for this creates an array of `ints` from 0 to `x`, but that can be changed by using *blocks*).

Other common datatypes in Ruby are *hashes*, which are like maps in other languages and written like `{"SML" => 7, "Racket" => 12}`, and *ranges*, which represents continuous sequences and written like `1..10`.
## blocks
Blocks are code sequences that can be passed down to methods 0 or 1 times, which then may be called inside the method's body using the keyword `yield`. They are used everywhere in Ruby and its standard library, including many array methods, and is the reason why idiomatic Ruby doesn't include many loops.

Blocks can take arguments which are supplied whenever we call them.
The syntax for blocks looks like this: `array.new(5) {|i| i*2}` where the block is everything between the curly braces, and inside the `| |` are the argument, which can be omitted if we don't use them in the block's body.
Optionally, instead of curly braces we can wrap a block in the keywords `do` and `end`.

Blocks are **not** objects. Blocks are "almost closures" in the sense that they have lexical scope, but they can't be passed around(except when creating them, to the method the're used in). To pass a block we have to wrap it in another block: `{|i| yield i}`.

Ruby does have support for full closures via the class `Proc`.
To make a `Proc` out of a block we can call the `lambda` method with a block.

# Subclassing and inheritance
*Inheritance* is an important OOP concept. The idea is that we can reuse a class's definition by making other classes that inherit this definition, and can each make their own modifications and extensions as needed.
A class B that inherits from class A is called the *subclass*, while the parent class is called the *superclass*.
B inherits all of A's methods, and all its fields in languages that have them as part of the language definitions like Java.

The inherited definition can be *extended* by adding new fields and methods, or *overridden* in some parts, for example by replacing a method definition with a new one in the subclass.

Inheritance lets us reuse code by sharing it between classes, and marks a certain relationship between the different classes in our program that (hopefully) makes semantic sense as well. This relationship ultimately creates a system of relationships between classes called the *class hierarchy*.
Usually OOP languages have operations for exploring this hierarchy -including Ruby.

In ruby, each class has exactly one *superclass*. All classes ultimately inherit from `Object` or from one of its descendants.
To specify that a class B inherits from A We write: `class B < A` at the top of the class definition(by default, a class inherits from `Object`).

Subclassing is sometimes a good idea, as it lets us reuse code and it just makes sense for some classes to have this kind of relationship. But it tends to be overused, even when there are much better approaches, leading to an unnecessarily complicated class hierarchy that may not even make sense.

Choosing when to use subclassing can be a challenging design problem and we won't discuss it here. Instead we'll consider some possible alternatives to making class B a subclass of A:
1. Modifying A to include all of the things we wanted to have in B - this is often not a good idea, except for maybe small changes, as it can break existing code, and bloat A with different parts that are totally irrelevant to each other and even resulting in clashing of code and fields/methods from those parts.
2. Copying all the relevant code from A to B - also generally not advised, as we tend to prefer code reuse when possible. Also, having the subclass-superclass relationship can be important, especially in static OOP languages where it makes *subtyping* possible.
3. composition - making an instance of the old class a field of the new class. This is often better than subclassing and tends to be underused, but it is not always better. First, if we want to access A's methods we'll need to either access the field first, or wrap each method in a new method of B - making code reuse more cumbersome. Second, there's the aforementioned problem of not having the subclass-superclass relationship.

# Dynamic Dispatch
Dynamic Dispatch refers to the process by which we decide what method to call on an object.
It works by determining the runtime-type of the object and then calling the corresponding method of the class of the object.
Basically, *dynamic* - determined at run time, *dispatch* - calling a method.

Dynamic dispatch is a core OOP concept that enables a program to call methods on objects without knowing their specific types at compile time, thus promoting code reusability and flexibility. It is a fundamental difference between OOP and functional programming and plays a crucial role in achieving polymorphism in OOP.

One important way dynamic dispatch is manifested is in the fact that it always refers to `self` as an instance of the class it determined it to be at runtime:
When having an object `o` of a class `B` which is a subclass of `A`, calling a method `m1` on `o`, which has a call to a method `m2`, will treat `m2` as a method of `B` - even if `m1` was defined in `A`.

For example:
```Ruby
class A 
	def m1 
		m2
	end 
	def m2
		puts 0
	end
end

class B < A
	def m2
		puts 1
	end
end

a = A.new
b = B.new
a.m1 # Will print 0
b.m1 # Will print 1
```
In this example, calling `m1` on objects of classes `A` and `B` demonstrates dynamic dispatch, as the method `m2` is resolved dynamically based on the runtime type of the object, showcasing polymorphic behavior.
## Dynamic dispatch versus closures
One crucial difference between functional programming and closures and dynamic dispatch is how they handle a modification of code that refers to other code.
More specifically, if a closure refers to a function that is later shadowed by another function, it doesn't matter, as the closure keeps the old function in its environment. 
On the other hand, if a subclass overrides a method of a superclass, any calls to that method from an object of the subclass will now refer to the new method - even if the calling method was defined in the superclass.

This can be either a blessing or a curse: if the newly defined function/method is simply a more efficient implementation with exactly the same behavior, for example, it is desirable for it to modify the old one. But if it has a slightly different behavior, it can break earlier code.

As an example lets consider the following SML and Ruby code:
```sml
fun even x = if x=0 then true else odd (x-1)
and odd x = if x=0 then false else even (x-1

fun even x = false // Doesn't break old code
fun even x = (x mod 2) = 0 // Doesn't enhance old code
```

```Ruby
class A
	def even x
		if x==0 then true else odd(x-1) end
	end
	def odd x
		if x==0 then false else even(x-1) end
	end
end

class B1 < A
	def even x # breaks B1’s odd too!
		false
	end
end

class B2 < A
	def even x # enhances B2’s odd too!
		x % 2 == 0
	end
end
```
