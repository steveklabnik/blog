---
layout: post
title: "Moving from Sinatra to Rails"
date: 2011-12-30 11:00
---

I love both Sinatra and Rails, for different reasons. I've heard a few
different heuristics for which framework would be better for your application,
but I'm not sure the answer is all that simple, really. Regardless of which is
correct for your application, I haven't seen a lot of people discussing how to
move between the two frameworks.

## Step One: Evaluate your test coverage

In <a href="http://www.amazon.com/gp/product/0131177052/ref=as_li_ss_tl?ie=UTF8&tag=stesblo026-20&linkCode=as2&camp=1789&creative=390957&creativeASIN=0131177052">Working Effectively with Legacy Code</a><img src="http://www.assoc-amazon.com/e/ir?t=stesblo026-20&l=as2&o=1&a=0131177052" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />(this is an affiliate link. Does this bother you?),
Michael Feathers introduces a fantastic technique called "Lean on the Compiler." 
It's on page 315, for those of you playing along at home.

> The primary purpose of a compiler is to translate source code into some
> other form, but in statically typed languages, you can do much more with
> a compiler. You can take advantage of its type checking and use it to identify
> which changes you need to make. I call this practice _Leaning on the Compiler_.
> 
> _Lean on the Compiler_ is a powerful technique, but you have to know what
> its limits are; if you don't, you can end up making some serious mistakes.

Now, in a language like Ruby, we don't have type checking. We do have something
that double checks our code correctness: tests. Just like static type checks, 
tests can not _ensure_ that you've done your transformations, but they sure
as hell can help. This becomes step one in the effort to move from one
framework to another: evaluate your test coverage.

### Acceptance Tests are most important

When looking at your tests, first check out your acceptance tests. These are
the most important, for two reasons: they're abstracted away from the framework
itself, and their purpose in life is to make sure that major functionality is
working. Do you have your happy paths covered? Is there any major functionality
that's _not_ covered by acceptance tests?

While the happy path is a big deal, when moving to a new framework, we're going
to introduce a high chance of people encountering issues, so the sad path is
also important. I personally tend to not write very many sad path acceptance
tests, and leave that for tests at the lower level. This is a good time to take
stock of the worst of your worst paths: is there certain functionality that's
_absolutely_ important to be handled 100% correctly? Then write some new
acceptance tests. As with any kind of engineering project, there's a tradeoff
here: You can't get coverage of every possible situation. Tests are supposed to
give you confidence in your code, so liberally add coverage for any situation
that makes you nervous.

### Integration tests are important too

These tests are a bit more tricky, as they are tied into the framework that
you're using. I'm not sure that anyone writes many of these kinds of tests with
Sinatra, outside of maybe model to model integration tests.

### Model and View tests: not a big deal

These kinds of tests are much more of a sanity check than anything else for
the purposes of this kind of move. It's good that they pass, but really, they
shouldn't be too reliant on the framework you're using. They're better for
making sure you've put things in the correct directories, and haven't forgotten
anything in the move.

I'm not even sure what a 'view test' would be in Sinatra, and they tend to be
not in favor with Rails projects anyway, so that's more of a general 'framework
to framework' bit of advice than anything else.


### Controllers don't exist in Sinatra...

... so you don't really write those kinds of tests. Controller tests don't seem
to be that popular in Rails-land these days either.

## Step Two: Git Can help

I'll show you how I managed transitioning files over. However, I'm really
interested in the idea of using a [subtree
merge](http://help.github.com/subtree-merge/) to keep being able to update the
original Sinatra project while working on the new Rails project.

First step is of course, make a new branch. This transition will probably take
some time, and you may want to push hotfixes into production during that period.
Using master is not advised.

Next, make a copy of everything and shove it in a temp directory. Then delete
everything in the git repo (except the .git directory, of course) and commit
that blank slate. Back up a directory, run `rails new myproject` with the
correct name, and you'll get a blank rails app. `cd myproject` and
`mkdir sinatra`, then copy the backup your made into the sinatra directory.
Finally, commit this.

Now you've got a new blank Rails app, all your old code in a directory, and
you can start moving things over.

## Step Three: Set up your test harness

Since we're going to allow our tests to guide our move, it pays to get tests up
and running first! Depending on what testing framework you use, get it going
with Rails. In our case, we were using minitest to test our code. This took a
little bit of effort to get working with Rails, but there weren't a ton of
problems.

As always: red, green, refactor. I'd make a simple test that doesn't test
anything, `assert true`. Make sure that your `rake test` or `rspec .` or
whatever you'll use to run the tests works, and then remove the dummy
test.

There are two strategies for moving tests over: You can move a chunk at a time,
or move one at a time. Chunks are easier, but then you get commits where the
build is broken. It's really up to you and your team's tastes: a huge test
suite with a number of failures can show you how close you are to being done
with the first 90% of the work. And since you're not planning on releasing
in this half-finished state, having a broken build is not _that_ terrible...
As always, you're the professional: make the call.

## Step Four: Move your models

Since models are the simplest to move, I like to do them first. You _should_
just be able to copy over each test file and model file, though because you
were using Sinatra, your models may be all in one file. This step should be
largely painless, though: you're not really relying on any framework-specific
things.

Model tests can still suss out problems with your environment, though, like
incorrect database settings, certain environment variables...

The idea to begin with the easiest thing comes from [Dave
Ramsey](http://www.daveramsey.com/home/), oddly enough. My aunt works at a
bank, and when I went to college, she bought me a few of his books to help
me learn about personal finances. Dave is a big fan of the 'get rid of all
debt' school of thought, and so a large portion of his work is strategies
for getting out of debt. Dave contends that paying off loans with the
highest interest, while mathematically the fastest way to pay off your
obligations, is not actually the best strategy. People like to see progress,
and are heartened by seeing it. By paying off the smallest loan first, one
is much more likely to feel more positive about the headway they're making,
and so it's a much better strategy in the end.

The same logic applies with this move: why start with the hard stuff? Knock
out some quick wins to keep your spirits high.

## Step Five: Convert your controllers

Next up: get your controllers created. This is a pretty manual process:

```
get "foos" do
  @foos = Foo.all
  render :"foos/index"
end
```

becomes

```
class FooController < ApplicationController
  def index
    @foos = Foo.all
  end
end
```

The biggest issue with moving all of this stuff is that Rails and Sinatra
use `redirect` and `redirect_to`. So you'll have to convert that stuff. However,
I wouldn't recommend changing things like `redirect "/foos/#{id}"` to
`redirect_to foo_path(foo)` just yet. When dealing with legacy code, you want
to change as little as possible with each step, so that you know when you
have introduced an error. If you try to convert things to a Rails style as well,
you run the risk of introducing errors. Therefore, in all of these moves, leave
the hell enough alone as much as possible. Once your code is up and running,
you can gladly refactor. Just don't do it now.

Don't forget to generate your routes, too. Sinatra's DSL is like a combination
of Rails' routing and controllers. Set those up in this step as well.

Since we don't have tests, this part is very error-prone. Luckily, our acceptance
tests will catch these issues in step seven. So give it your best shot, but don't
worry about being 100% perfect. Focus on getting the basic structural changes
in place.

Having tests is so nice. :/

## Step Six: Move your views

This should be as simple as the models: put your views in the correct directory,
and things should be golden. If you were using inline views with Sinatra, well,
you shouldn't have that many of them, so breaking them out should be pretty
easy.

## Step Seven: Listen to your tests

Okay! Those last moves were really awkward, since we didn't have tests to check
our work. This is where the acceptance tests come in. You can move these over
in batches or one at a time, but the acceptance tests will tell you where
you forgot a route, if your view is missing, or if you left some little bit of
Sinatra-ness in your Rails somewhere.

You're almost home! Once you get all your acceptance tests working, you should
pat yourself on the back! You're not done yet, but you've made a lot of progress.

## Step Eight: Track your exceptions!

You should have been doing this anyway, but if you weren't, set up some sort
of mechanism to catch and handle exceptions.
[Airbrake](http://airbrakeapp.com/pages/home) is one such service, but even
just recording them yourself would be fine. You _need_ to have this set up
in some form, as you're likely to generate errors, and examining your
exceptions is the best way to track down actual problems.

## Step Nine: Plan out deployment strategies

Of course, now that you're done developing, it's time to get the app out to
users. This'll require a comprehensive plan for actually making the jump. A
little bit of foresight can go a long way here.

My strategy was to roll out the new Rails app under a new domain: 
http://beta.myapp.com/. I then pinged my users with a message along the
lines of "We've made some infrastructure updates, if you'd like to help us
test them out, visit the beta site."

This approach does have some sticky points, however. The first one is the
database. In my case, I had a high level of confidence in my code, and this
application wasn't for anything that was considered mission-critical. We also
had a decent backup strategy in place. Therefore, I connected the beta
site up to the production data store. This meant there were no migration issues
later. However, this may make you uncomfortable, but there are other options,
too. You can treat the beta as a sandbox, and tell people that the data
will not be persisted after the beta, or you can migrate people's data
back to the production data store afterwards.

Another approach is to automatically migrate a portion of your users over to the
new code base. Ideally, nobody notices: your code base shouldn't have changed
in looks of functionality.

## Step Ten: Push to production!

Congrats! Execute on the plan you created in step nine, and get ready to answer
tons of emails about why your app is broken! Just kidding, I hope! I really
recommend the beta strategy for this reason. No plan survives first contact
with the enemy. Your users _will_ find things you didn't, no matter how much
manual testing you did along the way.

## Another strategy: mounting

I haven't actually tried this myself, but I've been thinking about another way
to make this happen: mount your Sinatra app inside of a Rails app, and use
that to move things over slowly. [Here's an
example](http://stackoverflow.com/a/6972706) of how to make this happen
technically. If you had a really big Sinatra application, I could see how this
might get you deploying faster; just carve out one vertical chunk of your app,
move it over, and keep the rest of your app running in Sinatra.
