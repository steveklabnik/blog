---
layout: post
title: "ActiveRecord (and Rails) Considered Harmful"
date: 2011-12-30 11:00
---

> It is practically impossible to teach OO design to students that have
> had a prior exposure to Rails: as potential programmers they are mentally
> mutilated beyond hope of regeneration.
> 
> - Edsger W. Dijkstra (paraphrased)

I love ActiveRecord. It was the first ORM I'd ever interacted with. My first
technical employer had commissioned a DBA, and so of course, we wrote all our
own queries. Which was fine; I know my way around a JOIN or two. The problem
came when it was time to make a new class; time to write "SELECT * FROM
'tableName' WHERE 'id'='%'"... for each class. "Just copy one of the other
small classes, hack out everything, and change the table names," were my
instructions.  Fine. Whatever. But I knew there had to be a better way...

Along comes Rails. Holy crap, ActiveRecord is _awesome_! It writes the _exact_
SQL I would have written myself! I don't need to do _anything_. This is the
best thing since sliced bread. But years later, not everything is rainbows and
sunshine. I've written a _lot_ of crappy code, and most of it is due to
following Rails 'best practices.' Which is totally fine! Rails is kinda getting
old these days. It's no longer the new and shiny. But while Rails developers
have gotten really good at busting out little CRUD apps, we haven't moved web
application design _forward_ in a really, really long time.

And that's what Rails did, really. That fifteen minute blog video was shocking.
I know several people that threw away two or three week old projects and
re-built their stuff in Rails within moments of watching it. And Rails has
continued to lead the way in improving how we build rich applications on the
web; the (not so but kinda whatever nobody but me cares) RESTful routing was
great. The asset pipeline, though it has some bugs, has been great. The
obsession with DRY has been great. The test obsession has been great. But Rails
has also not been great in aiding us in writing maintainable software. Many of
Rails' design decisions make it difficult to write _great_ software. It helps
us write good software, but that isn't enough anymore.

The real problem is that to truly move forward, Rails will have to re-invent
itself, and I'm not sure that it can.

## ActiveRecord is the problem

I'm not going to talk about all of the problems Rails has today, but I'd like
to show you the biggest, most central one: ActiveRecord.

ActiveRecord's greatest strength is also its problem: Tying class names to
table names. This means that it's impossible to de-couple your persistence
mechanism from your domain logic. You can manage it through a combination of
`set_table_name`, making a bunch of `Repository` classes, and careful coding...
but then you might as well be using DataMapper. Except the Ruby library of the
same name doesn't really implement the DataMapper pattern all that well either,
having the same issue of tying it all together.

This has another interesting effect: it led directly to the 'fat model'
recommendation. While 'get your stuff out of the controller' is correct, it's
lead Rails developers to build huge, monolithic models that are hard to test,
and violate SRP. It took me two and a half years to realize that Ruby classes
in the models folder don't have to inherit from `ActiveRecord::Base`. That
is a problem.

We've gotten into a situation with a local minimum: our quest for great software
has lead us to DRY ourselves into a corner. Now we have code that's incredibly
tightly coupled. Our 'single responsibility' is 'anything and everything that
tangentially relates to a Post.'

## ActionController is the problem

ActionController relies on instance variables to pass information from the
controller to the view. Have you ever seen a 200 line long controller method?
I have. Good luck teasing out which instance variables actually get set over the
course of all those nested `if`s.

The whole idea is kinda crazy: Yeah, it looks nice, but we literally just say
'increase the scope of variables to pass data around.' If I wrote a post saying
"Don't pass arguments to methods, just promote your data to a global" I'd be
crucified. Yet we do the same thing (albeit on a smaller scale) every time we
write a Rails application.

## ActionView is the problem

The whole idea of logic in templates leads to all kinds of problems. They're
hard to test, they're hard to read, and it's not just a slippery slope, but a
steep one. Things go downhill _rapidly_.

What I'd really like to see is Rails adopting a 'ViewModel + templates' system,
with logic-less templates and presenter-esque models that represent the views.
The differences between Django's idea of 'views' and Rails' idea of 'views' are
interesting here.

## MVC is the problem

If you'll notice, I basically have said that models are a problem. Controllers
are a problem. Views are a problem. MVC has served the web well, even if it
isn't the GUI style MVC that named the pattern. But I think we're reaching its
limits; the impedance mismatch between HTTP and MVC, for example, is pretty
huge. There are other ways to build web applications; I'm particularly excited
about [WebMachine](http://rubyconf-webmachine.heroku.com/). I don't have a
constructive alternative to offer here, I just know there's a problem. I'm still
mulling this one over.

## It's still good, even with problems

I love Rails. I build software with it daily. Even with its flaws, it's been a
massive success. But because I love Rails, I feel like I can give it
straightforward criticism: it's easier to trash something you love. The real issue
is that changing these things would require some really serious changes. It'd
involve re-architecting large portions of things that people classically identify
with Rails, and I'm not sure that Rails wants to or can do that.

This post is light on examples. I want this to be the _starting point_ of a
discussion, not the end of it. Expect more, in detail, from me in the future.
What do you think? Are these problems pain points for you? Are they worth
fixing? Are they actually problems?
