---
title: "redis-namespace 1.3.1: security release"
date: 2013-08-03 16:35
---

TL;DR: if you use [redis-namespace](https://rubygems.org/gems/redis-namespace) and you use `send`, `Kernel#exec` may get called. Please upgrade to 1.3.1 immediately.

Link to the fix: [https://github.com/resque/redis-namespace/commit/6d839515e8a3fdc17b5fb391500fda3f919689d6](https://github.com/resque/redis-namespace/commit/6d839515e8a3fdc17b5fb391500fda3f919689d6)

## The Problem

Redis has an EXEC command. We handle commands through `method_missing`.
This works great, normally:

```ruby
  r = Redis::Namespace.new("foo")
  r.exec # => error, not in a transaction, whatever
```

Here's the problem: `Kernel#exec`. Since this is on every object, when
you use `#send`, it skips the normal visibility, and calls the private
but defined `Kernel#exec` rather than the `method_missing` verison:

```ruby
  r = Redis::Namespace.new("foo")
  r.send(:exec, "ls") # => prints out your current directory
```

We fix this by not proxying `exec` through `method_missing`.

You are only vulnerable if you do the always-dangerous 'send random
input to an object through `send`.' And you probably don't. A cursory
search through GitHub didn't find anything that looked vulnerable.

However, if you write code that wraps or proxies Redis in some way, you
may do something like this.

The official Redis gem does not use `method_missing`, so it should not
have any issues:
https://github.com/redis/redis-rb/blob/master/lib/redis.rb#L2133-L2147

I plan on removing the `method_missing` implementation in a further
patch, but since this is an immediate issue, I wanted to make minimal
changes.

Testing this is hard, `#exec` replaces the current running process. I
have verified this fix by hand, but writing an automated test seems
difficult.

:heart::cry:
