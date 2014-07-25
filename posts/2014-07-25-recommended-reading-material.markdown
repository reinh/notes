---
title: Recommended Reading Material
description: Recommended reading material for learning Haskell, Algebra, Category Theory, etc.
---

# Suggestions

For Haskell, I suggest *Learn You a Haskell* [@lipovača2011learn]
followed by *Haskell: The Craft of Functional Programming* [@thompson1999haskell]
and/or *Introduction fo Functional Programming using Haskell* [@Bird98:Introduction].
*Real World Haskell* [@o2008real] can be used but it must be read carefully as it is out of date and contains a significant number of errata.

For Category Theory, I suggest Lawvere's *Conceptual Mathematics* [-@lawvere2009conceptual], Awodey's *Category Theory* [-@awodey2010category],
and Mac Lane's *Categories for the Working Mathematician* [@lane1998categories], in that order.
Alternatively, Awodey can be used as a forcing function to read Lawvere, and Mac Lane can be used as a forcing function to read Awodey.

For Abstract Algebra, and as preparation for Category Theory, I recommend Mac&nbsp;Lane's *Algebra* [-@lane1999algebra].

# General

How to Prove It [@velleman2006prove]
  ~ A wonderful book that introduces a structured method for proving things.
    Required reading for anyone who is interested in writing or understanding proofs.

# Haskell

Learn You a Haskell [@lipovača2011learn]
  ~ Recommended as a first introduction to Haskell. Focuses on typeclasses.
    A bit short; should be followed up with a more thorough introductory text like those listed below.

Introduction to Functional Programming using Haskell [@Bird98:Introduction]
  ~ One of the best introductory books on programming ever written.
    As the title suggests, this is not so much a Haskell book as a FP book that happens to *use* Haskell.
    It won't teach you about libraries or practical issues like network, file and other IO,
    but it *will* teach you how to think in a functional way about your programs.

Programming in Haskell [@hutton2007programming]
  ~ Focuses on core langauge concepts and avoids advanced topics.
    It's somewhat lightweight at only 171 pages, and its organization is a bit strange,
    but it is an excellent introduction to the Haskell language.

Real World Haskell [@o2008real]
  ~ Written by a few of the most prolific Haskell developers, this book presents a pragmatic introduction to Haskell.
    Unfortunately, it contains a number of errata and many sections have become obsolete.
    I recommend that you use the online version and read the comments as many of them correct errors or confusing wordings in the original.
    Also be sure to read this [summary of caveats and issues][caveats], listed by chapter.

The Haskell Road to Logic, Maths and Programming [@doets2004haskell]
  ~ Similar to @Bird98:Introduction, this isn't so much a Haskell book as a math book that uses Haskell for its examples.
    That said, it's a wonderful introduction to the sort of mathematics that you can express in Haskell (which is quite a lot).

Haskell: The Craft of Functional Programming [@thompson1999haskell]
  ~ A well organized introductory text that does a good job of teaching and motivating the functional perspective.
    Might be paced a bit slowly for some, but others will enjoy its thoroughness.

[caveats]: http://stackoverflow.com/a/23733494/2225384

# Cateogry Theory

*See also Edward Kmett's [list on Quora][ed].*

[ed]: http://www.quora.com/Category-Theory/What-is-the-best-textbook-for-Category-theory

Conceptual Mathematics [@lawvere2009conceptual]
  ~ A Category Theory text with few prerequisites, suitable for a "motivated high-schooler".
    This is a great introduction to Category Theory for folks without a mathematical background
    and will prepare you to read some of the more advanced texts that follow.

Categories for the Working Mathematician [@lang2002algebra]
  ~ Written for "working mathematicians", this dense book is a considerable challenge even for graduate students.
    That said, it's also the most comprehensive and thorough Category Theory text, written by one of the founders of the discipline.

Category Theory [@awodey2010category]
  ~ The standard modern text on Category Theory, and the best all around introduction.
    Sits somewhere between @lawvere2009conceptual and @lane1998categories in difficulty.
    Highly recommended.

Abstract and Concrete Categories: The Joy of Cats [@adámek2009abstract]
  ~ Sits somewhere between @lawvere2009conceptual and @awodey2010category in difficulty.
    A decent introductory text, but mostly redundant if you're alreading those two.

# Abstract Algebra

Algebra [@lane1999algebra]
  ~ In the [words] of one of Mac Lane's students, "I know of no book on pure mathematics more worth reading than this one".
    Introduces algebra methodically and thoroughly from first principles.
    A much easier book than *Categories for the Working Mathematician* [@lane1998categories],
    *Algebra* will introduce you to Mac Lane's idiosyncratic style and is an excellent preparation for Category Theory.

Algebra [@lang2002algebra]
  ~ Weighing in at over 900 pages, Lang is somewhere between an introductory textbook and some sort of beastiary of algebraic structures.
    Lang introduced a novel pedagogy for algebra that borowed new ways of thinking from category theory and homological algebra,
    which has influenced subsequent graduate-level algebra books.

[words]: http://www.amazon.com/review/R2MHDPXKDJRWA2/ref=cm_cr_dp_cmt?ie=UTF8&ASIN=0821816462&nodeID=283155&store=books

# References
