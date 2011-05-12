---
published: true
title: Trouble with Diaspora
layout: post
---

So, Wednesday, Diaspora was released.

If you're not familiar, a few months ago everyone was up in arms about the
latest Facebook privacy change. So four college kids started [a Kickstarter
project][1] with a dream: let's make a distributed, private Facebook. They
asked for $10,000. They got about $200,000.

They worked on the code all summer, in secret. Wednesday, a 'developer
preview' came out. They'd promised something by the end of the summer, and the
15th of September is the last day. So [they put it up on GitHub][2].

Oh boy.

Basically, the code is really, really bad. I don't mean to rain on anyone's
parade, but [there are really, really bad security holes][3]. And they're
there due to things that any professional programmer would never dream of
leaving out of their code. I don't want to disclose too many details, but you
can see the code yourself on GitHub.

At first, I found one. So I tried to patch it. And I did, and it got accepted
into master. Awesome. But then, the more I read, the more bad things I found.
They're going to need a complete overhaul to fix this. Go over every last
piece of code. And don't even get me started on their encryption code.

But basically, please heed their own warning from [the announcement][4]:

> Feel free to try to get it running on your machines and use it, but we give
no guarantees. We know there are security holes and bugs, and your data is not
yet fully exportable. If you do find something, be sure to log it in our
bugtracker, and we would love screenshots and browser info.

If you find one of the many, many nodes that people are publicly posting,
please don't use your real passwords, or information.

And if you're a developer, consider helping out. It's going to be rough going:
the mailing list and issue trackers are full of people that have no idea what
they're doing. Be prepared to wade through tons of crap. But they could
really, really use the help. I'll be submitting another patch or two, but it
needs much, much more than I can give.

EDIT: Please check out [my follow up post][5], where I talk about being
misquoted regarding this post.

EDIT 2: Patrick has a post up describing the exploits, now that there have
been some patches applied. If you're a technically inclined individual, you
might be interested. You can find it on [his blog][6].

   [1]: http://www.kickstarter.com/projects/196017994/diaspora-the-personally-controlled-do-it-all-distr
   [2]: http://github.com/diaspora/diaspora
   [3]: http://www.theregister.co.uk/2010/09/16/diaspora_pre_alpha_landmines/
   [4]: http://www.joindiaspora.com/2010/09/15/developer-release.html
   [5]: http://blog.steveklabnik.com/this-is-why-new-media-hates-old-media
   [6]: http://www.kalzumeus.com/2010/09/22/security-lessons-learned-from-the-diaspora-launch/

