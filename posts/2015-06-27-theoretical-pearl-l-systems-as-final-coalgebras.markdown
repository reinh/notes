---
title: Theoretical Pearl: L-systems as Final Coalgebras
---

<aside class="sidenote">

![Weeds created with a 3D L-system][Weeds]{#fig:weeds} "Weeds created
 with a 3D L-system [@wiki:lsystem]"

</aside>


[Weeds]: /images/640px-Fractal_weeds.jpg


<p class="lead">
[Denotational design] gives an elegant representation of [L-systems]
as fixed points of a coalgebra.
</p>

[Denotational design]: TODO
[L-systems]: TODO

<span class="newthought">L-systems were created</span> in 1968 by
Aristid Lindenmeyer to model the behavior of plant cells. As
*rewriting systems*, they start with a simple object and repeatedly
replace parts of it using a set of *rewriting rules* or *productions*
[@prusinkiewicz2012algorithmic, p. 13]. They can be used to generate fractals
and other self-similar images (see [@fig:weeds]).

A simple L-system consists of an alphabet of symbols, an initial
axiom (or starting string), and a set of production rules that expand each symbol
into a string. Formally, a *deterministic*, *context-free*
L-system[^D0L] (or  <span class="lining-numerals">D0L-system</span>) is
defined as a tuple $$L = (\Sigma,\omega,P)$$ where $\Sigma$ is the
alphabet, $\omega$ the axiom, and $P$ the collection of production
rules.

[^D0L]: A deterministic L-system is one where each symbol has only one
production rule. It is context-free when the production rules are only
aware of the symbol itself and not any of its neighbors.

Consider the first example of a <span
class="lining-numerals">D0L-system</span> given by
@prusinkiewicz2012algorithmic [p. 15]. It is built from alphabet $\{a,b\}$,
production rules $\{a \mapsto ab,b \mapsto a\}$, and starting string $b$. We
can use a Haskell representation where the symbols are characters, the
words are strings, and the rules are functions from characters to
strings:

```haskell
data D0L = D0L
  { axiom :: String
  , rules :: Char -> String
  }

example :: D0L
example = D0L "b" rules
  where rules 'a' = "ab"
        rules 'b' = "a"
```

In each step of the rewriting process, each letter in the string is
replaced according to its production rule. In our Haskell
representation, a step takes a `D0L`, applies the rules to the
axiom, and gives a new `D0L` with the new string as its axiom
and the same set of rules. We can use type driven development and a
theorem prover to implement `step`:

```haskell
step :: D0L -> D0L
step (D0L axm rls) = D0L (_run axm rls) rls
```

GHC gives us the type of the hole

```
Found hole ‘_run’ with type: String -> (Char -> String) -> String
```

and we can ask the [Exference] theorem prover to give us a suitable
implementation[^exf]

```haskell
:exf [Char] -> (Char -> [Char]) -> [Char]
(>>=)
```

[Exference]: https://github.com/lspitzner/exference

[^exf]: `String` is replaced by `[Char]` because Exference doesn't
    support type synonyms.

which gives us

```haskell
step :: D0L -> D0L
step (D0L axm rls) = D0L (axm >>= rls) rls
```

Since `step` is a specialization of `(>>=)`, let's make it fully
general

```haskell
data D0L m a = D0L
  { axiom :: m a
  , rules :: a -> m a
  }

step :: Monad m => D0L m a -> D0L m a
step (D0L axm rls) = D0L (axm >>= rls) rls
```

and we can see that `D0L` is really just packaging up the arguments to
`(>>=)`. What's more, we know that our implementation of `step` is
correct because it's the only defined inhabitant of its type. Thanks,
parametricity!

Generating a list of iterations for a `D0L` is

```haskell
generate :: Monad m => D0L m a -> [D0L m a]
generate = iterate step
```

which repeatedly (coiteratively) applies the `rules` to the `axiom`.
This makes `generate` a fixed point of the `rules` `m`-coalgebra.

Now we can generate first six steps of our example's derivation and check our
work with [@fig:abaababa].

<aside class="sidenote">

![abaababa][abaababa]{#fig:abaababa} "Derivation of the example in
 @prusinkiewicz2012algorithmic [p. 16]"

</aside>

[abaababa]: /images/abaababa.png


```haskell
> mapM_ (putStrLn . axiom) . take 6 $ generate example
b
a
ab
aba
abaab
abaababa
```

---
