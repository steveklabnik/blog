---
title: "How can I contribute to Ruby on Rails?"
date: 2012-07-05 09:54
---

After RailsConf this year, I joined the Rails Issue Team. This means that I
help triage issues that people have filed, try to reproduce errors, and point
core team members at ones that are most important. Since doing that, a few
people have asked me how to get started, so I decided to draw up my thoughts
here.

Note that there is also an [official Rails Guide on contribution](http://edgeguides.rubyonrails.org/contributing_to_ruby_on_rails.html) too.

## Who helps with Rails?

First up is the Rails Core team: [http://rubyonrails.org/core/](http://rubyonrails.org/core/)
Core team members essentially have the authority to merge code into the main
Rails codebase. Someone from core reviews every patch that goes into Rails.

Issues team: This group of people has the authority to tag, close, and edit
tickets, but can't actually merge code.

Documentation team: A few awesome people contribute by writing documentation
rather than just code. Docs are super important, so all these people are also
awesome.

Everyone else!: Rails is open source after all, and 1224 people have
contributed at least one patch.

You can find everyone's commits and count here: [http://contributors.rubyonrails.org/](http://contributors.rubyonrails.org/)

### About payment

Nobody is paid to just work on Rails itself. Everyone is a volunteer. Rails
runs on a 'scratch your own itch' policy. This has two big effects:

1. Pull requests can sit sometimes. Pull requests must be merged by a Core
member, so after your patch is submitted, you're basically waiting on
someone from a group of about 12 to decide 'hey, I should merge some pull
requests today' and get on it. There are currently 168 pull requests open on
Rails, the oldest of which is three months since its last comment.

2. Feature requests may simply fall on deaf ears. If you have a suggestion for
Rails, and you don't want to implement it, you need to convince someone to
write the code for you. But it's not as if the core team has a list of
requested features that it goes over when working. Of course, they have a list
of the features that they want to add, but it's not like it's comprehensive
from every feature requested. That said, it's possible that your idea may
spark the attention of someone, so sharing a feature request is valuable.
But don't feel entitled here.

## I found a bug, what should I do?

File a ticket on the [Rails issue tracker](https://github.com/rails/rails/issues)
and give us as much information as possible.

Note that only 3.2 is getting bug fixes. 3.1 and earlier are security fix only.

Good: Clear bug report, listed versions of Rails and/or Ruby and backtrace if
applicable

Better: Steps to reproduce, maybe with a sample app. 

Best: All of the above with a patch that fixes the problem.

## I've found a security vulnerability, what should I do?

Don't submit something to the tracker. Instead, check out [this page](http://rubyonrails.org/security)
which outlines the security policy. Basically, send an email to [security@rubyonrails.org](mailto:security@rubyonrails.org).

## I have a feature request, what should I do?

Please don't file an Issue; it's a bad medium for discussing these kinds of
things. It also makes it harder to keep track of what's a bug and what's a
wish for future changes. Please post to the [rails-core mailing list](https://groups.google.com/forum/?fromgroups#!forum/rubyonrails-core)
instead. Your idea is much more likely to be seen and discussed there.

You may get no response from the list. People tend to say nothing if they're
not interested. It happens.

## I want feedback on an idea before I work up a patch

Same as a feature request, please ping the [rails-core mailing list](https://groups.google.com/forum/?fromgroups#!forum/rubyonrails-core).

## I've written a patch, now what?

Submit a pull request with your patch. Someone from core will review it, and
may ask you to modify what you've done. Eventually it will either get merged
into Rails or rejected.

## I want to write docs, now what?

Don't sumbit them as issues to the main Rails repo, instead, check out
[docrails](http://weblog.rubyonrails.org/2012/3/7/what-is-docrails/).

## I want to help, but don't know what to work on!

We try to tag each issue with the part of Rails it affects. If you don't know
where to get started, pick your favorite part of Rails and sort the issues
by that part. For example [here are all the issues relating to the asset pipeline](https://github.com/rails/rails/issues?labels=asset+pipeline&page=1&sort=updated&state=open).

Try to reproduce the bug locally, write a test that fails, write a patch, boom!

## How do I set up my local machine to work on Rails

Check the Rails Guide [here](http://edgeguides.rubyonrails.org/contributing_to_ruby_on_rails.html#running-the-test-suite).
