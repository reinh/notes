---
title: Diff Lists, Cont, Yoneda, and Free Monad Optimizations
---

<p class="lead">
What do [difference lists][difflist], [continuations], the [Yoneda lemma][yoneda], and the [Codensity trick][codensity] have in common?
</p>

[difflist]: https://wiki.haskell.org/Difference_list
[continuations]: https://en.wikibooks.org/wiki/Haskell/Continuation_passing_style
[yoneda]: https://www.fpcomplete.com/user/bartosz/understanding-yoneda
[codensity]: http://comonad.com/reader/2011/free-monads-for-less/

A continuation in Haskell can be represented with the following type:

```haskell
newtype Cont r a = Cont { runCont :: (a -> r) -> r }
```

This type seems to be daunting to newer Haskell developers.
How would you construct such a value?
How would you *use* it once you've constructed it?
How does this represent a continuation? What even is a continuation?

Let's take a step back and think about what [continuation passing][CPS] does in simpler terms:
A continuation is a function that is applied to the result of another computation.
Continuation passing then inverts the usual control flow, where functions take values and provide values,
by having functions take *another function*, the continuation, which will be *provided* with the value.
This CPS transformation then is some sort of inversion of function application, so let's just try that and see what happens:

[CPS]: http://en.wikibooks.org/wiki/Haskell/Continuation_passing_style

```haskell
:t flip ($)
a -> (a -> b) -> b

```

By flipping function application, then, we get a function where you first supply a value
and *then* supply some function, or *continuation*, to be applied to the value.
Let's try this out:

```haskell
k = flip ($) 3

main = do
  print $ k succ
  print $ k show
  print $ k sqrt
```

prints:

```
4
"3"
1.7320508075688772
```

So `k` is a *suspended computation* that will apply the value `3` to
any continuation that is passed to it. This is great, but what can we
*do* with it? Let's start with a problem first tackled by
@hughes1986novel, the list concatenation problem. The problem is this:
constructing a list by repeatedly concatenating onto the end has
$O(2^n)$ performance. This is because each new concatenation must
traverse the entire first list before it can add the second list.

The definition of `(++)` is

```haskell
[]     ++ ys  = ys
(x:xs) ++ ys  = x : xs ++ ys
```

and the evaluation of `("foo" ++ "bar") ++ "bizz"` goes as follows:

```haskell
  ("foo" ++ "bar") ++ "bizz"
= ('f' : "oo" ++ "bar") ++ "bizz"
= ('f' : 'o' : "o" ++ "bar") ++ "bizz"
= ('f' : 'o' : 'o' : [] ++ "bar") ++ "bizz"
= ('f' : 'o' : 'o' : "bar") ++ "bizz"
= "foobar" ++ "bizz"
= 'f' : "oobar" ++ "bizz"
= ...
```

and then the entire string `"foobar"` is traversed again to add `"bizz"`.
The solution is to find some way to reassociate the concatenations so that they associate to the right.
List concatenation is defined as right-associative because this gives linear performance:

```haskell
  "foo" ++ ("bar" ++ "bizz")
= 'f' : "oo" ++ ("bar" ++ "bizz")
= 'f' : 'o' : "o" ++ ("bar" ++ "bizz")
= 'f' : 'o' : 'o' : [] ++ ("bar" ++ "bizz")
= 'f' : 'o' : 'o' : ("bar" ++ "bizz")
= 'f' : 'o' : 'o' : ('b' : "ar" ++ "bizz")
= 'f' : 'o' : 'o' : ('b' : 'a' : "r" ++ "bizz")
= 'f' : 'o' : 'o' : ('b' : 'a' : 'r' : [] ++ "bizz")
= 'f' : 'o' : 'o' : ('b' : 'a' : 'r' : "bizz")
= "foobarbizz"
```

Hughes' novel representation of lists is a *CPS transform*: Lists represented as *continuations*:

```haskell
rep    :: [a] -> ([a] -> [a])
rep s  = (s++)
```

This *representation* can be transformed back into the underlying abstract data type, or *abstraction*, by applying it to the empty list:

```haskell
abs    :: ([a] -> [a]) -> [a]
abs f  = f []
```

The choice of empty list is not arbitrary: `rep` and `abs` witness an isomorphism between the *free monoid*, a.k.a. `[a]`, and the *endomorphism monoid*, `a -> a`. These monoids are given as:

```haskell
instance Monoid [] where
  mempty   = []
  mappend  = (++)

newtype Endo a = Endo { appEndo :: (a -> a) }

instance Monoid Endo where
  mempty   = id
  mappend  = (.)
```

This means that `rep` and `abs` are *monoid morphisms*, which implies that the equivalent to string concatenation in this CPS representation is function composition, and indeed it is so:

```haskell
> abs $ rep "foo" . rep "bar" . rep "bizz"
"foobarbiz"
```

---
