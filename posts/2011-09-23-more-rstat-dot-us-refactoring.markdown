---
layout: post
title: "More rstat.us Refactoring"
date: 2011-09-23 17:03
comments: true
categories:
---

Hey everyone! I just wanted to share One More Thing with you about this rstat.us
refactoring.

The main thrust of the last article I posted was to show you a technique for
extracting a class, getting it under some kind of test, and then refactoring it
a bit. Refactoring is always an iterative process, and Ryan Bates from the
always awesome [Railscasts](http://railscasts.com) asked me why I made the
Salmon class into a module, especially given my recent [rant](/2011/09/06/the-secret-to-rails-oo-design.html)
against modules. The answer was, 'because it's simpler, and the first thing
I thought of.' He shared with me an alternate implementation that I like too,
and I wanted to share with you. Check it:

``` ruby
class SalmonNotifier
  def initialize(user, feed)
    @user = user
    @feed = feed
  end

  def mention(update)
    deliver OStatus::Salmon.new(update.to_atom("http://#{@user.author.domain}/"))
  end

  def follow
    deliver OStatus::Salmon.from_follow(@user.author.to_atom, @feed.author.to_atom)
  end

  def unfollow
    deliver OStatus::Salmon.from_unfollow(@user.author.to_atom, @feed.author.to_atom)
  end

  protected

  def deliver(salmon)
    send_envelope_to_salmon_endpoint salmon.to_xml(@user.to_rsa_keypair)
  end

  def send_envelope_to_salmon_endpoint(envelope)
    uri = URI.parse(@feed.author.salmon_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.post(uri.path, envelope, {"Content-Type" => "application/magic-envelope+xml"})
  end
end
```

This follows a more OO style, and is a bit more well-factored. Here's his
description of what he did:

> 1. Switched to a class and gave it a name that is a noun (maybe name
> should be different though).
> 2. Moved common method params into instance variables.
> 3. This simplified the mention/follow/unfollow methods enough to be on one line.
> 4. Renamed "send_to_salmon_endpoint" to "deliver" because it feels
> nicer, the "salmon endpoint" can be assumed due to the name of the
> class. I generally don't like to put the class name in the method
> name.
> 5. Extracted commented out into its own method with the same name. I
> don't know if this is really necessary though (same reason as above).
> 
> The only thing that bothers me now is the constant access of
> @user.author and @feed.author. This makes me think it should be
> interacting directly with authors. However you still need access to
> @user.to_rsa_keypair but maybe that method could be moved elsewhere
> more accessible.

All of these changes are pretty good. Ryan's suggestions for moving forward are
pretty good, as well, but I'd add one more thing: we're starting to collect a
bunch of methods all related to delivering more generic HTTP requests in the
protected section. This also might be worth pulling out, too.  Protected/private
in general is a minor smell that indicates there's code being used multiple
times that's not part of the main objective of the class.  It might not be worth
it yet, but then again, it might. Speaking of protected methods, you might
wonder why I ended up mocking out my protected method in the last post, as well.
There are no more tests that actually test the method is working properly.  This
is true, and it's because I was leading into thinking of something like this.
Mocked tests are almost always unit tests, and two methods are two separate
units, so I had just ended up doing it out of habit. This further shows that
maybe an extraction of another class is worthwhile.
