---
created_at: 2012-01-14
excerpt: Disassembling the switch to a static blog.
kind: article
publish: true
tags: [static blog, disassembling]
title: "Compiled Are I"
---

> While I’m not specifically trained as an author of prose,
> I *am* trained as an author of code. What would happen if
> I approached blogging from a software development perspective?
> What would that look like?
> <cite>Tom Preston-Werner</cite>

I find myself alone, the pixels from [Blogging Like A Hacker][0]
reflecting off my eyes. I tread empty battlefields of the
blogosphere, consuming tales of mutiny against those machines
that once served our need to express. I read of freedom and peace
in minimalism and simplicity, and feel the weight of a time long
past since some first seeked the right tools to build their prose.

Though too late, I have suffered the same itch as those who have
passed me by, spent time in scrutinizing their remedies, and
come to adopt a cure that has left me content. Hence, I shall
leave my share of fresh debris on this old field, in the hope
that it serves some whom none could before.

[0]: http://tom.preston-werner.com/2008/11/17/blogging-like-a-hacker.html

Picking A Cure
--------------

[Many][1] cures existed before Tom Presten-Werner expressed
the problem so succintly. Most were short-lived, personal hacks.
Most lacked documentation effort, of which the popular ones made
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
from the enterprise (Github Pages uses this) and community. Perfect
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
    with basic Ruby skills can extend the engine to do the
    silly stunts they wish. And people do that pretty often,
    eventually ending up as a how-to guide on the forum for
    the rest of the community to adopt and extend.

Finding Some Boilerplate
------------------------

Finding goes here

Building The Blog
-----------------

Code stuff.

Picking A Web Host & DNS
------------------------

Host selection goes here.

Blast Off!
----------

Launch!
