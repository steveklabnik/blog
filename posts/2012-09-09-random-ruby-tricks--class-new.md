---
title: "Random Ruby Tricks: Class.new"
date: 2012-09-09 15:41
---

If you didn't know, classes are first-class objects in Ruby:

```ruby
1.9.3p194 :001 > String.class
 => Class 
1.9.3p194 :002 > Class.class
 => Class 
```

How is this useful, though?

## Inheritance

You may create very simple classes at times. This often happens when
subclassing an error of some sort:

```ruby
class MyException < StandardError
end

raise MyException
```

That whole thing is awkward to me, though. Why bother with the end if you don't
need it? Turns out, it's easy to make your own `Class` object: just use
`Class.new`: 

```ruby
1.9.3p194 :001 > Class.new
 => #<Class:0x007fee209f42f8> 
```

But that doesn't help us a ton. Turns out `Class.new` takes an argument: the
class this new class inherits from:

```ruby
1.9.3p194 :002 > Class.new(StandardError)
 => #<Class:0x007fee209ee2e0> 
```

We can then save this in our own constant:

```ruby
1.9.3p194 :003 > MyException = Class.new(StandardError)
 => MyException 
1.9.3p194 :004 > MyException.new
 => #<MyException: MyException> 
1.9.3p194 :005 > MyException.ancestors
 => [MyException, StandardError, Exception, Object, Kernel, BasicObject] 
```

I think I like this notation a bit better than `class...end`. But many people
may not be familiar with it.

## Passing a block

Of course, you can pass a block to `Class.new` and it'll work like you'd
expect:

```ruby
1.9.3p194 :001 > Foo = Class.new do
1.9.3p194 :002 >     def bar
1.9.3p194 :003?>     puts "bar"
1.9.3p194 :004?>     end
1.9.3p194 :005?>   end
 => Foo 
1.9.3p194 :006 > Foo.new.bar
bar
 => nil 
```

The block gets `class_eval`'d. I haven't found a good use for this one,
exactly, but it's good to know about!

## `new` vs `initialize`

Ever wonder why you call `Foo.new` but define `Foo.initialize`? It's pretty
simple. Here:

```c
VALUE rb_class_new_instance(int argc, VALUE *argv, VALUE klass)
{
    VALUE obj;

    obj = rb_obj_alloc(klass);
    rb_obj_call_init(obj, argc, argv);

    return obj;
}
```

Obviously! This is the source for `Foo.new`. You might not read C, but it's
pretty simple: it first allocates the space for the object using
`rb_obj_alloc`, and then calls `initialize` using `rb_obj_call_init`.
