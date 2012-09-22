---
title: "Rescuing Resque: Let's do this"
date: 2012-09-22 06:10
---

If you've ever done background job stuff with Rails, you've probably used
[Resque](https://github.com/defunkt/resque). Resque is "Yet Another GitHub
Project They've Open Sourced and Then Abandoned." But Resque is super awesome:
it builds a job queue on top of Redis, which is a totally awesome piece of
software.

Anyway, Resque has been psuedo-abandonware for a while now. In January,
[Terence Lee](http://hone.heroku.com/) from Heroku got in charge of the
project, but it's a big job. Too big of a job to properly manage alone. It's
hard to sift through [60 pulls and 120 open
issues](https://github.com/defunkt/resque/issues?state=open), some of which
have been open for a few _years_. And manage the 1.x line while working on
new stuff for 2.0. And debug issues that basically boil down to "When I upgrade
Resque and this random gem, everything breaks, but when I downgrade that other
gem, it works again. But Resque throws the error."

Even outside of heroics, the bus factor on a project that's as important as
Resque should be higher than one.

So Terrence gave a presentation at Frozen Rails, and in it, he outlined what
needs to be done for Resque 2.0, and asked for some help getting it out the
door. So myself and a few other people are gonna pitch in and help out, and
we'd love to have you.

Here's the deal: I will personally be looking at (and already have read) every
single open issue on GitHub. Feel ignored about something involving Resque?
You can come to me. I can't guarantee that I can get it fixed, but at least
I'll help you figure out wtf is going on, and get us a bug report that we can
use to build a fix.

Think of it as decoupling the front end from the back end: Terrence can focus
on writing new code, and I can focus on paying attention to your problems,
helping you solve them, and getting fixes applied to the 1.x branch.

If you're interested in helping out, we'd love to have you. Helping triage
issues would be awesome, fixing bugs would be awesome, writing code would be
awesome, updating docs would be awesome.

Let's do this.
