---
title: "Using Puma on Heroku"
date: 2013-02-24 14:58
---

I'm a big fan of [Puma](http://puma.io) these days. Today, I converted my blog
over to use Puma, and I figured I'd share how I did it. This blog uses Sinatra.

If you want to look ahead,
[here](https://github.com/steveklabnik/blog/commit/3cd0f04ed29a25df6d6dfeeffccd2e12548c05cf) is the commit.

## Gemfile

Installing Puma is really easy: just add `gem 'puma'` to your Gemfile. Done!

This section is way too easy. I'm sorry Puma isn't more complicated. ;)

## Procfile

Heroku attempts to guess how you want to run your site, but sometimes it
guesses wrong. I prefer to be a bit more explicit, and in Puma's case, it will
guess wrong and use Webrick, so we need to do this step.

Heroku uses a gem called `foreman` to run your application. Basically, `foreman` gives you a 'Procfile' that lets you specify different processes and their types, and then foreman manages running them for you.

To use `foreman`, add it to your Gemfile:

```
gem 'foreman'
```

And then make a `Procfile`:

```
web: rackup -s puma -p $PORT
```

This says "I want my web processes to run this command." Simple. We tell
`rackup` to use Puma with the `-s` flag, for 'server.'

To start up your application, normall you'd run `rackup` yourself, but now, you
use `foreman`:

```
$ bundle exec foreman start
```

It'll print out a bunch of messages. Mine looks like this:

```
$ bundle exec foreman start
15:05:05 web.1  | started with pid 52450
15:05:06 web.1  | Puma 1.6.3 starting...
15:05:06 web.1  | * Min threads: 0, max threads: 16
15:05:06 web.1  | * Environment: development
15:05:06 web.1  | * Listening on tcp://0.0.0.0:5000
```

Now you can `open http://localhost:5000` in another terminal, and bam! Done.

## Other Rubies

If you really want Puma to scream, you should run with Rubinius or JRuby. I
haven't done this yet, but once I do, I'll update this post with instructions.

## Rails

If you're using Rails, it's the same process, but the Procfile line should be

```
web: bundle exec puma -p $PORT
```

Easy!
