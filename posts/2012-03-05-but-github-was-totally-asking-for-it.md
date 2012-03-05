---
title: "But GitHub was Totally Asking For It!"
date: 2012-03-05 10:35
---

TL;DR: Victim blaming is always bad, no matter what the situation. It's never
a victim's fault when bad things happen to them. It is always the aggressor's
fault. Stop blaming victims.

As some of you know, I've been spending a lot of time in various humanities
disciplines lately: reading lots of philosophy, being involved in various social
justice communities, picking up some anthropology books here and there. One of
the things that reading philosophy does for you is practicing reading people's
words and seeing their underlying arguments. Once you've figured out what
they're actually saying, you can see if the argument makes sense, contains any
fallacies, is coherent, etc.

## DRAMA DRAMA DRAMA: background

That's why I got kinda annoyed yesterday with this whole [zomg RAILS
VULNERABILITY FIASCO](https://github.com/blog/1068-public-key-security-vulnerability-and-mitigation).
For those of you who were [living under a rock yesterday](https://twitter.com/#!/merbist/status/176469092906176514),
which was probably a good idea, GitHub had an issue in their Rails application.
Rails has a feature called [mass assignment](http://railspikes.com/2008/9/22/is-your-rails-application-safe-from-mass-assignment)
(check the date of that blog post) which basically allows someone to send
arbitrary attributes through a web form, and they get saved in the database.
90% of the time, this is the behavior that you want: it's super convenient,
and most attributes do not need to be protected. Some, however, do. Imagine
that I change the `user_id` attribute to be your user instead of mine. Now I've
posted something as you. That kind of thing. `*_id` attributes are the most
common ones that need to be protected.

## Arguments I've heard before

Now, this is really a question of defaults: Rails gives you the ability to
protect yourself against this kind of thing, with `attr_accessible`, a
whitelist of attributes that are mass-assign-able. Rails defaults to not
setting this option on generated models. I happen to think that this default is
poor, but it was chosen for a few good reasons. I personally think that the
whole feature needs to be re-thought through to make it better, but that's not
the point of my post. 

### A disclaimer

Now, before I say anything more about this, I really, really want to clarify.
I **AM NOT** saying that what happened to GitHub is in **ANY WAY** comparable
to rape. To be extra, extra clear, I'm just going to state my thesis right
here: The arguments made about GitHub and what happened to them resemble in
structure the same victim blaming arguments that many make against those who
have been raped. Rape is a terrible tragedy that is in no way comparable to
making a joke commit to Rails master.

### The internet's reaction

Anyway, with that **HUGE DISCLAIMER** out of the way, here's some things that
I've heard out of people's mouths in the last day or so:

> The vulnerability can be protected by using feature that Rails team provided.
> Github team choosing not to use it is not Rails team's fault.

&nbsp;

> Not saying that I like the default setting being open, but it really is up to
> developers to secure their apps.

&nbsp;

> it boggles my mind the apologists coming into this thread about this. 

&nbsp;

> Seems a bit ungrateful, this is obviously a severe security risk, that he
> exposed, which he tried to inform relevant people about but ultimately was
> ignored. He wouldn't have been so blunt about it if he didn't care for the
> betterment of the service, or rails for that matter.

&nbsp;

> I think he probably did the Rails community at large a huge favor here. Had
> this just been fixed quietly on GitHub, that would certainly be better for
> GitHub's PR but the wider community might never have realized the lurking
> horror that the Rails team appears to have been unlikely to do anything
> about other than point people to the existing docs.

&nbsp;

> More "an innocent kid was the only one not afraid to say that emperor is
> actually naked."

&nbsp;

> They should have burned the midnight oil and made sure the same problem
> wasn't prevalent in other parts of the code.

&nbsp;

> Instead, the reward you landed to @homakov is a suspension. Homakov found a
> vulnerability in a project used by hundreds of thousands of applications, and
> his issue is ignored. The liklihood of this vulnerability reaching the ears
> of developers everywhere is extremely low and Rails clearly weren't taking it
> seriously. So instead he demonstrates the vulnerabilty in an attack which is
> clearly the "whitest" of white, and gets a suspension. 

## Where have I heard this before?

<blockquote class="twitter-tweet"><p>"Dude, look at that Rails app. She was _totally_ asking for it! Did you see her, not even covering her attributes!"</p>&mdash; Steve Klabnik (@steveklabnik) <a href="https://twitter.com/steveklabnik/status/176409293208301569" data-datetime="2012-03-04T20:50:27+00:00">March 4, 2012</a></blockquote>
<script src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

I originally wrote a whole thing here, but in the interest of being direct, I
just deleted it. Here's the deal:

Reading all of the backlash against GitHub on this one makes me really mad.
It's never the victim's fault when bad things happen to them, it's the
aggressor's fault. Expecting a victim to be nice to the person that damaged
them is insane, shows an incredible lack of empathy, and downplays the damage
done to them. Yes, he didn't cause any direct damage, but the indirect damage
through both this fallout as well as causing GitHub to spend a Sunday morning
auditing _everything_ under pressure is still a _lot_ of damage.

While it's not Rails' fault that this happened either, I do feel that Egor did
have a good point about the default situation: the feature is kind of poor. I
don't think that putting `attr_accessible nil` is the right thing to do, though,
the feature needs to be re-thought a bit. But that's something else unrelated.

Seriously. It's never a victim's fault.
