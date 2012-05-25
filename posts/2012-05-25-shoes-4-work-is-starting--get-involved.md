---
title: "Shoes 4 work is starting: get involved"
date: 2012-05-25 14:23
---

As you know, I've been doing a lot of work over the last few years to keep
\_why's [Shoes](http://shoesrb.com) project going. A few other intrepid
individuals have been doing a lot as well. We're starting to work on Shoes 4,
and we'd love your help.

## A little about Shoes

If you didn't know, Shoes is a GUI toolkit for Ruby. It uses blocks heavily:

``` ruby
Shoes.app do
  para "Push the button"
  
  button "Me! Me!" do
    alert "Good job."
  end
end
```

Super simple. You get native widgets on all platforms.

## Shoes 4

Shoes 4 is a total re-write of Shoes. It's being done in JRuby. There are a
few related projects:

* ShoesSpec: An executable specification for Shoes implementations, so that
  others can co-exist. A few other Shoes projects exist already, and a unified
  interface will be great.
* Shoes-mocks: Sort of the opposite, a dummy set of Shoes that you can use to
  test applications written in Shoes.
* The website: A new website is being made as well. Help here would be just as
  awesome as work on Shoes itself.

## What we need

Of course, pull requests are always welcome. But if you use Shoes or want to,
please get involved in [the discussions](http://github.com/shoes/shoes4/issues)
about what Shoes 4 will look like on the bug tracker. Feel free to open an
Issue with any topic for discussion. Thoughts from users, current and potential,
are always awesome!

Let's all have fun developing Shoes 4!
