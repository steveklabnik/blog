---
layout: post
title: "Better Ruby Presenters"
date: 2011-09-09 12:00
categories:
---

My [last blog post](/2011/09/06/the-secret-to-rails-oo-design.html) caused a bit
of a stir in some circles. I got a bunch of emails. Apparently, I need to expand
on a few things. So here we go. Let's rap about the Presenter pattern, shall we?

## No seriously, helpers suck

> In Ruby, everything is an object. Every bit of information and code can be
given their own properties and actions. - ruby-lang.org/about

... except helpers. Why is it in Ruby that everything is an object, even
integers, yet as soon as we need to format a date, we all turn into Dijkstra and
bust out structured programming? Actually, come to think of it, Dijkstra
wouldn't even write any code, because it's beneath him, but you get the idea.
(if you don't get this, it's a joke. About proofs, telescopes, and CS...)
Helpers are like a compliment that you don't want to give, but feel obligated
to: "Yeah, I mean, well, you tried, and that's what counts, right?"

This is the topic of a future post, but when programming in a langauge, you want
to work with its primary methods of abstraction. In Ruby, that's objects, and
there's a good reason for that: functions don't provide a sufficient amount of
power to tackle hard problems. I don't want to get into this either, but there's
a reason that objects exist, and that nobody's making procedural languages
anymore.  No biggie. C has a special place in my heart.

But I digress: objects > functions. At least in the context of getting stuff
done in Ruby. This pretty much applies to most of the rest of the points in this
post, so just keep that in the back of your brain.

## Why not a class method?

Well, first of all, [class methods also suck](http://nicksda.apotomo.de/2011/07/are-class-methods-evil/). Here's the
issue: Can you tell me the difference between these two methods?

``` ruby
def foo
  "hello"
end

class Bar
  def self.foo
    "hello"
  end
end

foo
Bar.foo
```

Yep, that's right. You can see it clearly from the last two lines: class methods
are functions that happen to be namespaced. That means they're slightly better,
but really, `DictionaryPresenter.as_dictionary(something)` might as well just be
a helper. At least `as_dictionary(something)` is shorter.

Here's another reason: I didn't make that method be a class method, even though
there was no state, because a really real presenter (I mean, that was a real
world example, but...) generally works a little different. Usually, I make
presenters that actually stand in for the objects they're presenting. Check
this out. Here's the presenter I showed you:

``` ruby
class DictionaryPresenter
  def initialize(collection)
    @collection = collection
  end

  def as_dictionary
    dictionary = ('A'..'Z').inject({}) {|h, l| h[l] = []; h}

    @collection.each do |p|
      dictionary[p.title[0]] << p
    end

    dictionary
  end
end
```

The real-world presenter that I used this for looked like this:

``` ruby
class DictionaryPresenter
  include Enumerable

  def initialize(collection)
    @dictionary = ('A'..'Z').inject({}) {|h, l| h[l] = []; h}

    collection.each do |p|
      @dictionary[p.title[0]] << p
    end
  end

  def each &blk
    @dictionary.each &blk
  end
end
```

... or close to this. There was an 'other' category, and a few other things...
but you get the idea. Now, instead of this:

``` ruby
@posts = DictionaryPresenter.new(Post.all).as_dictionary
```

You do this:

``` ruby
@posts = DictionaryPresenter.new(Post.all)
```

And the presenter actually stands in for the hash. A subtle but important
difference. This gives you more options, because you have a real, live object
instead of just some random processing. With this simplistic presenter, you
might not see a huge benefit, but often, you'll want something a bit more
complicated. And since this was what I had in my head, I didn't make
`as_dictionary` be a static method.

Oh, and presenters that decorate a single object rather than a collection
often implement `method_missing`, so that you only _add_ methods rather than
hide most of them. Some don't. It depends.

## Blocks vs. Policy

I also showed off a Ruby version of a design pattern known as the Policy
pattern, or sometimes the Strategy pattern. Turns out that Policy is often
a bit heavyweight for Ruby, especially in an example like this, so I wanted
to show you an alternate version of it, taking advantage of a Ruby feature:
blocks.

For reference, the old code, put into the new code:

``` ruby
class DictionaryPresenter
  include Enumerable

  def initialize(policy, collection)
    @dictionary = ('A'..'Z').inject({}) {|h, l| h[l] = []; h}

    collection.each do |p|
      @dictionary[policy.category_for(p)] << p
    end
  end

  def each &blk
    @dictionary.each &blk
  end
end

class UserCategorizationPolicy
  def self.category_for(user)
    user.username[0]
  end
end
```

We could use blocks instead:

``` ruby
class DictionaryPresenter
  include Enumerable

  def initialize(collection, &blk)
    @dictionary = ('A'..'Z').inject({}) {|h, l| h[l] = []; h}

    collection.each do |p|
      @dictionary[blk.call(p)] << p
    end
  end

  def each &blk
    @dictionary.each &blk
  end
end

DictionaryPresenter.new(Post.all) do |item|
  item.title[0]
end
```

While this is shorter, and a bit more Rubyish, it also means that we lose the
<a href="http://en.wikipedia.org/wiki/Reification_(computer_science)">reification</a> of
our concept of a policy. While this is _shorter_, I find it more
confusing. Why am I giving this one line block to the presenter? It's not really
clear to me. And I can't give a better name to item... and if I want to change
the policy, it has to be done in every place we use the presenter...

This does get to the root of another thing that will end up being a follow-up:
What's the difference between closures and objects? If you don't know, maybe
this will get you thinking:

``` ruby
#ugh, this is slightly odd, thanks Ruby!
def apply(proc=nil, &blk)
  if block_given?
    blk.call
  else
    proc.call
  end
end

proc = Proc.new do
  puts "a proc!"
end

class MyProc
  def call
    puts "an object!"
  end
end

my_proc = MyProc.new

apply do
  puts "a block!"
end

apply proc

apply my_proc
```

Chew on that a while.

## This is too verbose

Absolutely. `DictionaryPresenter.new(PostCategorizationPolicy, Post.all).as_dictionary`
is too long. 100% there. Good thing that I'd _actually_ write this:

``` ruby
Dictionary.new(Post.all, ByTitle)
```

I switched the arguments around, because it reads better. When writing blog
posts, you have to balance writing code samples that explain what you're
trying to say, and ones that are 'real.' I tend to be a bit more verbose with
things like this, because it's easier for someone who just jumps in to remember
what all the parts are... then again, by _not_ showing the 'real code,' people
might end up implementing the crappy, verbose version. It's always a trade-off,
and I may or may not make the right choice. It happens.

And yes, even earlier in this blog post: I said `DictionaryPresenter` and I'd
really just say `Dictionary`.

## Where does all of this go?

You've got two options, and only one of them is good: You should make a
directory in app for your presenters. In this case, I'd be running
`touch app/presenters/dictionary.rb` pretty quick. The other case is to
put things in lib. This whole debacle uncovers something that @avdi went
on a rant about over the last few days: models don't have to inherit from
anything. Here's [what Wikipedia says about models](http://en.wikipedia.org/wiki/Model–view–controller#Concepts ):

> The model manages the behaviour and data of the application domain, responds
> to requests for information about its state (usually from the view), and
> responds to instructions to change state (usually from the controller). In
> event-driven systems, the model notifies observers (usually views) when the
> information changes so that they can react.

See anything about "saves stuff to the database?" Okay, 'manages... data' could
be, but the point is, it's not _required_. Models are the reification of a
concept that exists in your application domain. Persistance is not required for
every concept.

Therefore, if it relates to your problem domain, it goes in app. If it doesn't,
it goes in lib. Something like `Dictionary`? Depends on how important you think
it is. It's probably pretty important; that's why you made it a class.

## Design Patterns? Are you serious?

Yes. Design patterns don't suck, Design patterns _in Java_ suck. I'm not even
going to start this one here, expect more in this space soon.

Design patterns are great, and they're totally useful in Ruby.

## In conclusion: A shout-out

I hope you've enjoyed this small digression on Presenters. If you're gonna use
presenters in your application, I encourage you to write simple ones as simple
Ruby classes, but if they get slightly more complicated, you need to check out
[Draper](https://github.com/jcasimir/draper) by my buddy Jeff Casimir. It lets
you do stuff like this:

``` ruby
class ArticleDecorator < ApplicationDecorator
  decorates :article

  def author_name
    model.author.first_name + " " + model.author.last_name
  end
end

article = ArticleDecorator.find(1)
article.author_name
```

There's a lot of features to it, so check it out on GitHub. Totally worthwhile.
