# Type inference
SML is a statically typed language, like Java and C.
However, unlike those languages, it has *type inference*.
Type inference means that the types of bindings do not always have to be stated explicitly; Instead, they can sometimes be inferred from the code itself, with varying degrees of success depending on the language and the code.
While type inference can make code more elegant and less verbose, some argue that it may make the code less obvious.

Type-checking and type inference are conceptually different processes, yet they are often implemented as one process in practice.
Type inference is not "magic"; it utilizes a clever algorithm to infer types and must be considered during language design to work effectively. For instance, a type system that accepts everything is easy to infer, as is a type system that rejects everything..
## Type inference in SML
SML has such an algorithm, and it leverages Parametric Polymorphism to get much of its power.
The main idea is this:
to use the types of previous bindings to infer the types of later ones,
Each binding's type starts as an unconstrained, "general" type.
Using the code's content, we infer what constraints are needed to be placed on the type in order for it to type-check.
At last we arrive at a specific type. If the type remains unconstrained, we assign it a type variable.
If the type couldn't be determined completely, but instead it could be of one or more different types, type inference fails (which is why, before we learned pattern matching, we sometimes had to write the types of function arguments - the type inference doesn't have enough information).
Type inference also fails if it infers a binding to be of more than one type.
Finally, we enforce the Value Restriction, which we'll get to shortly.
## The value restriction
The value restriction aims to cover a "hole" in our type system, in which certain programs type-check even through they may have the wrong types.
The issue is caused by combining refs with polymorphic types, like in this example:
```sml
val r = ref NONE (* ’a option ref *)
val _ = r := SOME "hi" (* instantiate ’a with string *)
val i = 1 + valOf(!r) (* instantiate ’a with int *)
```
SML chose to overcome this issue by giving a val binding a polymorphic type only if the expression in the val binding evaluates to a value or a variable.

# The module system
*Structures* in SML is a way of coupling together bindings.
it serves 2 purposes:
1. namespace management - each structure has its own namespace
2. Abstraction - hiding certain bindings and implementation details from outside the structure, using signatures - another language feature.

The simplest way of using modules is by just assigning a name to a series of bindings for namespace management.
The syntax for this is: ``structure StructName = struct bindings end``, where `StructName` is the structure's name and `bindings` is the series of bindings belonging to the structure.
## Namespaces
*Namespace management* is a way of organising code by coupling certain pieces of code with a given name.
This is especially important for larger programs, to make the code more readable and easier to maintain.
For example, In SML's standard library all list functions are under the `List` module. We access the map function by typing ``List.map``.
## Signatures and abstraction
*Signatures* lets us supply types for modules.
We define a strict interface the module has to follow, and everything not defined explicitly in the interface cannot be used from outside the module. This lets us define private bindings, including even private type bindings. If the structure cannot implement this interface, the type checker raises an error.

SML has various, slightly different ways of defining signatures. We'll cover only one of those.

The syntax for defining a signature is: 
`signature SignName = sig types end`
where `types` is the series of types the structure has to implement.
We supply a structure with a signature by adding `:> SignName` inside the structure definition: 
`structure StructName :> SignName = struct bindings end`

By defining a binding inside the structure and not specifying an appropriate type declaration in the signature we make it private, meaning that it cannot be used from outside of the module.
This is an important thing in software design - hiding implementation details and separating the interface from the implementation.

One such use of this is making helper functions, functions that are only used internally in the structure and should not be used anywhere else.

Another use is by making abstract types - defining a type inside of a module and only providing constructors, among with all necessary functions that handle this type, inside of the module.
For clients of the module, the type is abstract - its implementation is hidden and irrelevant.

Here's an example of using structures and signatures that covers all those points:

```sml
signature NatSig = 
	sig
		type natural
		exception BadNat
		val MakeNatural : int -> natural
		val add : natural * natural -> natural
		val toString : natural -> string
	end

structure Naturals :> NatSig =
	struct
		datatype natural = Nat of int
		exception BadNat
		
		fun MakeNatural x =
			if x < 0
			then raise BadNat (*Naturals can't be negative*)
			else Nat x
		
		fun add (x, y) =
			case (x, y) of
			    (Nat x', Nat y') => Nat(x' + y')
		
		fun toString x =
			case x of
				Nat x' => (Int.toString x')
	end
```

# Equivalence
The notion of hiding implementation details raises a very important question: what makes 2 pieces of code equivalent?
Equivalence, in our case, means that we could replace one piece of code with another and not be able to "tell the difference".
There are various definitions of "differences", and those has to do with what aspect of the code we are examining for equivalence. When studying algorithms, it might be *asymptotic complexity*(O(n) notion and the like).
In real-world applications we might care about different measures of actual performance.

Here we talk about another kind of equivalence, based on the overall semantics of the code, often used by people in the programming language design field:
A function `f` is equivalent to a function `g` if they produce the same answer and have the same side effect no matter where they are called in any program with any arguments.
Everything else is irrelevant - running time, helper functions etc.

For example, 2 list sorting functions are equivalent as long as they only take a list and sort it, not matter what kind of algorithm they use.
That definition can be similarly adapted to different pieces of code.
Here's a more precise defintion of equivalence, taking into account side effect and other considerations:

two functions when given the same argument in the same environment are equivalent if they:
1. Produce the same result (if they produce a result)
2. Have the same (non)termination behavior; i.e., if one runs forever the other must run forever
3. Mutate the same (visible-to-clients) memory in the same way.
4. Do the same input/output
5. Raise the same exceptions

It is important to note that another benefit of side-effect free programming is that it is easier to produce equivalent functions this way: taking mutation into account makes it much harder to track and reason about equivalence.