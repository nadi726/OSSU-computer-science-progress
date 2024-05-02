# Racket's syntax
Racket is a modern programming language belonging to the Lisp family of programming languages, and is a descendant of Scheme.
Racket is a dynamically-typed functional language(in the sense we have discussed) and thus shares many similarities with SML, such as closures, limit of mutation and more.

We won't fully discuss the syntax of racket here, but here's a basic overview:
adding binding to the top level environment is done by `(define x e)` where `x` is the name and `e` is an expression which is evaluated to the value `x` is bound to.

Anonymous functions are defined by `(lambda (x1 .. xn) e)` where `x1` to `xn` are the arguments. Unlike SML, in racket multiple arguments are really multiple arguments, so they all has to be supplied. However, many functions can take any number of arguments.

We can bind lambda functions like any other expression, and the corresponding name is in scope of the lambda. Therefore there is no need in Racket for a more traditional kind of function definition, although there's syntactic sugar for this:
```scheme
(* defining a recursive function with lambda *)
(define pow
	(lambda (x y)
		(if (= y 0)
			1
			(* x (pow x (- y 1)))))

(* using syntactic sugar*)
(define (pow x y)
	(if (= y 0)
		1
		(* x (pow x (- y 1))))
```

Racket has native list support like SML.
We use `'()` or preferably `null` for the empty list.
`cons` defines a new pair, while `list` can be used to convert a series of arguments into a list. Because there is no type system, lists do not have to hold only arguments of the same type.

Racket's syntax is fundamentally very simple.
Everything is either:
1. An atom - a primitive like a number, boolean, etc, or an *identifier* - a binding or a special syntax like *if*.
2. a sequence of things in parenthesis.

The first element in a sequence of parenthesis defines what the rest means. The first element is either a function - in which case the other elements are the function's arguments - or a *special form*, like the lambda we've seen before.
A function first evaluates all its arguments, while the evaluating rules for special forms differ.

While this syntax is unusual, it has certain advantages. It allows the code to be unambiguous (think of `1 + 2 * 3` - how would you evaluate this?).
This makes the program easier to parse into an abstract syntax tree and makes the somewhat-artificial distinction between code and data more blurry.
While those are more advanced topics that won't be covered now, we will see some implications of this later on.

## If & cond
`If` and `cond` are special forms with a similar functionality to conditionals in other languages.
They look like this:
```scheme
(if x
	e1
	e2)

(cond [x e1]
	  [y e2])
```
An `if` evaluates its first argument. if it is true, it evaluates the second argument and that's the result of the expression. If it is false, it evaluates the third argument and that's the result of the expression.
`cond` is like an `if`, but it is built up of cases.
In each case there's a condition and an expression. If the condition evaluates to false, it goes to the next case without evaluating the expression. Once we reach a true value, the corresponding expression is evaluated and that's the result of cond.

Square brackets can be used anywhere instead of parenthesis, but as a matter of style they are only used in specific cases like cond branches.

# Bindings in racket
## Local bindings
There are different ways for defining local bindings with different semantics each.
The first one is `let`:
```scheme
(let ([x1 e1]
	  [x2 e2]
	  ...
	  [xn en])
	  e)
```
A `let` expressions binds `x1...xn` to the result of the corresponding expressions and extends the environment of `e` with those bindings.
The important thing here is that the bindings are only in the environment of `e`. A binding can't refer to any other binding that it is defined together with, no matter if it comes before or after itself.
This is useful for example if you want to swap variables defined outside of the `let`, or more generally, if your code doesn't require more sophisticated semantics for local bindings.

A `let*` is almost the same, but here later bindings are each defined in an environment that is extended with the previous bindings (like `let` in SML), and thus can access those bindings. However, a binding can't refer to itself or to later bindings.

A `letrec` is like `let*`, but bindings  can also refer to themselves and to later bindings. The bindings are still evaluated in order, and therefore doing something like this raises a runtime error:
```scheme
(define (bad-letrec x)
	(letrec ([y z]
			 [z 13])
		(if x y z)))
```

Another way of defining local bindings is by using a `define` locally, inside of a function body for example.
There are certain limit on where you can put a local `define`(for example on the beginning of a function body), but oftentimes in idiomatic Racket this is used more than `let` expressions.

## top-level bindings
In SML, the top-level environment's semantic was that of a Racket's `let*`, which means that bindings can't refer to later bindings.
In racket, however, the semantics are that of a `letrec`.
This means that you can refer to later bindings, but also makes for some caveats:
1. You can't define a binding more than once at top level, as that wouldn't make sense - how should Racket decide which one to use? 
2.  Therefore there is no shadowing at top level, unless bindings come from elsewhere (racket's standard library or other files), in which case they can be shadowed.
3. Like with `letrec`, trying to evaluate a binding earlier that where it is defined raises an error.

## Mutability
While racket is a functional language which discourages mutation, it still allows bindings to be mutated.
The expression `(set! x e)` changes the value of `x` to the value of evaluating `e`.

As is the problem with mutation, you have to keep track of where bindings were mutated in order to know the value of all expressions that refer to those bindings.

One particular worrisome case is when a binding used inside a function's body is modified elsewhere:
```scheme
(define b 3)
(define f (lambda (x) (* 1 (+ x b))))
...
(set! b 5)
```
In such cases, there's a general technique important to know about:
*If something might get mutated and you need the old value, make a copy before the mutation can occur.*
Here's how you do it in racket with this example:
```scheme
(define f
	(let ([b b])
	(lambda (x) (* 1 (+ x b)))))
```

But even this might not be enough. for example, the `+` and `*` symbols can be bound to something else.
The compromise that racket make is that if a `set!` has not been used on a binding in the module it was defined, then that binding is immutable. Therefore it is relatively easy to keep track of what was mutated and what not. All predefined functions, like `+`, are therefore immutable.

## cons and mcons
#### cons
A `cons` creates a pair of elements. As per Racket's dynamic typing, those can be of any type. A list in racket is really just an arbitrarily nested pair of pairs, where the first element of each pair is an element of the list and the second is either a pair, containing the rest of the list, or `null`, which signifies the end of the list.

Pair cells that don't define a list are also called *improper lists*. They can be good for defining *each-of* types, and using them instead of lists is discouraged. Generally speaking, trying to pass an improper list to a library function that operates on lists will result in an error.
We check for lists with the `list?` primitive and for a pairs with the `pair?` primitive.
We use `car` for accessing the first element of a pair and `cdr` for the second element.
#### mcons
In Racket, pairs are immutable.
If we wan't mutable pairs, there's a different construct called `mcons`.
`mcons` defines a mutable pair, and comes with related primitives for checking for an `mcons`, accessing its elements and modifying them.
Specifically:
- `set-mcar!` takes a mutable pair and modifies its first element.
- `set-mcdr!` takes a mutable pair and modifies its second element.

# Delayed evaluation
##  motive
Language constructs have to take into account *evaluation rules*.
Evaluation rules means where, and in what way, are the expressions evaluated.
For example, in most languages, including Racket, the evaluation rules for evaluating a function call is: Evaluate all arguments, and then evaluate the function body.
The evaluation rules for `if` are different, as we've seen above.
## Thunks
The implication of that is that this function has different semantics from an `if`, causing it to call a recursive call indefinitely:
```scheme
(define (my-if-bad x y z) (if x y z))

(define (factorial-wrong x)
	(my-if-bad (= x 0)
				1
				(* x (factorial-wrong (- x 1)))))
```
The key point is that sometimes, for various reasons, we might want to delay an evaluation of an expression.
We can use the fact that function definitions are not evaluated until called to achieve this, by wrapping the expression in a lambda:
```scheme
(define (my-if x y z) (if x (y) (z)))

(define (factorial x)
	(my-if (= x 0)
			(lambda () 1)
			(lambda () (* x (factorial (- x 1))))))
```

This technique of using a zero-argument function to delay evaluation is called a *thunk*.
## Lazy evaluation
Sometimes we have a computation that we need to perform zero-or-more times. If we use a thunk each time, we may needlessly repeat the computation. If we don't, we'll perform the computation even if we don't need to.

To solve this problem we can use an idiom, known by a few different names: *lazy evaluation, promises, call-by-need.*
The idea is to use a mutable pair to store whether or not the value was computed, and a thunk or a value depending on the case.
Here's a simple implementation:
```scheme
(define (my-delay f)
	(mcons #f f))

(define (my-force th)
	(if (mcar th)
		(mcdr th)
	(begin (set-mcar! th #t)
		   (set-mcdr! th ((mcdr th)))
		   (mcdr th))))
```
"Delaying" means creating a new such pair, while "force" is the process of retrieving the correct value and mutating the pair in case it needs to.

One way of using this is by passing this instead of a thunk.
For example, suppose we have a function that expects a thunk as argument, and we want to use lazy evaluation:
```scheme
 (f (let ([x (my-delay (lambda () e))]) (lambda () (my-force x)))
```

Another is to write a function in such a way that it expects a *delay*.
this way, we can call it as:
```scheme
(f (my-delay (lambda () e)))
```
The function may look like this:
```scheme
(define (f x-promise)
  (if stuff?
	  (my-force x-promise)
	  (* 4 (my-force x-promise))))
```
## Streams
*Streams* are infinite sequence of data, where the next piece of data is always generated on-demand by the current piece of data.
Streams are used everywhere, from file I/O to servers and GUIs.
One way to code up a stream is by using *thunking*.
for example:
```scheme
(define nats
	(letrec ([f (lambda (x) (cons x (lambda () (f (+ x 1)))))])
	  (lambda () (f 1))))
```

Streams allow us separation of concerns: one part of the code is responsible for generating the infinite sequence of data, while the other is responsible for processing it or doing things with it as it comes.

Seeing as how a stream is always generated from a starting value, and an expression that takes the current value and computes it using some sort of function, we can abstract out that process with a higher-order function:
```scheme
(define (stream-maker fn arg)
	(letrec ([f (lambda (x)
			(cons x (lambda () (f (fn x arg)))))])
		(lambda () (f arg))))

(define nats (stream-maker + 1))
```
## Memoization
Another idiom that uses lazy evaluation but does not use thunks is  *memoization*.
Memoization means that, if a function does not have side effects and always returns the same result for the same arguments, we can store those results in some sort of table and then look them up instead of re-computing the function with the same arguments each time we call it.

# Macros
Macros is a language feature that lets us define new syntax for the language in terms of existing syntax - in other words, create new syntactic sugar.
Macros are replaced with the actual language syntax before any of the other steps of computing the code are executed - in some sort of pre-processing stage.

Macros are powerful and convenient because they allow us to adapt the language to our specific needs, but we have to take into consideration that:
1. Macros can often break our code more easily than more conventional methods of achieving what we want. This is why they are often discouraged, and we should be very careful not to abuse them and use them only in places where they are really the best solution.
2. Each language with macro support has a different *macro system*. Racket's *macro system* is really well-designed and better than most, but in other languages macros are often more limited and are easier to introduce bugs with.

One example where we may want to define a macro in Racket is to let the user define a delay without having to supply the thunk. A use of such a macro will look like this: ```(my-delay e)``` and will transform to: ```(mcons #f (lambda () e))```
