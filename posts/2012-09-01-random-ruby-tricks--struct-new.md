---
title: "Random Ruby Tricks: Struct.new"
date: 2012-09-01 22:26
---

One of my favorite classes in Ruby is `Struct`, but I feel like many Rubyists
don't know when to take advantage of it. The standard library has a lot of
junk in it, but `Struct` and `OStruct` are super awesome.

## Struct

If you haven't used `Struct` before, here's [the documentation of Struct from
the Ruby standard library](http://www.ruby-doc.org/core-1.9.3/Struct.html).

Structs are used to create super simple classes with some instance variables
and a simple constructor. Check it:

```ruby
Struct.new("Point", :x, :y) #=> Struct::Point
origin = Struct::Point.new(0,0) #=> #<struct Struct::Point x=0, y=0>
```

Nobody uses it this way, though. Here's the way I first saw it used:

```ruby
class Point < Struct.new(:x, :y)
end

origin = Point(0,0)
```

Wait, what? Inherit...from an instance of something? Yep!

```ruby
1.9.3p194 :001 > Struct.new(:x,:y)
 => #<Class:0x007f8fc38da2e8> 
```

`Struct.new` gives us a `Class`. We can inherit from this just like any other
`Class`. Neat!

However, if you're gonna make an empty class like this, I prefer this way:

```ruby
Point = Struct.new(:x, :y)
origin = Point(0,0)
```

Yep. Classes are just constants, so we assign a constant to that particular
`Class`. 

## OStruct

[`OStruct`](http://ruby-doc.org/stdlib-1.9.3/libdoc/ostruct/rdoc/OpenStruct.html)s are like `Struct` on steroids. Check it:

```ruby
require 'ostruct'

origin = OpenStruct.new
origin.x = 0
origin.y = 0

origin = OpenStruct.new(:x => 0, :y => 0)
```

`OStruct`s are particularly good for configuration objects. Since any method
works to set data in an `OStruct`, you don't have to worry about enumerating
every single option that you need:

```ruby
require 'ostruct'

def set_options
  opts = OpenStruct.new
  yield opts
  opts
end

options = set_options do |o|
  o.set_foo = true
  o.load_path = "whatever:something"
end

options #=> #<OpenStruct set_foo=true, load_path="whatever:something"> 
```

Neat, eh?

## Structs for domain concepts

You can use `Struct`s to help reify domain concepts into simple little classes.
For example, say we have this code, which uses a date:

```ruby
class Person
  attr_accessor :name, :day, :month, :year

  def initialize(opts = {})
    @name = opts[:name]
    @day = opts[:day]
    @month = opts[:month]
    @year = opts[:year]
  end

  def birthday
    "#@day/#@month/#@year"
  end
end
```

and we have this spec

```ruby
$:.unshift("lib")
require 'person'

describe Person do
  it "compares birthdays" do
    joe = Person.new(:name => "Joe", :day => 5, :month => 6, :year => 1986)
    jon = Person.new(:name => "Jon", :day => 7, :month => 6, :year => 1986)

    joe.birthday.should == jon.birthday
  end
end
```

It fails, of course. Like this:

```
$ rspec
F

Failures:

  1) Person compares birthdays
     Failure/Error: joe.birthday.should == jon.birthday
       expected: "7/6/1986"
            got: "5/6/1986" (using ==)
     # ./spec/person_spec.rb:9:in `block (2 levels) in <top (required)>'

Finished in 0.00053 seconds
1 example, 1 failure

Failed examples:

rspec ./spec/person_spec.rb:5 # Person compares birthdays
```

Now. We have these two birthdays. In this case, we know about why the test was
failing, but imagine this failure in a real codebase. Are these month/day/year
or day/month/year? You can't tell, it could be either. If we switched our code
to this:

```ruby
class Person
  attr_accessor :name, :birthday

  Birthday = Struct.new(:day, :month, :year)

  def initialize(opts = {})
    @name = opts[:name]
    @birthday = Birthday.new(opts[:day], opts[:month], opts[:year])
  end
end

```

We get this failure instead:

```
$ rspec
F

Failures:

  1) Person compares birthdays
     Failure/Error: joe.birthday.should == jon.birthday
       expected: #<struct Person::Birthday day=7, month=6, year=1986>
            got: #<struct Person::Birthday day=5, month=6, year=1986> (using ==)
       Diff:
       @@ -1,2 +1,2 @@
       -#<struct Person::Birthday day=7, month=6, year=1986>
       +#<struct Person::Birthday day=5, month=6, year=1986>
     # ./spec/person_spec.rb:9:in `block (2 levels) in <top (required)>'

Finished in 0.00092 seconds
1 example, 1 failure

Failed examples:

rspec ./spec/person_spec.rb:5 # Person compares birthdays
```

We have a way, way more clear failure. We can clearly see that its our days
that are off.

Of course, there are other good reasons to package related instance variables
into `Struct`s, too: it makes more conceptual sense. This code represents our
intent better: a Person has a Birthday, they don't have three unrelated numbers
stored inside them somehow. If we need to add something to our concept of
birthdays, we now have a place to put it.
