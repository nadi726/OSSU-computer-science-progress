We've studied Functional Programming in both statically typed and dynamically typed languages, and OOP in a dynamically typed language.
Ideally we'd now introduce a statically typed OOP language, but doing so is out of scope of this course and would complicate the discussion - so we'll study static-typing without relating it too closely to a language, focusing on concepts more critical to OOP.

In OOP languages, the main goal of a type system is to prevent "method missing" errors.
OOP languages with a type system, especially modern languages, often have support for generics, but they get most of their flexibility from a different semantic: the idea of *subtype polymorphism*, or *subtyping*. Subtyping integrates really well with inheritance and polymorphism.
So, instead of studying subtyping in the context of an OOP language, we'll start by using a made-up language that looks similar to SML and has subtyping.
# A made up language
Our language has records with mutable fields.
The evaluation and type-checking rules are largely similar to SML's, with the addition of mutable fields: `e1.f = e2` sets the field `f` of `e1` to have the value of the result of evaluating `e2`, and it doesn't type check if `f` doesn't exist in `e1` or if the type of `f` is different to the type of the result of evaluating `e2`.
# Subtyping
## Motivation
The motivation for subtyping comes from the fact that when a type `t1` has all of the information of a type `t2`, but also some extra information, it is perfectly fine to use it instead of `t2`, but our current type system doesn't allow it.
For example: 
```sml
fun distToOrigin (p:{x:real,y:real}) =
	Math.sqrt(p.x*p.x + p.y*p.y)
val c : {x:real,y:real,color:string} = {x=3.0, y=4.0, color="green"}
val five : real = distToOrigin(c)
```
Here we'd like to use `c` as an argument to the function - it makes sense and doesn't introduce any errors.
But our type-system doesn't allow it: the type of `c` is `{c:real, y:real, color:string}` which is different from `p`, which doesn't have the `color` field.
## introducing subtyping
To solve this we'll introduce subtyping in such a way that it doesn't modify any existing type checking rules:
If a value `e` has a type `t1` that is a subtype of a type `t2` then `t1` also has the type `t2`. We write this as `t1 <: t2`.
Now we have to add rules for deciding when one type is a subtype of another, and we have to do it in such a way that it doesn't break our type system. Turns out there are 4 (useful) rules we can add in this way, with the first 2 rules only being relevant to records in our language:
* "width" subtyping: One record is a subtype of another if it has all the fields of the other record(as well as their types) and also additional fields.
* Permeability: The order of fields in a supertype does not matter.
* Transitivity: If `t1 :> t2` and `t2 :> t3` then `t1 :> t3`.
* Reflexivity: every type is a subtype of itself.
### "Depth" subtyping
Something that seems like a natural addition to our subtyping rules but actually breaks our current type system is depth subtyping.
Depth subtyping means that if a field `f` with type `ta` is a subtype of a field `f` with type `tb`, then:
`{f1:t1,...,f:ta,...,fn:tn} <: {f1:t1,...,f:tb,...,fn:tn}`.
It turns out that because of mutability, this rule breaks our type-system.
If we mutate an expression of the supposed subtype, by mutating the field with "depth" subtyping, thinking we were modifying the supertype, we will end up omitting information that is specific to the subtype.
For example:
```sml
fun setToOrigin (c:{center:{x:real,y:real}, r:real})=
	c.center = {x=0.0, y=0.0}
val sphere:{center:{x:real,y:real,z:real}, r:real}) = 
	{center={x=3.0,y=4.0,z=0.0}, r=1.0}
val _ = setToOrigin(sphere)
val _ = sphere.center.z
```
If we allow depth subtyping, this program will type-check, but raise an error, because the last expression doesn't actually has a field `z`, although the type of `sphere.center` does!
This problem only occurs because of having both mutation and depth subtyping; Removing any one of those will make our type system sound again.
## Function subtyping
Function subtyping does not mean using subtyping on the arguments. That's just regular subtyping, and we don't need new rules for that.
Instead, it means that the function itself is a subtype of another function.
A function's type has 2 parts: the argument type and the return type. Let's break this down to 2 parts accordingly, looking at how function subtyping can work in the context of functions with different return types or with different arguments types.
We'll look at 2 functions, `f` and `g`, where: `(f: t1 -> t2) :> (g: t3 -> t4)` and see under what conditions they satisfy the subtyping without reaching any contradictions or breaking the type system.
### Return types
Suppose `f` returns additional information to whatever it is that is using `f` instead of `g` (such as an argument in an higher-order function), this information is simply ignored - it does not "harm" the caller in any way. Conversely, if `f` returns **less** information, it may omit something we need. Therefore, if `t2 :> t4` then `f :> g`. Another way to say this is that return types are *covariant*, which means that they work just like how "regular" subtyping works.

For example, consider this function, which takes another function as an argument:
```sml
fun distMoved (f : {x:real,y:real}->{x:real,y:real},
p : {x:real,y:real}) =
	let val p2 : {x:real,y:real} = f p
		val dx : real = p2.x - p.x
		val dy : real = p2.y - p.y
	in Math.sqrt(dx*dx + dy*dy) end
```
If we supply this function, for example, the program should still work as expected, because the additional information is simply ignored:
```sml
fun flipGreen p = {x=~p.x, y=~p.y, color="green"}
val d = distMoved(flipGreen, {x=3.0, y=4.0})
```
### Argument types
Suppose `f` requires more information instead. Now, since the caller is only assuming it needs to supply the information `g` needs, we'll get a field/argument missing error. Therefore it cannot be that `t1 :> t3` (and `t1` is different than `t3`). However, it turns out that the opposite is true. If `f` needs **less** arguments, or, in other words, needs less information, then assuming `f` is `g` and supplying all that "extra" information is fine; we'll just ignore it.
Therefore, `t3 :> t1`. Another way to say this is that argument types are *contravariant*, which means that they work opposite to how "regular" subtyping works.

To continue the example from before, this function should not typecheck, as it assumes the record has an argument with field `color`, which it doesn't:
```sml
fun flipIfGreen p =
	if p.color = "green"
	then {x=~p.x, y=~p.y}
	else {x=p.x, y=p.y}
val d = distMoved(flipIfGreen, {x=3.0, y=4.0})
```
But this function should typecheck, as it needs less information than the information `f` supplies, and just ignores the rest(the `y` field):
```sml
fun flipX_Y0 p = {x=~p.x, y=0.0}
val d = distMoved(flipX_Y0, {x=3.0, y=4.0})
```
## In general
A function `f` that supplies both conditions (`t2 :> t4` and `t3 :> t1`), is a subtype of `g`. Note that together with reflexivity, this also includes cases where we have different types for only one part of the function, such as `(f: t1 -> t) :> (g: t3 -> t)`.
Therefore we can combine both propositions into the following one:
*For two functions, `f` and `g`, if `t2 :> t4` and `t3 :> t1` then `f :> g`.*
# Subtyping in OOP
Subtyping in OOP is mostly the same as subtyping in the more general sense we've discussed, with some more restrictions and design decisions.
In OOP languages, the class name is the type. An interface also introduces a new type. The subclass, and a class that implements an interface, is the subtype, but **those are the only subtypes**. Which means that even if 2 classes have exactly the same fields and methods, they do not have the same type unless explicitly stated via inheritance.

We could think of a class type as a record with 2 kinds of values: fields, which are mutable, and methods, which are immutable and have a reference to `this`.

A subclass can add more fields and method, as well as override a method with covariant return types.
Methods are generally like functions, but in Java and c# the language designers decided that a subclass's method with contravariant arguments cannot override an existing method, but instead introduce a new method with the same name. Overriding methods can only use covariant return types.

One thing that OOP languages tend to purposefully confuse but is important to notice is that **classes and types are not the same thing**.
A class defines an object's **behavior**. A type is the object's **specification** - what names of fields and method it needs to have and with what types.
Similarly, subclasses extend and modify a class's behavior, while subtyping places more restrictions on the object.
## Self/this is special
It turns out that, if we think about `self` as a kind of argument that gets automatically supplied to methods, it is special in the context of subtyping: If class `B` is a subclass of `A`, then `self` is covariant. That is because `self` can access all the new information provided by `B`, such as new fields, as long as its inside a method defined by `B`. The reason this works is that a method cannot choose what argument to get that satisfies the type-checking: it always gets the object itself, meaning `self` never changes inside of a class definition.

# Generics versus subtyping
Generics and subtyping are both ways of making a type system more expressive. But those tools don't really "compete" against each other - they're good at different things, and can actually complement each other to create even more expressive type systems.
## Generics
In general, generics are good at situations where you have code that can work for many types of things, but those have to be of the same type.
Notable use cases include:
* Types for functions that combine other functions
* Functions that operate over generic collections, such as a length function which should compute the length of any kind of a given list.

Because of how useful they are, modern OOP languages tend to have them too.

Generally speaking, you shouldn't use subtyping in situations where generics are good.
Subtyping doesn't express those kind of ideas as well as generics, and you'll end up permitting more than you should, and thus avoid static checking and the benefits it provides. 
For example: say you want to implement a map function that applies `f` to each element of a list. with subtyping, we don't have any way to restrict both the given list and `f` to having the same type without giving a specific type. Therefore we'd either have to restrict map to only one type or give up on static checking and use `Object`.
### Subtyping
Subtyping is good in situations where you have some code that may also have some extra "stuff", but that "stuff" may be irrelevant to other parts of the code.
A common example is in a GUI, where every component has certain properties shared by other components, like being on the screen, having a certain theme etc.
Without subtyping we won't have a way to "share" those properties between components - at least not in a natural way.
Doing so with generics will force us to use some awkward workaround, like in the previous example.
### Bounded polymorphism: combining Generics and Subtyping
Generics and subtyping can be combined together to allow for even more expressiveness, using what is known as *Bounded Polymorphism*.
The idea is that we can use generics to make something work for multiple types, as long as its the same type each time, then add subtyping to place certain restrictions on the given type and thus assume it has desired properties - such as certain fields and method. Basically, we'll say that the type should be: "any type of `t1` that is a subtype of `t2`".