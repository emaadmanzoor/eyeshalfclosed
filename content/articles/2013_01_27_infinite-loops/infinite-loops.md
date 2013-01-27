---
created_at: 2013-03-27
excerpt: Differences in Scala and Clojure.
kind: article
publish: true
title: "Infinite Loops"
---

I draw to the end of my first week of Coursera's [Scala course][1]. I have
taken it up as a solitary student with a vengeance, armed with a new year's
boost in morale since abandoning it midway last year. Expecting to blaze through
the first few weeks, I had planned to work through the course using both Scala
and Clojure and then churn out code walkthroughs of the [Storm][2] stream processing
platform (a Clojure project) and the [Kafka][3] message queue (a Scala project).

It turns out there are some important differences in the way these two functional
languages work that are not skin-deep. This post documents the differences I found
and investigated while writing infinite-recursive methods in Scala and Clojure.

## The Background: Function Evaluation

This week was about some basic concepts and theory on the substitution model of
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
      convenient way to short-circuit reduction of a parameter if it is unused in
      the function body. An example series of reductions for this would be:

<code class="python">
  sumOfSquares(4, 3 + 2)
    => square(4) + square(3 + 2) # Function applied
      => square(4) + square(5) # Argument reduced
        => 16 + 25
          => 41
</code>

Note that I have omitted some of the reduction steps for brevity.

## The Task: Infinite Recursion

An in-class exercise was to write a function for the boolean-and of two variables without
using the built-in primitives. The crux of this task was to remember the short-circuits:

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

Now if we provide this function as an argument to our and-function, we see the following
reduction happening (remember that Scala reduces by-value):

<code class="python">
  and2(false, loop)
    => # Hangs when trying to evaluate the "loop" method
</code>

What we would expect is a short-circuit as soon as we see a false first argument. To
achieve this, we can coax Scala into reducing a particular argument by-name instead:

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

## The Divide I: Infinite Loops

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

Unexpected, right? I was stumped! After a while being a headless chicken
burrowing into the details of function argument reduction in Clojure, I
stumbled onto [this illuminating blog post][4], comparing infinite loops
in a number of languages. The sneaky culprit turned out to be
*tail-call optimization*.

### Tail-Call Optimization

Let's see what this means by a simple reduction example, applied to calculating
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

Observe how the chain of execution gets wider with increasing *N*. Each function call,
is appended to the call stack. Once the last function has been reduced, only then is
the stack collapsed by subsequently reducing each function. The function *sumToN*
has a *tail call*.

Our *sumToN* function can be optimized by simply
adding an additional accumulator parameter. This parameter, along with the current
*N* value, maintains the *state* of the function evaluation at that instant.

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

And this happens automatically. This is why the Scala infinite loop function we wrote
earlier actually executed infinitely. In contrast, Clojure does not, and the infinite
function additions to the call stack eventually triggers a stack overflow.

## The Divide II: Lazy Evaluation

To mimic Scala's behaviour, let's enforce tail-call optimization in Clojure:

<code class="lisp">
  (defn myLoop [] ((loop [] () (recur))))
</code>

Now let's write an *and* method and try the same exercise we did in Scala:

<code class="lisp">
  user=> (defn and2 [x y] (if (= x true) y false))
  #'user/and2
  user=> (and2 false myLoop) ; Should short-circuit
  false
  user=> (and2 true myLoop)  ; Should hang
  #<user$myLoop user$myLoop@4d91f801>
</code>

This was unexpected. Where is our infinite loop? 

The culprit this time turns out to be *lazy evaluation*; a function is not
evaluated to its value unless explicitly required. Clojure uses lazy evaluation
by default, so instead of evaluating the function, it simply returns it to
us, should we choose to explictly evaluate it later. In contrast, Scala
begins evaluating the *loop* function within the if-condition and hence
runs into an infinite loop.

## Bonus Excercise: Lazy Evaluation In Haskell

I don't know Haskell at all, but [this blog post][4] pointed out an important
difference between lazy evaluation in Haskell and Clojure. Consider this
Haskell infinitely-recursive function:

<code class="haskell">
  forever = forever
</code>

When you call this function, it blocks infinitely, as expected. But in contrast
to Clojure and Scala's infinite loops, this one uses no CPU! Why?

I'll quote the explanation provided in the comments to the original blog post here:

> Haskell has lazy evaluation and call-by-need semantics. Since you aren't doing anything with your forever function, it will never get evaluated. You have to enforce strict evaluation, by e.g. printing it out. (The same mistake is done on the Computer Language Benchmark Game. There's an Array sorting benchmark where Haskell just blows away even hand-optimized C. The secret is that the benchmark never prints out the contents of the sorted array. The C compiler isn't smart enough to recognize that the array is never actually used anywhere, but Haskell is, and so the entire benchmark basically compiles down to the equivalent of "int main() { return 0; }".)
> <cite><a href="http://paulbarry.com/articles/2009/09/02/infinite-recursion#comment-5326">Jörg W Mittag</a></cite>

[1]: https://class.coursera.org/progfun-2012-001/
[2]: https://github.com/nathanmarz/storm/
[3]: http://kafka.apache.org/
[4]: http://paulbarry.com/articles/2009/09/02/infinite-recursion
