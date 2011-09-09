---
published: true
title: The Secret to Rails OO Design
layout: post
---

I often tell people that I learned Ruby via Rails. This is pretty much the worst
way to do it, but I'd learned so many programming languages by then that it
didn't hinder me too much. The one thing that it did do, however, was give me a
slightly twisted sense of how to properly design the classes needed in a Rails
app. Luckily, I obsessively read other people's code, and I've noticed that
there's one big thing that is common in most of the code that's written by
people whose design chops I respect.

This particular thing is also seemingly unique to those people. It's not
something that people who don't write good code attempt, but do badly. It's like
a flag, or signal. Now, when I see someone employ this, I instantly think "they
get it." Maybe I'm giving it too much credit, but this advanced design technique
offers a ton of interconnected benefits throughout your Rails app, is easy to
imploy, and speeds up your tests by an order of magnitude or more.
Unfortunately, to many beginning Rails devs, it's non-obvious, but I want _you_
to write better code, and so I'm here to 'break the secret,' if you will, and
share this awesome, powerful technique with you.

It's called the 'Plain Old Ruby Domain Object.'

Yep, that's right. A Ruby class that inherets from nothing. It's so simple that
it hides in plain sight. Loved by those who've mastered Rails, Plain Old Ruby
Objects, or "POROs" as some like to call them, are a hidden weapon against
complexity. Here's what I mean. Examine this 'simple' model:

{% codeblock lang:ruby %}
class Post < ActiveRecord::Base
  def self.as_dictionary
    dictionary = ('A'..'Z').inject({}) {|h, l| h[l] = []; h}

    Post.all.each do |p|
      dictionary[p.title[0]] << p
    end

    dictionary
  end
end
{% endcodeblock %}

We want to display an index page of all our posts, and do it by first letter.
So we build up a dictionary, and then put our posts in it. I'm assuming we're
not paginating this, so don't get caught up in querying for all Posts. The
important thing is the idea: we can now display our posts by title:

{% codeblock lang:haml %}
- Post.as_dictionary do |letter, list|
  %p= letter
  %ul
  - list.each do |post|
    %li= link_to post
{% endcodeblock %}

Sure. And in one way, this code isn't _bad_. It's also not good: We've mixed a
presentational concern into our model, which is supposed to represent buisness
logic. So let's fix that, via a Presenter:

{% codeblock lang:ruby %}
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
{% endcodeblock %}

We can use it via `DictionaryPresenter.new(Post.all).as_dictionary`. This has
tons of benefits: we've moved presentation logic out of the model. We've
_already_ added a new feature: any collection can now be displayed as a
dictionary. We can easily write isolated tests for this presenter, and they will
be _fast_.

This post isn't about the Presenter pattern, though, as much as I love it. This
sort of concept appears in other places, too, "this domain concept deserves its
own class." Before we move to a different example, let's expand on this further:
if we want to sort our Posts by title, this class will work, but if we want to
display, say, a User, it won't, because Users don't have titles. Furthermore,
we'll end up with a lot of Posts under "A," because the word "a" is pretty
common at the beginning of Posts, so we really want to take the second word in
that case. We can make two kinds of presenters, but now we lose that generality,
and the concept of 'display by dictionary' has two representations in our system
again. You guessed it: POROs to the rescue!

Let's change our presenter slightly, to also accept an organizational policy
object:

{% codeblock lang:ruby %}
class DictionaryPresenter
  def initialize(policy, collection)
    @policy = policy
    @collection = collection
  end

  def as_dictionary
    dictionary = ('A'..'Z').inject({}) {|h, l| h[l] = []; h}

    @collection.each do |p|
      dictionary[@policy.category_for(p)] << p
    end

    dictionary
  end
end
{% endcodeblock %}

Now, we can inject a policy, and have them be different:

{% codeblock lang:ruby %}
class UserCategorizationPolicy
  def self.category_for(user)
    user.username[0]
  end
end

class PostCategorizationPolicy
  def self.category_for(post)
    if post.starts_with?("A ")
      post.title.split[1][0]
    else
      post.title[0]
    end
  end
end
{% endcodeblock %}

Bam!

{% codeblock lang:ruby %}
DictionaryPresenter.new(PostCategorizationPolicy, Post.all).as_dictionary
{% endcodeblock %}

Yeah, so that's getting a bit long. It happens. :) You can see that now each
concept has one representation in our system. The presenter doesn't care how
things are organized, and the policies only dictate how things are organized. In
fact, my names sorta suck, maybe it should be "UsernamePolicy" and
"TitlePolicy", actually. We don't even care what class they are!

It goes further than that in other directions, too. Combining the flexibility of
Ruby with one of my favorite patterns from "Working Effectively with Legacy
Code," we can take complex computations and turn them into objects. Look at this
code:

{% codeblock lang:ruby %}
class Quote < ActiveRecord::Base
  #<snip>
  def pretty_turnaround
    return "" if turnaround.nil?
    if purchased_at
      offset = purchased_at
      days_from_today = ((Time.now - purchased_at.to_time) / 60 / 60 / 24).floor + 1
    else
      offset = Time.now
      days_from_today = turnaround + 1
    end
    time = offset + (turnaround * 60 * 60 * 24)
    if(time.strftime("%a") == "Sat")
      time += 2 * 60 * 60 * 24
    elsif(time.strftime("%a") == "Sun")
      time += 1 * 60 * 60 * 24
    end

    "#{time.strftime("%A %d %B")} (#{days_from_today} business days from today)"
  end
end
{% endcodeblock %}

Yikes! This method prints a turnaround time, but as you can see, it's a complex
calculation. We'd be able to understand this much more easily of we used Extract
Method a few times to break it up, but then we risk polluting our Quote class
with more stuff that's only relevant to pretty turnaround calculation. Also,
please ignore that this is also presentation on the model; we just care that
it's a complex bit of code for this example.

Okay, so here's the first step of this refactoring, which Feathers calls "Break
Out Method Object." You can open your copy of "Working Effectively With Legacy
Code" and turn to page 330 to read more. If you don't have a copy, get one.
Anyway, I digress. Here's the plan of attack:

1. Create a new class for the computation
2. Define a method on that class to do the new work.
3. Copy the body of the old method over, and change variable references to instance variables.
4. Give it an initialize method that takes arguments to set the instance variables used in step 3.
5. Make the old method delegate to the new class and method.

I've changed this slightly for Ruby, since we can't Lean On The Compiler, and a
few of Feathers' steps are about doing this. Anyway, let's try this on that
code. Step 1:

{% codeblock lang:ruby %}
class Quote < ActiveRecord::Base
  def pretty_turnaround
    #snip
  end

  class TurnaroundCalculator
  end
end
{% endcodeblock %}

Two:

{% codeblock lang:ruby %}
class TurnaroundCalculator
  def calculate
  end
end
{% endcodeblock %}

Three:

{% codeblock lang:ruby %}
class TurnaroundCalculator
  def calculate
    return "" if @turnaround.nil?
    if @purchased_at
      offset = @purchased_at
      days_from_today = ((Time.now - purchased_at.to_time) / 60 / 60 / 24).floor + 1
    else
      offset = Time.now
      days_from_today = @turnaround + 1
    end
    time = offset + (@turnaround * 60 * 60 * 24)
    if(time.strftime("%a") == "Sat")
      time += 2 * 60 * 60 * 24
    elsif(time.strftime("%a") == "Sun")
      time += 1 * 60 * 60 * 24
    end

    "#{time.strftime("%A %d %B")} (#{days_from_today} business days from today)"
  end
end
{% endcodeblock %}

I like to give it a generic name at first, and then give it a better one in step
5, after we see what it really does. often our code will inform us of a good
name.

Four:

{% codeblock lang:ruby %}
class TurnaroundCalculator
  def initialize(purchased_at, turnaround)
    @purchased_at = purchased_at
    @turnaround = turnaround
  end

  def calculate
    #snip
  end
end
{% endcodeblock %}

Five:

{% codeblock lang:ruby %}
class Quote < ActiveRecord::Base
  def pretty_turnaround
    TurnaroundCalculator.new(purchased_at, turnaround).calculate
  end
end
{% endcodeblock %}

Done! We should be able to run our tests and see them pass. Even if 'run our
tests' consists of manually checking it out...

So what's the advantage here? Well, we now can start the refactoring process,
but we're in our own little clean room. We can extract methods into our
TurnaroundCalcuator class without polluting Quote, we can write speedy tests
for just the Calculator, and we've split out the idea of calculation into one
place, where it can easily be changed later. Here's our class, a few
refactorings later:

{% codeblock lang:ruby %}
class TurnaroundCalculator
  def calculate
    return "" if @turnaround.nil?

    "#{arrival_date} (#{days_from_today} business days from today)"
  end

  protected

  def arrival_date
    real_turnaround_time.strftime("%A %d %B")
  end

  def real_turnaround_time
    adjust_time_for_weekends(start_time + turnaround_in_seconds)
  end

  def adjust_time_for_weekends(time)
    if saturday?(time)
      time + 2 * 60 * 60 * 24
    elsif sunday?(time)
      time + 1 * 60 * 60 * 24
    else
      time
    end
  end

  def saturday?(time)
    time.strftime("%a") == "Sat"
  end

  def sunday?(time)
    time.strftime("%a") == "Sun"
  end

  def turnaround_in_seconds
    @turnaround * 60 * 60 * 24
  end

  def start_time
    @purchased_at or Time.now
  end

  def days_from_today
    if @purchased_at
      ((Time.now - @purchased_at.to_time) / 60 / 60 / 24).floor + 1
    else
      @turnaround + 1
    end
  end
end
{% endcodeblock %}

Wow. This code I wrote three years ago isn't perfect, but it's almost
understandable now. And each of the bits makes sense. This is after two or three
waves of refactoring, which maybe I'll cover in a separate post, becuase this
was more illustrative than I thought... anyway, you get the idea. This is what I
mean when I say that I shoot for roughly five-line methods in Ruby; if your code
is well-factored, you can often get there.

This idea of extracting domain objects that are pure Ruby is even in Rails
itself. Check out this route:

{% codeblock lang:ruby %}
root :to => 'dashboard#index', :constraints => LoggedInConstraint
{% endcodeblock %}

Huh? LoggedInConstraint?

{% codeblock lang:ruby %}
class LoggedInConstraint
  def self.matches?(request)
    current_user
  end
end
{% endcodeblock %}

Whoah. Yep. A domain object that describes our routing policy. Awesome. Also,
validations, blatantly stolen from [omgbloglol](http://omgbloglol.com/post/392895742/improved-validations-in-rails-3):

{% codeblock lang:ruby %}
def SomeClass < ActiveRecord::Base
  validate :category_id, :proper_category => true
end

class ProperCategoryValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless record.user.category_ids.include?(value)
      record.errors.add attribute, 'has bad category.'
    end
  end
end
{% endcodeblock %}

This isn't a plain Ruby class, but you get the idea.

Now, you might be thinking, "Steve: This isn't just for Rails! You've lied!" Why
yes, actually, you've caught me: this isn't the secret to Rails OO, it's more of
a general OO design guideline. But there's something special about Rails which
seems to lure you into the trap of never breaking classes down. Maybe it's that
`lib/` feels like such a junk drawer. Maybe it's that the fifteen minute
examples only ever include ActiveRecord models. Maybe it's that more Rails apps
than not are (WARNING: UNSUBSTANTIATED CLAIM ALERT) closed source than open, so
we don't have as many good examples to draw upon. (I have this hunch since
Rails is often used to build sites for companies. Gems? Sure? My web app? Not so
much. I have no stats to back this up, though.)

In summary: Extracting domain objects is good. They keep your tests fast, your
code small, and make it easier to change things later. I have some more to say
about this, specifically the "keeps test fast" part, but I'm already pushing it
for length here. Until next time!
