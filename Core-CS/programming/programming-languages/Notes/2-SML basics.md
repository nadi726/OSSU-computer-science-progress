# Introduction
An SML program is a sequence of *bindings*. A *binding* is a kind of statement which takes an *expression* and evaluates it to a *value*, then adds that to the *environment*. 
A *value* is something that isn't computed further - it is evaluated to itself, where an *expression* is either a value or something that is evaluated to a value. By environment, we really mean 2 things: *static environment* and *dynamic environment*.
# Static and Dynamic environment
- **Static environment:**
    - Represents the context of the program, as is determined by the language before the program is executed. It is static because it is determined statically, no matter what are the actual results of executing the program is and whether they change at different runs. Amongst other things, it keeps track of the **types** that we associate with the names we give to different parts of the program.
* **Dynamic environment:** 
    * this is "where things happen". It is the environment that is active at run-time, and is responsible for executing the program and handling everything, from memory to evaluating expressions. In particular, it keeps track of the values associated with the names given to different parts of the program.
## Binding process
1. **Syntax:** check the syntax to determine what kind of binding it is and its different parts.
2. **Type-checking:** using the static environment, evaluate the type of the binding. if it type-checks, add it to the environment. else, raise an error and terminate.
3. **Evaluation:** evaluate the expression to a value using the dynamic environment and assign it to the binding, then add this to the dynamic environment.
## A simple example - val binding

```sml
val x = e
```
Here, the syntax is the keyword `val`, followed by the name we want to assign a value to, followed by the equal sign, followed by the expression to be evaluated to a value.
Next, we determine the type of `x` by type-checking `e` using the static environment, and assign the type of `e` to `x`.
We then evaluate `x` by evaluating `e` using the dynamic environment, and assigning the resulting value to `x`.

An analogous process happens in all other kinds of bindings. We won't cover all of them here - only some of the important ones.
## Function binding
A function is a value. it takes arguments and uses them to evaluate an expression that is associated with the function.
### syntax:
```sml
fun f (x1 : t1, x2 : t2, ..., xn : tn) = e
```
`f` is the name of the function, `x1`-`xn` are the arguments, and `e` is the expression.
### Type checking:
type-check e in a static environment that also maps `f`, `x1`, ..., `xn` to the corresponding types. `f` is in the environment, which allows us to reference it inside of `e`(recursion).
The syntax for the function type is `(t1 * t2 * ... *tn) -> t
Where `t` is the type of `e`.
the type of `e` is determined by the static environment through a technique called *type inference*.
We then add the type of `f` to the static environment.
### Evaluation:
A function is a value. it is only evaluated when it is called, which is a different kind of expression. `f` is added to the dynamic environment and associated with `e` (and, in `e`, the dynamic environment includes `f` for recursion)
### function calls:
We evaluate a function by calling it. The syntax of a function call is `f (e1, e2, ..., en)`, the type-checking requires the types of `e1`...`en` to correspond to the types of `x1...xn`, and the resulting value has type `t`.
The evaluation rules evaluates `f, e1... en`, assigns their values to `f, x1...xn` in a dynamic environment where `f` was defined, and then evaluates `e`.
### pairs
Pair let us compound data.
* ***syntax:** ``(e1, e2)
* ***type-checking:** has type `t1 * t2`  where `t1` is the type of `e1` and `t2` the type of `e2`
* **evaluation rules:** evaluate `e1` and `e2`, the pair of the resulting values is a value.

We can actually make tuples - a sequence of an arbitrary amount of compound values, by adding more expressions inside the brackets.
We access a tuple's item by index: the first item is `#1 p` and so on.
pairs can be nested, for example: `(1, (2, 3))` has type `int*(int*int)`
### let expressions
Let expressions give us the ability to define local bindings for a given expression.
* ***syntax:** `let b1 b2... bn in e end`
* **type-checking and semantics:**
    similar to top-level bindings, we evaluate each binding in turn, and expand the corresponding environment of the next bindings, and then of e with all bindings.
    the type of a `let` is the type of `e`, and the value of a `let` is the result of evaluating `e`.

 Local bindings can improve the style(readability) but also the efficiency of our code - by avoiding repeating expensive computations.

# Lack of mutation and its benefits
In SML, there is **no way to change the value of a binding**. we can create a new binding with the same name, effectively shadowing the previous binding, but we cannot modify its content.

Functional languages, in general, advocate the idea of preventing mutation. This may seem surprising, but disallowing mutation has several important advantages. one such advantage is the fact that we don't have to worry about aliasing.

* For example:
    if we have a function that takes a list as an argument, in most languages there are 2 distinct possibilities: one is that the function changed the original list, and the other is that it returned a copy.
    In SML, thanks to no-mutation,  **it doesn't matter**, as there is no way to tell.

This means that we don't have to worry about that question as we code, and it also has great performance and memory benefits: for example, the operation `tl` for accessing the tail of a list is actually giving us an alias of the original list instead of creating a new one.