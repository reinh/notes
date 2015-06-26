---
title: Notes on Edward Kmett on Hask
tags: Kmettoverse
description: Some notes on Edward Kmett's recent talk on building Hask with Haskell.
---

<p class="lead">
Rambling and incomplete notes on [Edward Kmett][kmett]'s talk [on Hask][hask].
</p>

\newcommand{\cat}[1]{\mathcal{#1}}

[kmett]: http://comonad.com
[hask]: https://www.youtube.com/watch?v=Klwkt9oJwg0

Categories
==========

The Category typeclass represents classes of "morphisms" [^morphisms] (abstract functions)
equipped with an identity morphism and composition of morphisms.


```haskell
class Category h where
  id   :: h a a
  (.)  :: h b c -> h a b -> h a c
```

This is the usual notion of a *category* from [Category Theory][CT] with a few restrictions.
Most importantly, this definition restricts us to categories with morphisms of kind `*`.
The rest of this talk will explore the use of `PolyKinds` to construct *higher kinded* categories.
The motivation for this is the introduction of a higher order morphism known as a *natural transformation*,
and the definition of a category that makes use of them.
In order to get there, however, we'll have to introduce *functors* first.

[^morphisms]: The terms "mapping", "arrow", and "morphism" are used pretty much interchangeably in category theory.

[CT]: http://en.wikipedia.org/wiki/Category_Theory

Functors
========

A *[functor]* is a type of mapping between categories.
Given two categories $\cat{C}$ and $\cat{D}$ and a functor $F \colon \cat{C} \to \cat{D}$,
$F$ maps objects in $\cat{C}$ to objects in $\cat{D}$ and arrows in $\cat{C}$ to arrows in $\cat{D}$.
This mapping must abide by two laws:

1.  It must preserve identity arrows:

    $F(id_X) = id_{F(X)}$ for every object $X$ in $\cat{C}$.

    In other words, the $id$ arrow for the object $X$ in $\cat{C}$ must map to the $id$ arrow for the object $F(X)$ in $\cat{D}$.

2.  It must preserve composition of arrows:

    $F(g \circ f) = F(g) \circ F(f)$ for all arrows $f \colon X
    \to Y$ and $g \colon Y \to Z$.

    In other words, the composition of arrows $f$ and $g$ in $\cat{C}$
    must map to the composition of arrows $F(f)$ and $F(g)$ in $\cat{D}$.

The Functor class that comes with Haskell is this sort of functor,
but again it is somewhat restricted because it doesn't parameterize over a choice of category:

```haskell
class Functor f where
  fmap :: (a -> b) -> f a -> f b
```

This means that it can only operate in the "ambient" Haskell category,
where the objects are all Haskell types and the arrows are all functions, often called *Hask*.
This also makes them *endofunctors*[^endofunctor].

[^endofunctor]: An *endofunctor* is a functor that maps from a category to itself.

It has a mapping from types to types
(this is the instance's type constructor, e.g., `Maybe`, which must be of kind `* -> *`)
and a mapping from functions to functions (this is the instance's implementation of `fmap`).
It must also abide a pair of "Functor laws" which are precisely the functor laws from category cheory:

[functor]: http://en.wikipedia.org/wiki/Functor

```haskell
-- fmap sends identity arrows to identity arrows
fmap id = id

-- fmap preserves composition
fmap f . fmap g = fmap (f . g)
```

Now that we have a way to describe categories explicitly,
we can describe Hask itself:

```haskell
instance Category (->) where
  id x = x
  (.) f g b = f (g b)
```

and we can also describe functors between categories other than Hask!
(Unfortunately, we'll have to get to that bit later since Edward has already jumped ahead
to *natural transformations*!)

[endofunctors]: http://en.wikipedia.org/wiki/Functor#Examples

Natural Transformations
=======================

If functors are morphisms of morphisms, it's reasonable to ask if we can go a step further
and get morphisms of morphisms of morphisms, i.e., morphisms of functors.
The answer is yes, and they're called [natural transformations][nat].

Specifically, a natural transformation is a morphism from a Functor to another Functor:

```haskell
newtype Nat f g = Nat { runNat :: forall a. f a -> g a }
```

`Nat` sends a Functor `f` to a Functor `g`.
It doesn't care what type the functors are parameterized over as long as it doesn't change.
The `RankNTypes` extension is needed here to universally quantify (and bind) the `a` in the inner scope,
and thereby "hide" it it from the outer scope.

Since it's somewhat unusual to operate at this level of abstraction,
it might help to provide a few examples of `Nat` values.
First, we'll need some functions that serve as functor mappings:

```haskell
-- A mapping from [a] to Maybe a
-- NB: This mapping "forgets" the tail of the list.
listToMaybe              :: [a] -> Maybe a
listToMaybe []           = Nothing
listToMaybe (x:xs)       = Just x

-- A mapping from Maybe a to Either () a
-- NB: Either () a is isomorphic to Maybe a
maybeToEither            :: Maybe a -> Either () a
maybeToEither Nothing    = Left ()
maybeToEither (Just x)   = Right x

-- A mapping from Either a b back to Maybe b
-- NB: This mapping "forgets" the left summand.
eitherToMaybe            :: Either a b -> Maybe b
eitherToMaybe (Left _)   = Nothing
eitherToMaybe (Right x)  = Just x
```

Now we can look at their `Nat`-encoded versions:

```haskell
Nat listToMaybe    :: Nat [] Maybe
Nat maybeToEither  :: Nat Maybe (Either ())
Nat eitherToMaybe  :: Mat (Either a) Maybe
```

(Note that the Functor's type argument is hidden by the forall and `Rank2Types`.)

Since natural transformations are morphisms, it's also reasonable to ask if they form a category,
and it shouldn't be a surprise that they do. This category is called a *functor category*.

Functor Categories
==================

Starting with the observation that the functions defined above can be composed,

```haskell
maybeToEither . listToMaybe   :: [a] -> Either () a
maybeToEither . eitherToMaybe :: Either a b -> Either () b
eitherToMaybe . maybeToEither :: Maybe a -> Maybe a
```

we can also explore the composition of `Nat` values. The first step is to make a `Category` instance for `Nat`:

```haskell
instance Category Nat where
  id = Nat id
  Nat f . Nat g = Nat (f . g)
```

If we try this without `PolyKinds`, we get a kind error:

```
    The first argument of ‘Category’ should have kind ‘* -> * -> *’,
      but ‘Nat’ has kind ‘(* -> *) -> (* -> *) -> *’
    In the instance declaration for ‘Category Nat’
```

We're trying to make a `Category` instance for `Nat`. Unfortunately, `Nat` has kind

```haskell
:k Nat
(* -> *) -> (* -> *) -> *
```

because `Nat` is a mapping of `Functor`s, which have kind `* -> *`,
while `Category` instances must have kind `* -> * -> *`. In other words,
`Category` instances can only map over types of kind `*`, not types of kind `* -> *`.


The solution is to allow `Category` to map over arbitrarily kinded types.
The [`PolyKinds`][PolyKinds][^polykinds] extension lets GHC derive a *polymorphic kind* for `Category`
so that the kind of `Category` instances becomes `k -> k -> *` where `k` represents any kind.

Now that we have a polymorphically kinded `Category`, we can construct our instance for `Nat`.
Here it is again for reference:

```haskell
instance Category Nat where
  id = Nat id
  Nat f . Nat g = Nat (f . g)
```

The identity morphism for natural transformations is the always useful `id`.
Composition for natural transformations is given by composition of the functions we use to represent them,
modulo some newtype wrapping and unwrapping.
Since newtypes are isomorphic to their underlying type, `Nat` wraps over `(->)`,
and functions already form a category, we get the category laws for `Nat` for free.
(Or at least we only had to pay for them once.)

[PolyKinds]: https://www.haskell.org/ghc/docs/latest/html/users_guide/kind-polymorphism.html

[^polykinds]: `PolyKinds` was introduced in the paper [Giving Haskell a Promotion][promotion] by Yorgey, Weirich, Vytiniotis, and Jones.

[promotion]: http://dreixel.net/research/pdf/ghp.pdf
