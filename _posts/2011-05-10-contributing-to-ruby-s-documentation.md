---
published: true
title: Contributing to Ruby's Documentation
layout: post
---

Ruby 1.9.3 is coming out soon! [drbrain has challenged the Ruby community to
improve its documentation][1], but some people were asking about how to do so.
So I made a video!

Some small errata: drbrain has informed me that he should edit the Changelog,
not me. So don't do that. :)

<iframe src="http://player.vimeo.com/video/23522731?title=0&amp;byline=0&amp;portrait=0" width="400" height="300" frameborder="0"></iframe><p><a href="http://vimeo.com/23522731">How to contribute to Ruby's documentation.</a> from <a href="http://vimeo.com/steveklabnik">Steve Klabnik</a> on <a href="http://vimeo.com">Vimeo</a>.</p>

If you don't want to watch me talk about it, here's the same info, in text:

Getting the Ruby source is pretty easy. You can find it on GitHub, here:
[http://github.com/ruby/ruby][2] . Click the "fork" button and clone down your
own fork:

    $ git clone git@github.com:YOURUSERNAME/ruby.git

After that's done, type `cd ruby/` and add the main project as an upstream. This will
let you keep up-to-date with the latest changes:

    $ git remote add upstream https://github.com/ruby/ruby.git

    $ git fetch upstream

Okay! Now that you're all set up, poke around and find something that needs
documented. I like to just look through the source, but you can also look
[here][5] for a list of things that have no docs. Documentation is written in
rdoc, and I'd check the recent commits that drbrain has been making to guide
you in style. [This commit][6], for example, is a pretty good template. You
can also check out the formatting guides [here][7]. There's also [this][8]
which explains some directives for .rb files and [this][9] which handles
directives for .c files.

Now that you've made a change to the documentation, you can regenerate the
docs by using rdoc. First, grab the latest version from rubygems:

   $ gem install rdoc

Always best to have the latest tools. Now do this to generate the docs:

    $ rdoc --o tmpdoc lib/rss*

I'm passing it in an output directory with op, since the doc directory is not
an rdoc directory. rdoc will complain and refuse to overwrite those files,
which is a good thing. I'm also passing in a pattern of what to compile
documentation for, compiling all of it takes a few minutes! In this case, I
chose to document the rss library.

Now you have a website in rdocout. Open up its index.html, and poke around for
what you've changed. If it all looks good, you're ready to make a patch!

    $ rm -r rdocout

    $ git add .

    $ git commit -m "adding documentation for $SOMETHING"

Now, you have two options here. One is to simply push the change up to GitHub,
and make a pull request.

    $ git push origin

... aaand pull request. The core Ruby development doesn't really happen on
GitHub though, and so your patch may take a while to get included. If you
really want to do it right, submit a patch to RedMine. We'll use git to make
this patch:

    $ git format-patch HEAD~1

This says "make a patch out of the last commit." It'll tell you a file name,
it should start with 000.

Now, sign up for the Ruby RedMine [here][10]. Once you've clicked the
confirmation email, [open a new ticket][11], and assign it to Eric Hodel,
category DOC, and give it your Ruby version, even though it's not a big deal
here. Click 'choose file' and pick your patch, then 'create and continue' and
BAM! You're done!

Let's all pitch in and make this the best documented Ruby release ever! In
writing documentation, you might even find some things that you'd like to help
improve. ;)

   [1]: http://blog.segment7.net/2011/05/09/ruby-1-9-3-documentation-challenge
   [2]: http://github.com/ruby/ruby
   [3]: mailto:git@github.com
   [4]: https://github.com/ruby/ruby.git
   [5]: http://segment7.net/projects/ruby/documentation_coverage.txt
   [6]: https://github.com/ruby/ruby/commit/071a678a156dde974d8e470b659c89cb02b07b3b
   [7]: http://rdoc.rubyforge.org/RDoc/Markup.html
   [8]: http://rdoc.rubyforge.org/RDoc/Parser/Ruby.html
   [9]: http://rdoc.rubyforge.org/RDoc/Parser/C.html
   [10]: http://redmine.ruby-lang.org/account/register
   [11]: http://redmine.ruby-lang.org/projects/ruby-19/issues/new
