---
published: true
title: I'm Making It Dead Simple To Contribute To Ruby's Documentation
layout: post
---

Okay! So, if you'd read [my previous article on
this](/2011/05/10/contributing-to-ruby-s-documentation.html), you'd know how
easy it is to contribute to Ruby's Documentaiton.

> But Steve, I'm _still_ kinda scared.

Okay, so here we go: I'm making it even easier on you.

Send me what you want changed, and how, and I'll make a patch and submit
it on your behalf.

No, seriously, I will. I already did once. [This guy](http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-core/38873) posted something about how it was too hard, [so
I made a patch for him](http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-core/38875). And now Ruby is better because of it.

## Patches don't have to be patches

Seriously, I don't even mean diff outputs. I just got this email:

> I'm eager to contribute docs but I don't know where to start: I don't
> mean pulling down the repo and all that, I mean, I see this link
> here:http://segment7.net/projects/ruby/documentation\_coverage.txt but
> all I see is a ton of "# is documented" comments. Where does a
> relative n00b begin? Poking around in the source code is, well,
> intimidating. I'm completely new to this but I take direction well.
> Just point me in the right direction. Just give me something to
> document, please!

I sent this back:

> No code diving needed! That's part of it. Let's do this: Find the documentation for one of your favorite methods. Here, I'll pick one: http://ruby-doc.org/core/classes/Array.html#M000278 okay, that looks okay, but look at compact!:
> 
> > Removes nil elements from the array. Returns nil if no changes were made, otherwise returns </i>ary</i>.
> 
> Why's that </i> there? Total screw-up.  For example. So, send me this email:
> 
> "Hey Steve-
> 
> Check out the docs for Array#compact!, here: http://ruby-doc.org/core/classes/Array.html#M000279 . There's an extra </i> that's screwing things up.
> 
> -Jonathan"
> 
> Done! I'll go from there. How about this one: 
> 
> "Hey Steve-
> 
> I checked out the docs for Time._load, here: http://www.ruby-doc.org/core/classes/Time.html#M000394
> 
> These docs kind of suck. What if I don't know what Marshal is? There should at _least_ be a link to Marshall, here: http://ruby-doc.org/core/classes/Marshal.html And it should probably say something like "You can get a dumped Time object by using _dump: http://www.ruby-doc.org/core/classes/Time.html#M000393 
> 
> - Jonathan"
> 
> I'm sure you can find something that's formatted wrong, or worded incorrectly, or anything else.
> 
> -Steve

Now, the _closer_ it is to an actual patch, the faster I'll be able to
do it. A vague "this documentation is confusing, but I'm not sure why"
is helpful, but will take longer. I'd rather get that email than not. If
you're not sure, hit send.

## Just Do It

And so I'll do it again. Scared to deal with doc patches? I'll make them
up. I'm serious. I'll do it. Send them to me.

That's all.

Send me patches.
[steve@steveklabnik.com](mailto:steve@steveklabnik.com). Do it.
