---
created_at: 2013-03-27
excerpt: Embodiments in Scala, Clojure and Haskell.
kind: article
publish: true
title: "Infinite Loops"
---

My second attempt at Coursera's [Scala course][1] turned out to have a
refreshingly twisty plot. The grand plan this time is to blaze through the
course using both Scala and Clojure, and then top it off by dishing out
code reviews of [Storm][2] (Clojure) and [Kafka][3] (Scala).

I didn't expect the first week to hit me with a bunch of creepy differences
in details that aren't skin-deep. How hard could it be to write an infinite
loop, right?

## The Background: Function Evaluation

The week started with some basic concepts on the substitution model of
function execution. In a nutshell, there are two ways a called function can
be reduced to a value in the substitution model:

   * **Call-by-value:** The function's arguments are fully reduced before the
      function is applied to them. This is the *default* method of substitution
      in both Clojure and Scala. An example series of reductions could be:

<code class="python">
  sumOfSquares(4, 3 + 2)
    => sumOfSquares(4, 5) # Argument reduced to a value
      => square(4) + square(5) # Function applied
        => 16 + 25
          => 41
</code>

   * **Call-by-name:** Applies the function to unreduced arguments. The arguments
      are evaluated in the body of the function *if needed*. This gives us a
      convenient way to short-circuit evaluation of a parameter if it is unused in
      the function body. An example series of reductions for this would be:

<code class="python">
  sumOfSquares(4, 3 + 2)
    => square(4) + square(3 + 2) # Function applied
      => square(4) + square(5) # Argument reduced
        => 16 + 25
          => 41
</code>

Note that I have omitted some of the reduction steps for brevity.

## The Plan: Infinite Recursion

An in-class exercise was to write a function performing the boolean-and of two variables
without using the built-in primitives. The crux was about remembering the short-circuits:

<code class="python">
  true && Y == Y
  false && Y == false
</code>

In Scala, this can be quickly accomplished by:

<code class="python">
  def and2(x: Boolean, y: Boolean) = if (x) y else false 
</code>

But the method above can be broken, and our weapon of choice is the infinite recursion loop:

<code class="python">
  def loop: Boolean = loop
</code>

This defines a function that calls itself. Note that because this is a *def* and not
a *val*, the right-hand-side of the assignment is evaluated only when the function is
called. *val*, in contrast, evaluates the right-hand-side at definition time.

Now if we provide this function as an argument to our boolean-and'er, we see the following
reduction happening (remember that Scala reduces by-value):

<code class="python">
  and2(false, loop)
    => # Hangs when trying to evaluate the "loop" method
</code>

What we'd like is to not evaluate the second parameter at all if the first is false.
To achieve this, we can coax Scala into reducing a particular argument by-name instead:

<code class="python">
  def and2(x: Boolean, y:=> Boolean) = if (x) y else false
</code>

The reduction for this would then be:

<code class="python">
  and2(false, loop)
    => if (false) loop else false
       => false
</code>

The infinite *loop* is never evaluated, since we have forced Scala to evaluate the
second parameter by-name instead of by-value. Hence, we achieve our desired behaviour.

## The Twist I: TCO

Translating this functionality to Clojure seemed trivial until I slammed into some
odd behaviour. To start with, let's write an innocent infinite loop function:

<code class="python">
  (defn myLoop [] (myLoop))
</code>

And let's run this method and watch it eat up our CPU:

<code class="python">
  user=> (myLoop)
  StackOverflowError  user/myLoop (NO_SOURCE_FILE:1)
</code>

Unexpected, right? I was stumped! After some headless-chicken-scrambling
into the details of function argument reduction in Clojure, I
stumbled onto [this illuminating blog post][4], comparing infinite loops
in a number of languages. The sneaky culprit turned out to be
TCO, or *tail-call optimization*.

### Tail-Call Optimization

Let's look at what this means by a simple reduction example, applied to calculating
the sum of ones upto *N*. Here is the non-tail-call-optimized reduction:

<code class="python">
  sumToN(5)
    => 1 + sumToN(4)
    => 1 + 1 + sumToN(3)
    => 1 + 1 + 1 + sumToN(2)
    => 1 + 1 + 1 + 1 + sumToN(1)
    => 1 + 1 + 1 + 1 + 1 # sumToN(1) returns
    => 1 + 1 + 1 + 2     # sumToN(2) returns
    => 1 + 1 + 3         # sumToN(3) returns
    => 1 + 4             # sumToN(4) returns
    => 5                 # sumToN(5) returns 
</code>

Observe how the chain of execution gets wider with increasing *N*. Each function call
is appended to the call stack. Only when the last function is reduced does
the stack get collapsed by subsequently reducing each function.

Our *sumToN* function can be tail-call-optimized by simply adding an additional
laccumulator parameter. This parameter, along with the current *N* value, maintains
the *state* of the function evaluation at that instant.

<code class="python">
  sumToN(0, 5)
    => sumToN(1, 4)
    => sumToN(2, 3)
    => sumToN(3, 2)
    => sumToN(4, 1)
    => sumToN(5, 0)
    => 5
</code>

Notice how the evaluation of this function always has a constant tail length, and hence
accumulates a constant amount of space on the call stack for any *N* value.

### Scala Does Tail-Call Optimization By Default

And this happens really quietly. This is why the Scala infinite loop function we wrote
earlier actually executed infinitely. In contrast, the Clojure one never runs, and the
infinite function additions to the call stack eventually trigger a stack overflow.

## The Twist II: Lazy Evaluation

To mimic Scala's behaviour, let's enforce tail-call optimization in Clojure:

<code class="lisp">
  (defn myLoop [] ((loop [] () (recur))))
</code>

Now let's try the same boolean-and'ing exercise we did in Scala:

<code class="lisp">
  user=> (defn and2 [x y] (if (= x true) y false))
  #'user/and2
  user=> (and2 false myLoop) ; Should short-circuit
  false
  user=> (and2 true myLoop)  ; Should hang
  #<user$myLoop user$myLoop@4d91f801>
</code>

What did it just dump out on our feet? Where is our infinite loop? 

The culprit this time turns out to be *lazy evaluation*; a function is not
evaluated to its return value unless explicitly asked to. Clojure uses lazy evaluation
by default, so instead of evaluating the function, it simply returns it to
us, should we choose to explicitly evaluate it later. In contrast, Scala
begins evaluating the *loop* function within the if-condition and hence
runs into an infinite loop. That weird dump is a representation of our Clojure function.

## Bonus Twist: Really Lazy Evaluation

Another interesting fact a comment in [this blog post][4] pointed out was an important
difference between lazy evaluation in Haskell and Clojure. Consider this
Haskell infinitely-recursive function:

<code class="haskell">
  forever = forever
</code>

When you call this function, it blocks infinitely, as expected. But in contrast
to Clojure and Scala's infinite loops, this one uses no CPU! Why?

It turns out Haskell is *extremely lazy*. Since our function doesn't really do anything,
it's never really executed. You could simply print something to the screen within the
function to set Haskell on fire, but it won't budge until you do so.

The [Computer Language Benchmark Game][5] fell into Haskell's lazy trap once, when
the array sorting benchmark in Haskell outperformed hand-optimized C. It turned out that
the sorted array was never printed out. So the Haskell function took the lazy way out
and did absolutely nothing, while C worked hard to sort a bunch of numbers that would
never see the light of day.

[1]: https://class.coursera.org/progfun-2012-001/
[2]: https://github.com/nathanmarz/storm/
[3]: http://kafka.apache.org/
[4]: http://paulbarry.com/articles/2009/09/02/infinite-recursion
[5]: http://benchmarksgame.alioth.debian.org/
