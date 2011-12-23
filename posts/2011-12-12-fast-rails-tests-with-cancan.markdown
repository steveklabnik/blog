---
layout: post
title: "Fast Rails Tests With CanCan."
date: 2011-12-12 13:19
comments: true
categories: 
---

If you haven't used it, [CanCan](https://github.com/ryanb/cancan) is a great
library for Rails that handles authorization for you. Its calling card is
simplicity; just do this:

```ruby
class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.is? :paying_customer
      can :show, Article
    else
      can :show, Article, :free => true
      cannot :show, Article, :free => false
    end
  end
end
``` 

And then in a controller:

```ruby
def show
  @article = Article.find(params[:id])
  authorize! :read, @article
end
```

Super simple! However, as simple as CanCan is, if you want to keep your test
times super low, there's a few things that you should know about.

## Incidental coupling: the silent killer

The biggest problem with CanCan from the Fast Tests perspective is that we've
got coupling with class names. In order to test our Ability class, we also have
to load User and Article. Let's try it without concern for how isolated our
tests are:

```ruby
require "cancan/matchers"
require "spec_helper"

describe Ability do
  let(:subject) { Ability.new(user) }
  let(:free_article) { Article.new(:free => true) }
  let(:paid_article) { Article.new(:free => false) }

  context "random people" do
    let(:user) { nil }

    it "can see free Articles" do
      subject.can?(:show, free_article).should be_true
    end

    it "cannot see non-free Articles" do
      subject.can?(:show, paid_article).should be_false
    end
  end

  context "paying users" do
    let(:user) do 
      User.new.tap do |u|
        u.roles << :paying_customer
      end
    end

    it "can see free Articles" do
      subject.can?(:show, free_article).should be_true
    end

    it "can see non-free Articles" do
      subject.can?(:show, paid_article).should be_true
    end
  end
end
```

A few notes about testing with CanCan: I like to organize them with contexts for
the different kinds of users, and then what their abilities are below. It gives
you a really nice way of setting up those `let` blocks, and our tests read real nicely.

Anyway, so yeah. This loads up all of our models, connects to the DB, etc. This
is unfortunate. It'd be nice if we didn't have to load up `User` and `Article`.
Unfortunately, there's no real way around it in our `Ability`, I mean, if you
want them to read all Articles, you have to pass in `Article`... hmm. What about
this?

```ruby
let(:free_article) { double(:class => Article, :free => true) }
let(:paid_article) { double(:class => Article, :free => false) }
```

Turns out this works just as well. CanCan reflects on the class that you pass
in, so if we just give our double the right class, it's all gravy. Now we're not
loading `Article`, but what about `User`?

The key is in the `||=`. If we pass in a `User`, we won't call `User.new`. So let's
stub that:

```ruby
let(:user) { double(:is? => false) }
let(:user) do 
  double.tap do |u| #tap not strictly needed in this example, but if you want multiple roles...
    u.stub(:is?).with(:paying_customer).and_return(true)
  end
end
```

Sweet! The first one is a random user: all their `is?` calls should be false.
The second is our user who's paid up; we need to stub out their role properly,
but that's about it.

## It's that easy

With some dillegence, isolating your tests isn't hard, and works really well. I
have a few more tests in the example I took this from, and 14 examples still
take about a third of a second. Not too shabby!

Happy authorizing!

Oh, and the final spec, for reference:

```ruby
require "cancan/matchers"
require "app/models/ability"

describe Ability do
  let(:subject) { Ability.new(user) }
  let(:free_article) { double(:class => Article, :free => true ) }
  let(:paid_article) { double(:class => Article, :free => false) }

  context "random people" do
    let(:user) { double(:is? => false) }

    it "can see free Articles" do
      subject.can?(:show, free_article).should be_true
    end

    it "cannot see non-free Articles" do
      subject.can?(:show, paid_article).should be_false
    end
  end

  context "users" do
    let(:user) do 
      double.tap do |u|
        u.stub(:is?).with(:user).and_return(true)
      end
    end

    it "can see free Articles" do
      subject.can?(:show, free_article).should be_true
    end

    it "can see non-free Articles" do
      subject.can?(:show, paid_article).should be_true
    end
  end
end
```
