---
created_at: 2012-01-14
excerpt: On the switch to nanoc.
kind: article
publish: true
tags: [nanoc]
title: "Compiled Are I"
---

> While I’m not specifically trained as an author of prose,
> I *am* trained as an author of code. What would happen if
> I approached blogging from a software development perspective?
> What would that look like?
> <cite>Tom Preston-Werner</cite>

I feel alone, the pixels from [Blogging Like A Hacker][0]
speaking of freedom and peace in minimalism and simplicity, and
feel the weight of a time long past since some first seeked the
right tools to build their prose.

Though a bit too late, I have suffered the same itch, spent
time scrutinizing their remedies, and come to adopt a cure that
leaves me content. Hence, I leave my share of fresh debris on
this old field, in the hope that it serves some whom none
could before.

[0]: http://tom.preston-werner.com/2008/11/17/blogging-like-a-hacker.html

The Choice
----------

[Many][1] cures exist. Most were short-lived, personal hacks
lacking documentation effort, of which the popular ones made
up for with their expressive community. I was looking for the
perfect blend of malleability, strength and a good instruction manual.

[1]: http://iwantmyname.com/blog/2011/02/list-static-website-generators.html

1. [**toto**](http://cloudhead.io/toto): Tiny (~300 sloc), built to work with git and
Heroku out of the box, this was my dream engine for a while; then
I realised it's a bit too tied in with Heroku for my comfort (I'm
forced to live behind a draconian proxy). It has a bunch of features
that I'm still working on incorporating into my current cure, and
this [beautiful guide][2].

[2]: http://fadeyev.net/2010/05/10/getting-started-with-toto/

2. [**Jekyll**](http://jekyllrb.com/): Possibly the most popular of the lot, with a
really neat [framework][3] to get started with, and solid backing
from the big players (Github Pages uses this) and community. Perfect
for the blogger focused on blogging, with no desires to spend time
tweaking their platform to perform silly stunts.

[3]: http://octopress.org/

3. [**nanoc**](http://nanoc.stoneship.org/): My pick, and my reasons for this can also be
counted as my reasons against the options above:

    i. *Actively maintained*: The release at the time of this
    post was on January 9, 2012. They've got a pretty
    busy forum and an IRC channel too, and seeing Denis
    (the creator) still involved after having created it way
    back in 2007 instills some amount of faith in the project.

    ii. *Brilliantly documented*: This engine has the most
    extensive, in-depth documentation of the one's I've
    evaluated. This includes API documentation, a bunch of
    mini-tutorials on customizing the engine, some deployment
    and best-practices guides and a whole lot of community-
    contributed material.

    iii. *Powerful*: This could be a corollary of the two
    above; with the depth of documentation at hand, anyone
    with basic Ruby skills can extend the engine to perform
    breathtaking acrobatic manoeuvers.

The Switch
----------

The power of customizability carries the burden of the
time it consumes. Ideally, you'd tweak until it's just
perfect, when really, it never is. The switch was meant
to be painless, but the more I realised was possible, the
longer the silence on my [old blog][4], as I toiled
behind my shiny new nanoc3 site hosted on Heroku.

This post was intended to be a practical, comprehensive
guide to the switch from Wordpress, but the
time lapsed between that process and now leaves me
with just a bunch of references that guided me through.

[4]: http://halfclosed.wordpress.com/

References
----------

1. [**nanoc3_blog**](https://github.com/mgutz/nanoc3_blog): A
   well done starter kit for nanoc3, with minimalistic styling
   and a bunch of useful blog features like archives, tags and
   pages.

2. [**nanoc_fuel**](https://github.com/kamui/nanoc-fuel): The
   one stop solution to adding Facebook likes and comments to
   your nanoc3 blog.

3. [**Octopress**][3]: While a Jekyll framework, the features
   curated by this project are easily embeddable into any nanoc3
   blog. 

The switch is quickest if you know exactly what you want, and
can dabble in Ruby without fear. While you're at it, the place
to be is the [nanoc group](http://groups.google.com/group/nanoc).
