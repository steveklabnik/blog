---
title: "Transmuting Philosophy into Machinery"
date: 2012-03-06 13:28
---

I'm so very close to releasing the beta of [Get Some REST](http://getsomere.st). 
However, I'm about to get on a plane to Poland, and that's a bad time to launch
things. ;) [wroc\_love.rb](http://wrocloverb.com/), here I come!

Anyway, I figured I'd give you a preview of some of the content that I've been
working on. This particular article is short, but it's also a public response
to something, and so, to whet your appetite, I figured I'd give you a little
taste of what's to come. It's out of context, so I'm a little light on
explaining why you'd do each step of the process; there is much more on that
elsewhere in the book! Rather than explaing all the _why_, I just actually do
it. This is one of the last articles, and it's a fairly simple example once
you've grokked all the fundamentals, so it's a bit small, lengthwise.

If all goes well, I'll be releasing at wroc\_love.rb. So keep your eyes peeled.

Without further ado, the article.

<hr/> 

> Kessler's idea was, that besiddes _the law of mutual struggle_ there is in
> nature _the law of mutual aid_, which, for the success of the struggle for
> life, and especially for the progressive evolution of the species, is far
> more important than the law of mutual contest. This suggestion - which was,
> in reality, nothing but a further development of the ideas expressed by
> Darwin himself in _The Descent of Man_, seemed to me so correct and of so
> great an importance, that since I became aquanted with it I began to cllect
> materials for further developing the idea, which Kessler had only cursorily
> sketched in his lecture, but had not lived to develop. He died in 1881.
> 
> - Peter Kropotkin, "Mutual Aid: A Factor of Evolution", p21


Rob Conery is a pretty cool guy. While I always enjoy reading his blog, he's
been at battle with the Hypermedia crowd recently. It's always good natured,
though, and he means well.

He recently posed an interesting question to his blog:

> I would like to invite the good people who have engaged with me over the last
> few days to jump in and write me up an API – and by way of explanation – show
> how their ideas can be translated into reality.

Great! After all, social exchange is one of the building blocks of society:

> In so far as the process of exchange transfers commodities from hands in
> which they are non-use-values to hands in which they are use-values, it is a
> process of social metabolism.
> 
> Karl Marx, "Capital, Volume 1", p198

Let's apply what we've learned about the basics of designing
hypermedia APIs. Here's his requirements:

## Use Cases

This is step one: simple authentication and then consumption of basic data. The client will be HTML, JS, and Mobile.

### Logging In

Customer comes to the app and logs in with email and password. A token is returned by the server upon successful authentication and a message is also received (like “thanks for logging in”).

### Productions

Joe User is logged in and wants to see what he can watch. He chooses to browse all productions and can see on the app which ones he is aloud to watch and which ones he isn’t. He then chooses to narrow his selection by category: Microsoft, Ruby, Javascript, Mobile. Once a production is selected, a list of Episodes is displayed with summary information. Joe wants to view Episode 2 of Real World ASP.NET MVC3 – so he selects it. The video starts.

### Episodes.

Kelly User watches our stuff on her way to work every day, and when she gets on the train will check and see if we’ve pushed any new episodes recently. A list of 5 episodes comes up – she chooses one, and watches it on her commute.


## The design process

### Step 1: Evaluate Process

Fortunately, this has been done for us, in the Use Cases above. Sweet!

### Step 2: Create state machine

Taking all of this into account, I drew out this state machine:

![tekpub state machine](/images/tekpub_state_machine.png)

Basically, you start at a root. Two options: see the newest list of
productions, or see them all. You can filter all of them by a category.
Eventually, you end up picking one. This workflow should be enough to support
all of our use cases.

### Step 3: Evaluate Media Type

Okay, so, he mentions this in use cases:

> The client will be HTML, JS, and Mobile.

I'm not 100% sure what he means here: I think it's that we'll be building a
site on this API (html), it'll have heavy JS usage (js), and probably a mobile
version or possibly a native client (mobile).

Given this information, I'm going to choose JSON as a base format. Besides,
our developers tend to like it. ;)

After that choice is made, we also need these things:

- Filtering things means a templated query of some kind, so we'll need some
  kind of templating syntax.
- We need lists of things as well as singular things. I like to simply this by
  representing singular things as a list of one item. So, lists and individual
  items.
- We also have a few attributes we need to infer from these loose requirements.
  No biggie. :)

### Step 4: Create Media Types

Based on this, I've made up [the application/vnd.tekpub.productions+json media type](/tekpub-productions.html). Key features, based on our evaluation:

- Each transition in our state machine has a relation attribute
- Each transition that needs to be parameterized has some sort of template
  syntax
- Each attribute that we need someone to know about has a definition
- Everything is always a list. It may contain just one item. Our client's
  interface can detect this special case and display something different if it
  wants.

### Step 5: Implementation!

That's for Rob! ahaha!

However, you might want a sample implementation. I'm willing to make one if
there's confusion about it, but I figured I'd put the article out and see if
that's interesting to people before I went through the effort.

## What about auth?

Oh, I didn't handle the auth case. That's because auth happens at the HTTP
level, not at the application level. HTTP BASIC + SSL or Digest should be just
fine.

## But, but, but... I didn't get any verbs! Or URLS!

I know. Fielding:

> A REST API should spend almost all of its descriptive effort in defining the
> media type(s) used for representing resources and driving application state,
> or in defining extended relation names and/or hypertext-enabled mark-up for
> existing standard media types. Any effort spent describing what methods to
> use on what URIs of interest should be entirely defined within the scope of
> the processing rules for a media type (and, in most cases, already defined by
> existing media types). [Failure here implies that out-of-band information is
> driving interaction instead of hypertext.]

As well as

> A REST API must not define fixed resource names or hierarchies (an obvious
> coupling of client and server). Servers must have the freedom to control
> their own namespace. Instead, allow servers to instruct clients on how to
> construct appropriate URIs, such as is done in HTML forms and URI templates,
> by defining those instructions within media types and link relations.
> [Failure here implies that clients are assuming a resource structure due to
> out-of band information, such as a domain-specific standard, which is the
> data-oriented equivalent to RPC's functional coupling].

And 

> A REST API should be entered with no prior knowledge beyond the initial URI
> (bookmark) and set of standardized media types that are appropriate for the
> intended audience (i.e., expected to be understood by any client that might
> use the API). From that point on, all application state transitions must be
> driven by client selection of server-provided choices that are present in the
> received representations or implied by the user’s manipulation of those
> representations. The transitions may be determined (or limited by) the
> client’s knowledge of media types and resource communication mechanisms, both
> of which may be improved on-the-fly (e.g., code-on-demand). [Failure here
> implies that out-of-band information is driving interaction instead of
> hypertext.]

Soooooooooo yeah.

## Further Exploration

### Sources Cited

* ["Mutual Aid: A Factor of Evolution", Kropotkin](http://www.amazon.com/Mutual-Aid-Evolution-Peter-Kropotkin/dp/0875580246)
* ["Capital, Volume I", Karl Marx](http://www.amazon.com/Capital-Critique-Political-Economy-Classics/dp/0140445684/ref=sr_1_1?s=books&ie=UTF8&qid=1331214700&sr=1-1)
* ["Someone save us from REST"](http://wekeroad.com/2012/02/28/someone-save-us-from-rest/)
* ["Moving the Philosophy into Machinery"](http://wekeroad.com/2012/03/03/moving-the-philosophy-into-machinery/)
* ["REST APIs Must be Hypertext Driven"](http://roy.gbiv.com/untangled/2008/rest-apis-must-be-hypertext-driven)
* [The Design Process: An Overview](/nodes/the-design-process-an-overview)

### Next Articles

For more on why media types are awesome, check [Programming the Media Type](#).

### Terms Used

None really at the moment! This article stands alone.

