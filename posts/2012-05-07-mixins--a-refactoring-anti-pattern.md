---
title: "Mixins: A refactoring anti-pattern"
date: 2012-05-07 13:51
---

I spend an unusually large amount of time thinking about interactions between
what I call 'past me' and 'future me.' It seems that my life changes
significantly every few years, and I like to ground myself by imagining how
odd it would be if 'current me' could tell 'past me' things like '[Someday, 
you'll be speaking at OSCON](http://www.oscon.com/oscon2012/public/schedule/detail/24042).'

It's not always general life stuff, though, it's often a trick or technique
with code. How many times have you learned something new, and then had that
terrible urge to go back and re-write all of that terrible, terrible code
you've written in the past? This happens to me constantly.

So here, let me show you something I realized that I used to do wrong all the
time.

Let's do it via a quiz. Of course, because I'm framing it this way, you'll
get the answer, but seriously, just play along.

## Two factorizations

Which code is better factored?

``` ruby
# app/models/post.rb
class Post
  include Behaviors::PostBehavior
end

# app/models/behaviors/post_behavior.rb
module Behaviors
  module PostBehavior
    attr_accessor :blog, :title, :body

    def initialize(attrs={})
      attrs.each do |k,v| send("#{k}=",v) end 
    end

    def publish
      blog.add_entry(self)
    end

    # ... twenty more methods go here
  end
end
```

or

``` ruby
class Post < ActiveRecord::Base
  def publish
    blog.add_entry(self)  
  end

  # ... twenty more methods go here
end
```

One line of reasoning asserts that the first example is better. Here's why:
all of the behavior is in one place, and the persistence is in another. A
clear win.

Another line of reasoning asserts that the second is better. Here's why:
it's significantly simpler. A clear win.

So which is right?

## They're both wrong

Both of these justifications are wrong. As far as I'm concerned, these two
classes are equally complex, but because there is a lot more ceremony in
version one, version two is preferable. Assertion one is wrong because both
are still in the same place, they're just in two different files. Assertion
two is wrong because it's not simpler than version one, it's equivalently
complex.

## Measures of complexity

Whenever we refactor, we have to consider what we're using to evaluate that
our refactoring has been successful. For me, the default is complexity. That
is, any refactoring I'm doing is trying to reduce complexity. So how do I
measure complexity?

One good way that I think about complexity on an individual object level comes
from security practices: the 'attack surface.' We call this 'encapsulation' in
object oriented software design. Consider these two objects:

``` ruby
class Foo
  def bar
  end

  def baz
  end
end

class Bar
  def quxx
  end
end
```

Bar has one less way into the object than Foo does. Hence the idea of a
'surface' that an attacker would have access to. A bigger surface needs more
defense, more attention, and is harder to lock down.

Note that I said 'one less.' If you said "Foo has a surface of two, and Bar
has a surface of one," you'd be wrong. Luckily, Ruby provides us with a simple
way to calculate attack surface. Just use this monkey patch: (I'm not suggesting
that you actually use this monkey patch.)

``` ruby
class BasicObject
  def attack_surface
    methods.count
  end
end
```

This gives us

``` ruby
1.9.2p318 > Foo.new.attack_surface
 => 59 
1.9.2p318 > Bar.new.attack_surface
 => 58 
```

Oooooh yeah. `Object.new.methods.count` is 57... we forgot about those. This
is why mixins do not really reduce the complexity of your objects. Both
versions of Post above have the same number of methods. How many, you ask?

``` ruby
 > Post.new.methods.count
 => 337
 > Post.new.methods.count - Object.new.methods.count
 => 236
```

In this case, my `Post` is an object that inherits from `ActiveRecord::Base`
and defines nothing else. ActiveRecord adds in 236 methods to our object. That
is a pretty huge increase.

## Reducing complexity through encapsulation

Several people have been dancing around this issue for a while by saying
something like 'Consider ActiveRecord a private interface, and never use it
from outside of your class.' They feel this exact pain, but enforce it through
social means rather than reducing the complexity of objects. Now, there are
good reasons to do that, so I don't think it's categorically wrong, but it
certainly is a compromise.

An implementation of DataMapper would be able to solve this problem,


``` ruby
class Post
  def initialize(title, body)
    @title = title
    @body = body
  end
end

class PostMapper
  def save(post)
    @database.insert(:posts, [post.title, post.body])
  end
end

PostMapper.new.save(Post.new("Hello DataMapper", "DM rocks"))
```

or the repository pattern:

``` ruby
class PostRepository
  def first
    title, body = @database.select(:posts, "LIMIT 1")
    Post.new(title, body)
  end
end
```

All incredibly theoretical and pretend. But note that the `Post` in both
instances has no methods defined on it that deal with persistence whatsoever.
We've used encapsulation to hide all of the details of the database in the
database, the details of the post logic in the `Post`, and we use the
Mapper or Repository to mediate between the two.

## Using Mixins the right way

Mixins are awesome, though, and can be used to reduce duplication. They're
for cross-cutting concerns:

``` ruby
class Post
  def summary
    "#{author}: #{body[0,200]}"
  end
end

class Comment
  def summary
    "#{author}: #{body[0,200]}"
  end
end
```

moves to

``` ruby
class Post
  include Summarizer
end

class Comment
  include Summarizer
end

module Summarizer
  def summary
    "#{author}: #{body[0,200]}"
  end
end
```

We've eliminated some duplication, even if we didn't reduce our method
surface. This is a win along a different axis, we just shouldn't fool ourselves
that we've made our classes 'simpler.'
