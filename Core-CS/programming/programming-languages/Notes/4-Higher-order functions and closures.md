# Functional programming
This section continues our discussion of functional programming concepts.
But first, we have to define what functional programming is.
This is a bit challenging, as functional programming may mean different things depending on the context or on the people who use the term.

Generally, through, it is agreed that:
functional programming is a programming *paradigm*.
A paradigm is a way of thinking, a way of modelling our reasoning about a particular topic. a *programming paradigm*, therefore, is a certain way, or method, of thinking about the overall structure - the design - of our programs.
Functional programming is a paradigm that suggests that the fundamental building blocks of a program should be **functions** - pure, mathematical functions that take in an input and return an output, and produce no side effects - that is, they don't do anything else, such as mutating variables or writing to a file. Those functions should be composed and applied together in order to structure our whole program.

It boils down to 2 main ideas that functional programming brings to the table of programming paradigms, as opposed to other styles of programming:
1. The idea of first class functions, and the (orthogonal but complementary) idea of closures.
2. The advocating of limiting mutation as much as possible, and only using it when absolutely necessary or when it makes much more sense to model our programs in that way.

There are other ideas that are often associated with functional programming. As functional programming is centred around functions, there is a large focus on writing recursive functions, and recursive data structures to go along with them.
Functional programming is also much more closely related than most other paradigms to the idea of programming as a way of mathematical thinking and proof writing. Programs written in a functional style often have a very interesting and useful property to them - they can be proven mathematically to be correct.
The idea of *laziness*, which we will touch upon later, is also largely advocated in certain variations of functional programming, especially in languages such as Haskell.

A related question is: what makes a programming language a functional language? The truth is that there is no hard and fast "rule" to define which languages are functional and which are not. You can program in a functional style, at least to some degree, in a wide variety of languages that are not considered functional. As we've said, a paradigm is a certain way of modelling our program, and we often have a choice here.
Programming languages support different paradigms to varying degrees.
Therefore, a better, more productive question to ask would be: given a certain language, how much does it support programming in a certain style? How much native support it has for that style's idioms, and how much it hinders them? For functional programming, we'd need, as a minimum, support for immutable data, first-class functions and closures.
# First-class functions
*First-class functions* are functions that can be used just as any other value: they can be passed around to to other functions, returned from functions and put inside data structures.
A *higher-order function* is a closely related, albeit more limited, term: it just means functions that take other functions as arguments and/or return functions as a result.
## Functions as arguments
The most common sort of higher order functions is functions that take other functions as arguments. This allows us to abstract away common computations, enhancing our ability to make parts of our code reusable. 

For example, say we want to repeatedly apply a function `f` to itself `n` times.
We could achieve this by passing `f` to a new function:
```sml
fun n_times(f, n, x) =
	if n = 0
	then x
	else f (n_times (f, n-1, x))
```
We can apply this function to different functions `f`:

```sml
fun double_string x = x ^ x
fun double_int x = x + x
fun increment x = x + 1
```

Notice how our higher-order function works for both `strings` and `ints`. 
## Higher-order functions and polymorphism
Turns out, higher-order functions are often polymorphic. `n_times`, for example, has type: `('a -> 'a) * int * 'a -> 'a`
That makes higher-order functions even more useful, but its important to remember that Generics and higher-order functions are orthogonal concepts: a function can be polymorphic without being a higher-order function, and a higher-order function isn't necessarily polymorphic.
One simple change to our function, for example, could make it non-polymorphic:
```sml
fun n_times_int(f, n, x) =
	if n = 0
	then x * 1
	else f (n_times (f, n-1, x))
```
This function's type ls `(int -> int) * int * int -> int`.
## Anonymous functions
Passing functions as arguments is useful, but a lot of the time the function we're passing as an argument is only supposed to be used once, in that specific context, and a full function definition is a bit too much.
Instead we can use an anonymous function.
An anonymous function, like the name implies, is a function without a name. It is also an expression itself, which means it can be directly passed as an argument.

Consider this function, for example:
```sml
fun triple_n_times (n, x) = n_times(fn y => 3*y, n, x)
```
Here we've defined a function using 2 other function: `n_times` and an anonymous function, which takes an argument and triples it.

One important difference between anonymous functions and regular function binding is that as anonymous functions have no name, they cannot use recursion. In such cases, we'll need to refer back to `fun` bindings.

A poor way of using anonymous functions is making unnecessary function bindings, which means creating a new function that does nothing except wrap an existing one:
```sml
fun nth_tail (n,x) = n_times((fn get_tl y => tl y), n, x)
```
Here, `tl` is already a function. We could have just passed it directly:
```sml
fun nth_tail (n,x) = n_times(tl, n, x)
```

## Useful higher-order functions
There are certain higher order functions that are so useful that they are widely used and known. Let's take a look at the 3 most common ones.

Here are possible definitions of them for lists:
```sml
fun map(f, 'a list) =
	case xs of
		[] => []
	  | x::xs' => f(x)::map(f, xs')

fun filter(pred, 'a list) =
	case xs of
		[] => []
	  | x::xs' => if pred x 
				  then x::(filter(pred, xs'))
				  else filter(pred, xs')

fun fold(f, acc, xs) =
	case xs of
		[] => []
		x::xs' => fold(f, f(acc, x), xs')
```
### Map
map takes a function `f` and a data structure and applies `f` to every element of the data structure - resulting in a new value where each element is "mapped" to an element from the original.

For example, say we have a list of `ints` and we want to square each element:
```sml
val int_list = [1, 2, 3, 4, 5]
val squared_ints = map((fn x => x*x), int_list)
(*Answer: [1, 4, 9, 16, 25]*)
```

### Filter
Filter takes a list and a function that returns true whether an element of the list meets a certain condition, false otherwise. The result is a new list that contains only the elements that met the condition.
Here filter is used to get the even numbers from a list:

```sml
val evens = filter((fn x => x mod 2 = 0), int_list)
(*Answer: [2, 4]*)
```

### Fold
Fold is the most complicated of the three, and has different variations.
In general, through, it takes a function, list and a base case, and applies the function to each element of the list and the result so far, starting with a base case.
This may sound quite involved, but there's a reason for this: fold is the general idea of **traversing** a data structure. In fact, we can even define map and filter in terms of fold.

An example of using fold is to get the sum of a list, or a product:
```sml
val list_sum = fold((fn (x, y) => x + y), 0, int_list)
(*Answer: 15*)
val list_sum = fold((fn (x, y) => x * y), 1, int_list)
(*Answer: 120*)
```

Sometimes fold has a different name, and that sometimes depends on the variation used. Other common name are `reduce` and `inject`.
One thing we should particularly notice is that lists can be traversed from the left or from the right. That's why fold usually has 2 separate functions, called `foldl` and `foldr` for folding to the left or to the right, respectively. For some lists it doesn't matter which one you use, but others you may have to traverse from a certain direction to get the right answer.

Another thing we should notice about those functions is a clear separation of concerns: we separate the traversing of the data (`fold`, `filter` etc) from the processing of that data (the function we pass to the higher-order function)
# Lexical scope and closures
Here we're getting into the second big concepts in this section, which is essential to make functions - especially higher-order functions - much more powerful.

This idea is called lexical scope. *Lexical scope* is the idea that **the body of a function is evaluated in the environment where the function was defined**.
It is often contrasted with *dynamic scope*, which is the idea that the function's body is evaluated in the environment from which it is called.

For example, let's consider this simple function:
```sml
val x = 1
fun f y = x + y
val x = 2
val z = f 1
```
The value of `z` is 2, **not** 3, because at when `f` was defined, `x` was bound to 1. Under dynamic scope, the value of `z` would have been 3.
## Lexical scope and mutability
It is important to remember that val bindings in SML are immutable, so `val x = 2` is not re-assigning `x` to a different value, but instead creates a new binding named `x`. This is important because if `x` was mutated instead, then it means that its value in the environment has changed, so calling `f` later would still result in 3, just like dynamic scope - although it is **still** lexical scope.
## Why lexical scope
Except in some specific situations, lexical scope is vastly superior to the alternative. It makes the code easier to reason about, more predictable (a later variable binding cannot change the behaviour of an already existing function), and makes it easier to write code that is the result of combining and composing different functions, as each function's behaviour is entirely independent of the others. This is why almost all major programming languages use lexical scope as the default, and most of them don't offer any support for dynamic scope.
## Closures
In order to implement lexical scope, each function's value is actually composed of 2 parts: one part is the code the gets executed and the binding, and the second part is the function's **environment**(which is the environment it had when it was defined). This idea is called a *closure* as it means that a function is closed in terms of bindings - it has everything it needs to compute the result.
### Closure idiom: enhancing higher-order functions
One key use of closures is to make our higher-order functions much more powerful. For example, let's take a look at 2 functions defined by `filter`:
```sml
fun allGreaterThanSeven xs = filter (fn x => x > 7, xs)
fun allGreaterThan (xs,n) = filter (fn x => x > n, xs)
```
The first function doesn't rely on the environment; It's just like the other functions we've seen so far. But in the second one, the parameter `n` is defined when the function is called, so the environment of the call to filter contains `n`.
Notice how the second function is a generalization of the first one. This is something we wouldn't be able to accomplish without closures, and it's just one example. 
In general, we can say that a function that has an access to "context" allows for much more versatility.
### Closure idiom: function composition
Using closures, we can compose functions to create new functions - just like in math.

Here's an example of how we can define such a function:
```sml
fun compose(f, g) = fn x => f (g x)
```

Notice how this kind of function **can't** be done without closures.
That's because the inner function is defined when `compose` is called, and at that point it has `f` and `g` in its environment, allowing it to define a closure to compose them at each call. 
Under dynamic scope, we'd have something very different: a function that calls 2 functions `f` and `g` every time it is called. Those would not be the `f` and `g` passed in as arguments to compose, but functions called `f` and `g` in the environment where the new function was called.

Function composition is very common in programming.
However, as we've seen, using closures we can make defining them much more powerful.

SML has syntactic sugar for defining function composition using the infix operator `o`. For example:
```sml
(* No syntactic sugar *)
fun sqrt_of_abs i = Math.sqrt(Real.fromInt (abs i)) 
(*With syntactic sugar - using the o operator *)
val sqrt_of_abs = Math.sqrt o Real.fromInt o abs
```

This is probably the most useful form of function composition, but we can compose functions in different ways. for example:
```sml
fun backup(f, g) =
	fn x => case f x of
				NONE => g x
			  | SOME y => y
```
### Closure idiom: currying
We've seen that in SML, every function takes exactly 1 argument, and so far we've used tuples for creating "multi-argument" functions. Currying is a different way of doing so, using closures, and although it can seem awkward at first, it is in fact very elegant and convenient.
#### Currying
The basic idea is using one function's argument as a way of extending another function's environment. 
For example:
```sml
val sorted3 = fn x => fn y => fn z => z >= y andalso y >= x
```
calling `sorted3` will result in a closure where `x` is defined. 
Calling that closure will result in another closure where `y` is defined.
The final closure has both `x` and `y` in its environment, and when called, it also defines `z` and computes the result of the inner expression.

So, the result of `sorted3 4 5 6` (which is the same as `((sorted3 4) 5) 6` - parentheses are optional here) is the result of the expression `6 >= 5 andalso 5 >= 4` which is `true`.

SML has syntactic sugar for defining curried arguments, by separating the arguments with spaces, so the function could be rewritten as:
```sml
fun sorted3 x y z = z >= y andalso y >= x
```
#### Partial Application
The benefit of using currying in defining multi-argument functions is that it allows us to create new functions by supplying only some of a function's arguments, essentially creating more specific functions from a more general one.
This idea is called *Partial Application*, and its often used in conjugation with higher-order functions:
```sml
fun sum1 xs = fold (fn (x,y) => x+y) 0 xs
val sum2 = fold (fn (x,y) => x+y) 0
```
Here, `sum2` uses partial application to define summing as a specific way of using fold. `List.fold` is the implementation of fold for lists in the standard SML library, and it uses currying (along with many other functions in the standard library) because of how convenient partial application is.

Partial application is not useful only for higher-order functions. 
For example, here we define a range function that creates a list of consecutive integers, then use partial application to define a function that created a list of integers from 1 to `n`.
```sml
fun range i j = if i > j then [] else i :: range (i+1) j
val countup = range 1
```
#### Currying and Uncurrying
Using function composition, we can convert between curried and uncurried functions, or swap the order of arguments in a curried function, depending on what we need:
```sml
fun other_curry f x y = f y x
fun curry f x y = f (x,y)
fun uncurry f (x,y) = f x y
```

### Mutation in SML
Mutation is sometimes useful, even essential, which is why functional programming doesn't completely prevents it - just greatly limits it. Mutation makes sense where the natural way of modelling the program is to update something so that all users of that state can see the change (We'll see an example soon).
functional programming limits mutation, and in SML this is done by using a special kind of type called `ref`. Most other things in SML **cannot** be mutated.
We create a `ref` `r` by putting the keyword `ref` before an expression. We get `r`'s content with `!r` and update it with `r := e`.

Example:
```sml
val x1 = ref 0
val x2 = x1 (* x1 and x2 refer to the same reference *)
val _ = x1 := 1
val y = !x1 - !x2 (* y is 0 *)
```

### Closure idiom: Callbacks
Callbacks are a common idiom in certain kinds of programs, such as GUI programs.
The key idea is to register "clients" so that we call them when a certain event happens, like a button press.
While closures are not strictly necessary for callbacks, they can be used to extend the idea and give each client a "context", or a private state, in which it operates (OOP languages implements the same thing with objects instead). 
Even better is the fact that functions don't need to type-check their environments to match that of a function they are passed to, so the callback library doesn't have to "care" or "know" about whether and how the passed functions use closures.

Here we'll demonstrate a simple, bare-bones implementation of callbacks in SML using mutation (which is useful here, as it allows us to update the state which keeps track of all the clients), and then see how it can be used with closures.

```sml
val cbs : (int -> unit) list ref = ref []
fun onKeyEvent f = cbs := f::(!cbs) (* The only "public" binding *)
fun onEvent i =
	let fun loop fs =
		case fs of
			[] => ()
		  | f::fs’ => (f i; loop fs’)
	in loop (!cbs) end
```

`cbs` is the mutable variable that keeps track of events. we update it with `onKeyEvent`, which adds a function `f` to `cbs`.
Once an event happens, the function `onEvent` is called.
We haven't shown here how to attach `onEvent` to an actual event in SML (here it is simulating a key press), as that's irrelevant and beyond the scope of this example. What matters is that `onEvent` loops through all the clients in `cbs` and calls each of them, passing in which key was pressed.

Here are 2 examples of clients that uses closures:
```sml
val timesPressed = ref 0
val _ = onKeyEvent (fn _ => timesPressed := (!timesPressed) + 1)

fun printIfPressed i =
	onKeyEvent (fn j => 
		if i=j
		then print ("you pressed " ^ Int.toString i ^ "\n")
		else ())
```

The first function discards the actual key pressed. It keeps track of the number of times a key was pressed with `timesPressed` which is initialised to `ref 0`. Each call would update the `ref` by 1. `timesPressed` is in the closure's environment, and `onKeyEvent` doesn't know about it - but the client does.

`printIfPressed` takes a key `i` and registers a new client which prints a message if `i` was pressed. Here, too, `i` is in the closure's context, and is totally unrelated to `onKeyEvent` itself.