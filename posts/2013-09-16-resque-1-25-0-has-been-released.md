---
title: "Resque 1.25.0 has been released"
date: 2013-09-16 09:47
---

I've just released Resque 1.25.0! Resque is the most stable, widely-used job queue for Ruby. It uses Redis as its backing store.

This release is thanks to [adelcambre](https://github.com/adelcambre), who took the time to get it over the finish line! <3.

A total of 19 contributors helped out with this release, with 77 commits. Thank you to everyone!

This release contains no changes from the 1.25.0.pre release that was put out a few weeks ago, so if you're using it, you can upgrade with no problems.

## CHANGES

You can see the full CHANGELOG [here](https://github.com/resque/resque/blob/v1.25.0/HISTORY.md).

This release had a pre-release because of one big change: [a refactor to the
forking code](https://github.com/resque/resque/pull/1017/files). This was
introduced to fix a problem: the exit syscall raises a SystemExit Exception in
ruby, its exit is treated as a failure, thus deregistering the worker. After
the refactor + fix, things should be peachy. But please give the prerelease a
try.

In addition, it has been discovered that we have accidentally introduced a
SemVer violation back in v1.23.1: https://github.com/resque/resque/issues/1074

I take SemVer seriously, and apologize for this change. SemVer states that at
this time, I should basically do whatever. Since this fixes a bug, I'm inclined
to leave it in. If this introduces a significant problem for you, please let me
know. Since others might now be relying on this new behavior, I'm not 100% sure
what the best option is. Your feedback helps.

## INSTALLING

To get 1.25.0 installed, just use `gem install`:

```bash
$ gem install resque
```

Or include it in your `Gemfile`:

```ruby
gem 'resque', '~> 1.25.0'
```

## SOURCE

You can find the source [on GitHub](https://github.com/resque/resque).
