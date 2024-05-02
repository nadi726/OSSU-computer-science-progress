# Kinds of compound data
Every programming language has base types, like integers and strings, but in order to properly express more complicated types of data we need datatypes that are comprised of other data. Those are *compound types*

There are 3 conceptual kinds of compound types:
1. **Each of/product types** - describes a value that is made up of values of `t1, t2... tn` types
2. **One of/sum types** - Describes a value that is made up of **either of** `t1, t2... tn` types
3. **self reference/recursive types** - describes a value that refers to itself in its definition

* Tuples are an example of each-of types - they have certain "fields", and require all of them
* Options are an example of one-of types: a `t Option` is either a `None` or `Some t` 
* Lists(in languages like SML and Racket) are an example of recursive (and one-of) types: a list of type `t` is either the empty list or a pair of a value of type `t` and a list of type `t`

In OOP, we typically uses classes and inheritance to express a combination of those ideas: A *class* is an each-of types, with required *fields* and *methods*. It is also a self reference because we can use `self`/`this` to refer to the class itself. And by having multiple classes inherit from a single base class, and using *subtyping*, we can use each subclass to somewhat represent a kind of a one-of type for each option. We can do a similar thing with *interfaces*.
## Compound data in SML and Syntactic sugar
### Records
Records are a kind of each-of type that have named fields. Unlike tuples, which are ordered by position, records access the contained values by referring to their names.
A record expression looks like this: `{i1 = e1, i2 = e2,...,in = en}`. We won't go into details about their type and evaluation rules, because at this point it should be fairly obvious.
We can access values of a record by specifying the name of the field `f`, like this: `#f e`, although we will soon learn a better way.

### Syntactic sugar and the truth about tuples
Records and tuples are so similar, that we can define a tuple in terms of a record. In fact, this is what SML actually does.
A tuple is a **syntactic sugar** for a record.
The expression `{e1, e2, ..., en}` is really the same as `{1 = e1, 2 = e2, ..., n = en}`

This is an example of **syntactic sugar**. Syntactic sugar means introducing new syntax into the language, without introducing a new meaning that wasn't there before. 
Internally, the compiler or interpreter translates the new syntax into a different one that it already knows how to deal with.
When it sees a tuple in SML, for example, it translates it into a record with field names corresponding to the position of each value in the tuple.
Put more simply, its a way of defining language features using existing language features.
It enables us to keep a language implementation smaller while giving the programmer more ways to express ideas.
#### Practicality
Syntactic sugar is very useful and comes up in a lot of different places.
It can make our code more readable and less verbose without introducing more complexity to the language.

Examples:
* many languages support this: `a += b`, which is syntactic sugar for `a = a + b`
* *f-strings* in Python allows us to deal with string formatting much more concisely:
	```python
	# Regular concatenation
	message = 'Hello, ' + name + '. You are ' + str(age) + 'years old.'
	
	# Using f-strings (Python 3.6+)
	message = f'Hello, {name}. You are {age} years old.'
	```
* Dart supports *null-aware operations*, which succinctly handle null/non-null values:
```dart
// Without null-aware operators
var value = input != null ? input : 'default value';

// Using null-aware operators
var value = input ?? 'default value';
```

### Datatypes
Datatypes are SML's way of handling one-of types.
They look like this:
```sml
datatype mytype = C1 of t1
				| C2
```
`C1` and `C2` defines constructors. A constructor is 2 different things:

1.  either a function that is given an expression of the type defined in the datatype binding - if it takes a type t as an argument, or a value otherwise. Here `C1` defines a function, where `C2` defines a value. They both return a value of type `mytype`, which has a "tag" that relates them to the specific kind of `mytype` they belong to. 
2. This is related to a concept we haven't seen yet: pattern matching, and without getting into the details, it allows us to match patterns.
#### Lists and options are datatypes
Lists and options are just built-in datatypes with slightly special syntax.
Here's how we might define them:
```sml
datatype IntList = Cons of int * IntList
				  | Empty
datatype IntOption = Some of int
				   | None
```
Note here there's one difference between the types we defined and the built in types: the built in types accept **any** type, while ours only works for `int`. That is because the built-in types uses something called *parametric polymorphism*, which we'll get to soon.
### Type synonyms
A different way of defining names for types is by using type synonyms.
Here we don't create a new type - just give a new name to an existing type. example:
```sml
type date = int * int * int
```

# Parametric polymorphism
So far we've seen many kinds of types, and soon we'll see a powerful way of choosing and deconstructing the right type for an expression. But what we're lacking is a way of referring to types more generally.
What if we want to create functions that handle more than one type, or, like we've seen, create types that define a general notion of a certain type - like lists?
That's where type variables, or parametric polymorphism comes into account.
*Parametric polymorphism* sounds fancy, but it only means that we define a parameter that, based on the type inserted, causes the expression to have a different shape, hence *polymorphism* - many shapes. They are also known as *Generics* as they describe types in a more "general" way.

The idea is very simple: instead of defining an actual type, we define *type variables*, which refer each to a certain specific type - that we haven't yet specified. Once we call that expression with a type, we create a new compound type that used the type we specified.
Lets take a list, for example:
```sml
datatype `a List = Cons of `a * `a List
				  | Empty
```
`'a` can be any one type - an `int`, a `string`, or anything else we want.
but once we create an `int List`, for example, there can be no strings in that list.
Here's another example, inside a function:
```sml
fun length xs =
	if null xs
	then 0
	else 1 + length (tl xs)
```
This concept is used to make generic functions and datatypes, which helps make our code more reusable - the length function, for example, can be used to determine the length of **any** list.
# Pattern matching
## Case expressions
A case expression is SML's way of accessing the different variants of a datatype(or any expression, really). it looks like this:
```sml
fun f e =
	case e of
		C1 v => e1
	  | C2 => e2
```
a case expression evaluates `e` to a value, and based on the type of the value it has one-or-more branches, or cases, each corresponding to one possible variation of that type.
It then picks the correct case based on the value of `e`, and based on the shape of that case it might **deconstruct** certain bindings, and evaluates the corresponding expression in an environment with those bindings.

Pattern matching is better that the intuitive alternative, like we've seen for lists and options, as it leverages the type-checker to encourage us to cover **all** cases, and **exactly** those cases, while also making sure we get out the data we want and in the right way.
## Pattern matching demystified
That method of picking the right branch and deconstructing is called *Pattern matching*, and it works by comparing the type of the value of `e` against what is described in the pattern `p`. If they match, the variable name, or names, in `p` are matched against the corresponding values inside of the value of `e`, and bound to them.
## Val bindings
Here's another example of pattern matching:
`val (a, b, c) = (1, 2, "shalom")`
We've seen val bindings before, but it turns out that SML is built a lot around that idea of pattern matching, and we also use it in val bindings.
here, the shape of the pattern is a tuple with 3 items, and those get assigned to the corresponding values of the given tuple - `a` to `1` and so on.
## Function arguments
It turns out that function arguments also use pattern matching.
In SML, functions have only one argument. What we've seen so far is really just a pattern that matches a tuple with the names of the "arguments".

```sml
fun f0 tup = 
	case tup of
		(a, b) => a + b
fun f1 (a, b) = a + b
fun f2 {first=a, second=b} = a + b
```
All those functions are doing the same thing, which is adding 2 numbers together. `f0` and `f1` are equivalent: we can treat a function argument as a tuple, or we can apply pattern matching in the argument itself to treat it as multiple argument.
`f2` does something a bit different: it uses pattern matching with a record, effectively giving us a function with named arguments.
## More type inference
By using patterns to access values of tuples and records instead of what we've done so far, we can now make use of type-inference to omit describing types in the function argument.
This is because, as opposed to getting the values directly, patterns tell the type-checker all it needs to know about the type of the expression, as pattern-matching tells us about all the fields of the record or tuple.
For example:
```sml
fun sum_triple triple =
	let val (x, y, z) = triple
	in
		x + y + z
	end

fun sum_triple (triple: int * int * int) =
	#1 triple + #2 triple + #3 triple
```
In the first example we know that triple is a tuple with exactly 3 integers **based on what happens in the body of the function,**
while in the second we can only tell that the first 3 fields are integers - we don't know that those are all the fields, and thus have to specify a type.
Omitting argument types is not only the common practice in SML, but it can also help us discover that some functions are more general than we've though.
## Nesting patterns
Pattern matching is recursive - we can nest patterns inside of other patterns.
For example:
```sml
fun all_same_value lst =
    case lst of
        [] => true
      | c::[] => true
      | c1::(c2::cs) => (c1 = c2) andalso all_same_value (c2::cs)
```
This function checks whether all values in a list are the same.
It uses nested patterns to get out the different pieces of the list based on its length (0, 1 or more items). particularly the case `c1::(c2::cs)` is matched against a list whose first value `c1` is consed into a list with at least one value `c2`.

# Tail recursion
This topic is completely separate from anything we've seen so far. It doesn't deal with language semantics at all, and instead focuses on two idiom that are important in SML and functional programming in general: *tail recursion* and *accumulators*.

## Motivation
Recursion is a great tool for going through arbitrarily-long data and computations, and is often much more powerful than loops. But it has a big problem: it is clogging up memory.
When we call a function, the program goes "inside" that function to compute its content. With recursion, instead of completing the computation and going into the next iteration of the function, we have to wait upon the function to complete and return a value. This means that every call we make ends up eating more memory to preserve the context of the waiting calls. When we have a lot of calls, we may run out of memory and crash the program, resulting in what is known as a *stack overflow*.
## The solution
Luckily, we can often solve that problem by writing our recursive functions in such a way that by the time we get to the next call, there is nothing else to do except calling the function. This idea of a function ending with nothing except a call to another function is called a *tail call*.
Recursive Functions that are ordered in this way are called *Tail-recursive functions*.
The benefit of this is that if the language implementation supports *tail call optimization*(which refers to the compiler/interpreter replacing the active instance of the function with the tail call), we can use this to write recursive functions that do not have the memory problem we've seen earlier.

Here's an example:
```sml
fun length1 xs =
	case xs of
		[] => 0
      | _::xs` => 1 + length1 xs`

fun length2 (xs, acc) =
	case xs of
	    [] => acc
	  | _::xs` => length2 (xs`, acc + 1)
```

The first function uses regular recursion as we've seen so far.
The second uses tail recursion. Notice how in the first function, the recursive case has more computation outside of the recursion(adding 1 to the result), while in the second one, that computation is done **inside** the recursive call.
## Accumulators
In order to achieve this behaviour we've introduced a new argument that contains the sum up-until that point in the recursion. At the first call of the function, we'll have to assign that argument to 0 in order to get the correct answer.

This kind of argument is called an *accumulator*. An *accumulator* is an argument that is used to preserve the context of the function. There are different kinds of accumulators, and we won't show them here, but what is important for us is that the accumulator we've used stores the result-so-far of the computation.
## Trampoline
Supplying the accumulator with 0 every time we want to call our function is not only cumbersome, but also hinders the function's abstraction (which refers ti the idea that the user doesn't need to care about the implementation) and can potentially introduce bugs, so its common to use something called a *trampoline* - define the recursive behaviour inside an inner function and call it inside the main function with the accumulator:

```sml
fun length3 xs =
	let fun inner (xs, acc) =
		case xs of
			[] => acc
		  | _::xs` => length3 (xs`, acc + 1)
	in
		inner xs 0
	end
```
## Traversing data structures
Another important difference between tail-recursive and other recursive functions it that they traverse data structures in exactly the opposite way.
Consider the following example:
```sml
fun rev1 lst =
	case lst of
		[] => []
	  | x::xs => (rev1 xs) @ [x]

fun rev2 lst =
	let fun aux(lst,acc) =
		case lst of
			[] => acc
		  | x::xs => aux(xs, x::acc)
	in
		aux(lst,[])
	end
```

Here we have 2 functions that reverse a list.
The first one is non tail-recursive, and has a much more expensive computation, as it traverses the remaining list to insert an element at its end in each iteration.
In the second, tail-recursive function, the first call appends the first element to the end of the empty list, the next one appends the second element on top of it and so on - effectively reversing the list just by traversing it.

It's important to note that sometimes that opposite way of traversing data structures is not what we want, making the tail-recursive solution more cumbersome and less performant than other approaches.