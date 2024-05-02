# Datatype programming without Datatypes
In SML, we made our own one-of types by making datatypes bindings.
As Racket is dynamically typed, we can't really do the same thing.
Partly because **we don't need to** - the lack of a type system means that there are no restrictions on how we use and combine types.
Instead, we can define our own one-of types by simply deciding (and often document this with code) on methods for representing, accessing and (in the case of mutation) modifying the underlying data.

With simpler, non-recursive kinds of data we can just use something like a list to store all the values.
Unlike SML, where lists are polymorphic and therefore can hold only one type of data, in Racket we can just put any value we want in a list and address all possibilities in our code.
For example, say we want to have a list that can store either an `int` or a `string` and add together all the numbers and all the lengths of the strings.
In SML, we'll have to use a datatype binding to define a one-of type that can be either an `int` or `string`. In Racket we can just treat a given list as if its a list of the required "type":
```scheme
(define (funny-sum xs)
	(cond [(null? xs) 0]
	[(number? (car xs)) (+ (car xs) (funny-sum (cdr xs)))]
	[(string? (car xs)) (+ (string-length (car xs)) (funny-sum (cdr xs)))]
	[#t (error "expected number or string")]))
```
What makes this possible is both the dynamic nature of Racket and the fact that we can check the type of a value at run-time using primitives like `string?`

For more sophisticated, recursive types we'll have to decide beforehand on methods for handling the data.
We'll use a more fleshed-out example to demonstrate this concept.
We'll do this by comparing an SML program to 2 possible implementations in Racket. The second one is better, but the first is important for understanding the process and doesn't introduce any new language constructs.
## in SML
```sml
datatype exp = Const of int | Negate of exp | Add of exp * exp | Multiply of exp * exp

exception Error of string
fun eval_exp_new e =
	let
		fun get_int e =
			case e of
				  Const i => i
				| _ => raise (Error "expected Const result")
	in
		case e of
			Const _ => e (* notice we return the entire exp here *)
			| Negate e2 => Const (~ (get_int (eval_exp_new e2)))
			| Add(e1,e2) => Const ((get_int (eval_exp_new e1)) + (get_int (eval_exp_new e2)))
			| Multiply(e1,e2) => Const ((get_int (eval_exp_new e1)) * (get_int (eval_exp_new e2)))
	en
```
What we have is a datatype which describes a little language for representing arithmetic expressions, and a function to evaluate such an expression.
We want to return a value of type `exp` from the function because this little language is really meant to be expanded - right now, the only value we have is an `int`, but we may later want to also have different kinds of values like a `bool`.
## First approach: using lists
We can use a list to represent the different kinds of expressions an `exp` can be, and define methods for constructing them, accessing their underlying values, and testing what kind of expression it is.
One way of defining such lists is by making the first element some sort of identifier, like a string representing the expression's name, while the rest of the list holds the values:
```scheme
; helper functions for constructing
(define (Const i) (list ’Const i))
(define (Negate e) (list ’Negate e))
(define (Add e1 e2) (list ’Add e1 e2))
(define (Multiply e1 e2) (list ’Multiply e1 e2))
; helper functions for testing
(define (Const? x) (eq? (car x) ’Const))
(define (Negate? x) (eq? (car x) ’Negate))
(define (Add? x) (eq? (car x) ’Add))
(define (Multiply? x) (eq? (car x) ’Multiply))
; helper functions for accessing
(define (Const-int e) (car (cdr e)))
(define (Negate-e e) (car (cdr e)))
(define (Add-e1 e) (car (cdr e)))
(define (Add-e2 e) (car (cdr (cdr e))))
(define (Multiply-e1 e) (car (cdr e)))
(define (Multiply-e2 e) (car (cdr (cdr e))))
```

Now we can write a function to evaluate such an expression:
```scheme
(define (eval-exp e)
	(cond [(Const? e) e] ; note returning an exp, not a number
		 [(Negate? e) (Const (- (Const-int (eval-exp (Negate-e e)))))]
		 [(Add? e) (let ([v1 (Const-int (eval-exp (Add-e1 e)))]
	 	 [v2 (Const-int (eval-exp (Add-e2 e)))]) 
		 	 (Const (+ v1 v2)))]
		 [(Multiply? e) (let ([v1 (Const-int (eval-exp (Multiply-e1 e)))]
							  [v2 (Const-int (eval-exp (Multiply-e2 e)))])
							(Const (* v1 v2)))]
		[#t (error "eval-exp expected an exp")]))
```

And create such expressions and evaluate them:
```scheme
(define test-exp (Multiply (Negate (Add (Const 2) (Const 2))) (Const 7)))
(define test-ans (eval-exp test-exp)) ; Ans: (list 'Const -28)
```

The important distinction between the dynamic approach and the SML approach is that here there is nothing in the program that really "knows" about our type definitions. They are just things that we, the programmer, decided about, and (hopefully) enforce and document.
## Second approach: using structs
A `struct` is a Racket construct that is used to piece together data under a new, single type, basically creating an each-of type.
It takes care of defining the equivalent functions to those we defined manually in the previous approach: each struct introduces to the environment functions for creating new instances of the struct, accessing its element and checking whether a given expression is of the same type of that struct.

In our example, struct definitions will look like this:
```scheme
(struct const (int) #:transparent)
(struct negate (e) #:transparent)
(struct add (e1 e2) #:transparent)
(struct multiply (e1 e2) #:transparent)
```
The first one, for example, has a function `(const e)` for creating a new instance of the struct, a function `(const? e)` for checking whether `e` is a `const`, and a function `(const-int e)` for accessing the first (and only) field of the struct.
The `#:transparent` is an optional struct attribute that makes the fields and accessors visible outside of the module that defined the struct.
There's other attributes, like `#:mutable` which makes a struct mutable and introduces corresponding functions for modifying its values.

Our function `eval-exp` function looks very similar with the struct instead of a list:
```scheme
(define (eval-exp e)
	(cond [(const? e) e] ; note returning an exp, not a number
		  [(negate? e) (const (- (const-int (eval-exp (negate-e e)))))]
		  [(add? e) (let ([v1 (const-int (eval-exp (add-e1 e)))]
						  [v2 (const-int (eval-exp (add-e2 e)))])
					  (const (+ v1 v2)))]
		  [(multiply? e) (let ([v1 (const-int (eval-exp (multiply-e1 e)))]
							   [v2 (const-int (eval-exp (multiply-e2 e)))])
							(const (* v1 v2)))]
		  [#t (error "eval-exp expected an exp")]))
```

However, the `struct` method is superior. First, because it saves us the trouble of manually defining constructors, getters and (possibly) setters for the struct. Second, because the list approach has a problem which can only be solved by something like a `struct`:
**It can't prevent breaking of abstraction.**
If, for example, someone tried to access the underlying list elements directly, or generally treat it as a list instead of the type we've defined, there's nothings preventing him from doing so.
This muddles the ground between interface and implementation and makes catching bugs harder.
On the other hand, a `struct` introduces a new type to the environment, meaning that the only type-testing function to return true given a struct instance will be the one introduced by the struct itself.
Furthermore, the only way to access or modify it is by using the `struct`'s functions.

It should be noted that from what we've seen, even with structs we can't enforce *invariants*. Racket has good ways to do that, but we won't cover them here.

# Implementing a programming language
Implementing a programming language is a valuable experience for solidifying our understanding of the concepts discussed here.
We've already introduced a small language for arithmetical expression,
and now we're going to discuss how to extend it to a full small-scale programming language, complete with variables, environment and closures.

### The typical process
The typical process of designing a language implementation is as follows:
1. Take a string of input which is the file (or multiple files) of the code in the target language. The *parser* parses this input, checking for syntax errors, and if none are found, produces an *AST*.
   (An *AST* - abstract syntax tree - is a tree data structure that is much more convenient to work with in the rest of the process.)
2. If our language has a type system or other kinds of enforcements, the AST is then checked for those and returns an error accordingly.
3. The next step depends on whether we are implementing a *compiler* or an *interpreter* for a language B.
   * An *interpreter* is a program written in a language A that takes a program in B and performs its instructions in A.
   * A *compiler* uses another language A that takes a program in B and converts it to an equivalent program in C. 
   * For either approach, A is called the *metalanguage*.
    For interpretation, B is the target language, while for compilation, B is called the source language and C the target language.

#### Two important notes:
* Modern language implementations tend to use some combination of compilation and interpretation, often involving several steps.
* It is essential to separate the idea of the language itself, the language **specification**, from language **implementation**. 
  **Interpreter versus compiler is a feature of a particular programming-language implementation, not a feature of the programming language**. C is not a "complied language", and Python is not an "interpreted language". Those are just the common language implementations.
## A sample language
Our `eval-exp` function is an example of an interpreter for a small language.
It has *expressions* (defined as structs) and one kind of *value* - a constant `const`.
There is no parsing, as the fact that we're using Racket constructors to represent the language means we're already working in terms of AST.
There is also no type-checking, as the language doesn't have a type system.
Therefore one of the benefits of writing such an *embedded* language is not having to write a parser. There are also other benefits, one of which we'll see later.
### Extending the language
Let's introduce more values and expressions:
```scheme
(struct bool (b) #:transparent) ; b should hold #t or #f
(struct if-then-else (e1 e2 e3) #:transparent) ; e1, e2, e3 should hold expressions
(struct eq-num (e1 e2) #:transparent) ; e1, e2 should hold expressions
```
Now we have a new value - a `bool`, and also conditionals and comparisons.

We now have to take into consideration the fact that even if an AST is "legal", as we can assume since we've skipped parsing, it may still be wrong - if it doesn't follow language semantics.
One such case is if an expression expects a certain kind of value, but is instead given another.
Our interpreter should check for this and return an error, as in this case, of the `add` expression in our langauge:
```scheme
[(add? e)
	(let ([v1 (eval-exp (add-e1 e))]
		  [v2 (eval-exp (add-e2 e))])
		(if (and (const? v1) (const? v2))
			(const (+ (const-int v1) (const-int v2)))
			(error "add applied to non-number")))]
```

### Variables and environments
In order to have variables in our language we need an environment.
The environment is represented in the metalanguage, usually using a suitable data structure with fast lookup types for efficiency. For our demonstration, we'll just use a list of pairs, each pair having a variable name and a value.

We'll have to modify `eval-exp` to include an helper function which performs all computations so far and takes the current environment as argument. The helper function serves as a trampoline, as our initial environment is always set up in the same way(we'll use an empty environment).
The environment is handled in different ways according to the expression:
* For variable lookup, we look up the variable name in the environment and return the appropriate value (or an error if not found).
* For things like `let` expressions, we pass in to the sub-expressions an appropriately modified environment.
* For every other expression, we evaluate the sub-expressions with the current environment.
### Closures
For closures, we can create a data structure that stores the environment where the closure was defined, and the function's body.
A function definition, which includes only the body, would evaluate to a closure, which interpreter would pass in the current environment to.
A function call would look like this: `(e1 e2)` 
Where `e1` should evaluate to a closure, evaluate `e2` and add it to the closure's environment, then use it to evaluate the body. 
If we want to allow recursion, we'll also need to add a variable which holds the function to the environment.

Storing all of the environment in each closure takes up a lot of memory. In a "real" implementation, we'd first scan the function's body for free variables (variables defined outside of the body), and the closure's environment will be comprised just of those variables - this way, we won't store the whole environment each time - just what we need to.
### Macros
Since we are writing our language programs in Racket, we can write Racket functions other than `eval-exp` for producing parts of the target language. 
Those functions won't evaluate the target-code, just convert it into different code, which is also valid in the target language and therefore can be evaluated with `eval-exp`.
Those functions, therefore, serve as *macros* in our new language.

Here's a simple example:
```scheme
(define (double e) ; takes language-implemented syntax and produces language-implemented syntax
	(multiply e (const 2)))
```