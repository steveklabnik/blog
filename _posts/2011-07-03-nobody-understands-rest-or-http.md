---
published: true
title: Nobody Understands REST or HTTP
layout: post
---

The more that I've learned about web development, the more that I've
come to appreciate the thoroughness and thoughtfulness of the authors of
the HTTP RFC and Roy Fielding's dissertation. It seems like the answers
to most problems come down to "There's a section of the spec for that."
Now, obviously, they're not infallible, and I'm not saying that there's
zero room for improvement. But it really disappoints me when people
don't understand the way that a given issue is supposed to be solved,
and so they make up a partial solution that solves their given case but
doesn't jive well with the way that everything else works. There are
valid criticisms of the specs, but they have to come from an informed
place about what the spec says in the first place.

Let's talk about a few cases where either REST or HTTP (which is clearly
RESTful in its design) solves a common web development problem.

### I need to design my API

This one is a bit more general, but the others build off of it, so bear
with me.

The core idea of REST is right there in the name: "Representational
State Transfer" It's about transferring representations of the state...
of resources. Okay, so one part isn't in the name. But still, let's
break this down.

#### Resources

From [Fielding's dissertation](http://www.ics.uci.edu/~fielding/pubs/dissertation/rest_arch_style.htm#sec_5_2_1_1):

> The key abstraction of information in REST is a resource. Any information
that can be named can be a resource: a document or image, a temporal service
(e.g. "today's weather in Los Angeles"), a collection of other resources, a
non-virtual object (e.g. a person), and so on. In other words, any concept that
might be the target of an author's hypertext reference must fit within the
definition of a resource. A resource is a conceptual mapping to a set of
entities, not the entity that corresponds to the mapping at any particular
point in time.

When we interact with a RESTful system, we're interacting with a set of
resources. Clients request resources from the server in a variety of
ways. But the key thing here is that resources are _nouns_. So a RESTful
API consists of a set of URIs that map entities in your system to
endpoints, and then you use HTTP itself for the verbs. If your URLs have
action words in them, you're doing it wrong. Let's look at an example of
this, from the early days of Rails. When Rails first started messing
around with REST, the URLs looked like this:

    /posts/show/1

If you you use Rails today, you'll note that the corresponding URL is
this:

    /posts/1

Why? Well, it's because the 'show' is unnecessary; you're performing a
GET request, and that demonstrates that you want to show that resource.
It doesn't need to be in the URL.

#### A digression about actions

Sometimes, you need to perform some sort of action, though. Verbs are
useful. So how's this fit in? Let's consider the example of transferring
money from one Account to another. You might decided to build a URI like
this:

    POST /accounts/1/transfer/500.00/to/2

to transfer $500 from Account 1 to Account 2. But this is wrong! What
you really need to do is consider the nouns. You're not transferring
money, you're creating a Transaction resource:

    POST /transactions HTTP/1.1
    Host: <snip, and all other headers>

    from=1&to=2&amount=500.00

Got it? So then, it returns the URI for your new Transaction:

    HTTP/1.1 201 OK
    Date: Sun, 3 Jul 2011 23:59:59 GMT
    Content-Type: application/json
    Content-Length: 12345
    Location: http://foo.com/transactions/1

    {"transaction":{"id":1,"uri":"/transactions/1","type":"transfer"}}

Whoah, [HATEOS](http://timelessrepo.com/haters-gonna-hateoas)! Also, it
may or may not be a good idea to return this JSON as the body; the
important thing is that we have the Location header which tells us where
our new resource is. If we give a client the ID, they might try to
construct their own URL, and the URI is a little redundant, since we
have one in the Location. Regardless, I'm leaving that JSON there,
because that's the way I typed it first. I'd love to [hear your thoughts
on this](mailto:steve@steveklabnik.com) if you feel strongly one way or
the other.

Anyway, so now we can GET our Transaction:

    GET /transactions/1 HTTP/1.1
    Accept: application/json

and the response:

    HTTP/1.1 blah blah blah

    {"id":1,"type":"transfer","status":"in-progress"}

So we know it's working. We can continue to poll the URI and see when
our transaction is finished, or if it failed, or whatever. Easy! But
it's about manipulating those nouns.

#### Representations

You'll notice a pair of headers in the above HTTP requests and
responses: Accept and Content-Type. These describe the different
'representation' of any given resource. From [Fielding](http://www.ics.uci.edu/~fielding/pubs/dissertation/rest_arch_style.htm#sec_5_2_1_2):

> REST components perform actions on a resource by using a representation to
capture the current or intended state of that resource and transferring that
representation between components. A representation is a sequence of bytes,
plus representation metadata to describe those bytes. Other commonly used but
less precise names for a representation include: document, file, and HTTP
message entity, instance, or variant.
>
> A representation consists of data, metadata describing the data, and, on
occasion, metadata to describe the metadata (usually for the purpose of
verifying message integrity).

So `/accounts/1` represents a resource. But it doesn't include the form
that the resource takes. That's what these two headers are for.

This is also why adding `.html` to the end of your URLs is kinda silly.
If I request `/accounts/1.html` with an `Accept` header of
`application/json`, then I'll get JSON. The `Content-Type` header is the
server telling us what kind of representation it's sending back as well.
The important thing, though, is that a given resource can have many
different representations. Ideally, there should be one unambiguous
source of information in a system, and you can get different
representations using `Accept`.

#### State and Transfer

This is more about the way HTTP is designed, so I'll just keep this
short: Requests are designed to be stateless, and the server holds all
of the state for its resources. This is important for caching and a few
other things, but it's sort of out of the scope of this post.

Okay. With all of that out of the way, let's talk about some more
specific problems that REST/HTTP solve.

### I want my API to be versioned

The first thing that people do when they want a versioned API is to
shove a /v1/ in the URL. _*THIS IS BAD!!!!!1*_. `Accept` solves this
problem. What you're really asking for is "I'd like the version two
representation of this resource." So use accept!

Here's an example:

    GET /accounts/1 HTTP/1.1
    Accept: application/vnd.steveklabnik-v2+json

You'll notice a few things: we have a + in our MIME type, and before it
is a bunch of junk that wasn't there before. It breaks down into three
things: `vnd`, my name, and `v2`. You can guess what v2 means, but what
about `vnd`. It's a [Vendor MIME Type](http://tools.ietf.org/html/rfc4288#section-3.2).
After all, we don't really want just any old JSON, we want my specific
form of JSON. This lets us still have our one URL to represent our
resource, yet version everything appropriately.

I got a comment from [Avdi Grimm](http://avdi.org/) about this, too:

> Here's an article you might find interesting: [http://www.informit.com/articles/article.aspx?p=1566460](http://www.informit.com/articles/article.aspx?p=1566460)
>
> The author points out that MIMETypes can have parameters, which means you can actually have a mimetype that looks like this:
>
>     vnd.example-com.foo+json; version=1.0
>
> Sadly, Rails does not (yet) understand this format.

### I'd like my content to be displayed in multiple languages

This is related, but a little different. What about pages in different
languages? Again, we have a question of representation, not one of
content. /en/whatever is not appropriate here. Turns out, [there's a
header for that: Accept-Language](http://tools.ietf.org/html/rfc2616#section-14.4).
Respect the headers, and everything works out.

Oh, and I should say this, too: this doesn't solve the problem of "I'd
like to read this article in Spanish, even though I usually browse in
English." Giving your users the option to view your content in different
ways is a good thing. Personally, I'd consider this to fall out in two
ways:

* It's temporary. Stick this option in the session, and if they have the
  option set, it trumps the header. You're still respecting their usual
  preferences, but allowing them to override it.
* It's more permanent. Make it some aspect of their account, and it
  trumps a specific header. Same deal.

### I'd like my content to have a mobile view

Sounds like I'm beating a dead horse, but again: it's a representation
question. In this case, you'd like to vary the response by the
User-Agent: give one that's mobile-friendly. There's a whole list of
[mobile best practices](http://www.w3.org/TR/mobile-bp/) that the w3c
recommends, but the short of it is this: the User-Agent should let you
know that you're dealing with a mobile device. For example, here's the
first iPhone UA:

    Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A543a Safari/419.3

Then, once detecting you have a mobile User-Agent, you'd give back a
mobile version of the site. Hosting it on a subdomain is a minor sin,
but really, like I said above, this is really a question of
representation, and so having two URLs that point to the same resource
is kinda awkward.

Whatever you do, for the love of users, please don't detect these
headers, then redirect your users to m.whatever.com, at the root. One of my
local news websites does this, and it means that every time I try to follow a
link from Twitter in my mobile browser, I don't see their article, I see
their homepage. It's infuriating.

### I'd like to hide some of my content

Every once in a while, you see a story like this: [Local paper boasts
ultimate passive-agressive paywall policy](http://www.boingboing.net/2010/10/25/local-newspaper-boas.html).
Now, I find paywalls distasteful, but this is not the way to do it.
There are technological means to limit content on the web: making users
be logged-in to read things, for example.

When this was discussed on Hacker News, [here's](http://news.ycombinator.com/item?id=1834075)
what I had to say:

nkurz:

> I presume if I had an unattended roadside vegetable stand with a cash-box, that I'd be able to prosecute someone who took vegetables without paying, certainly if they also made off with the cash-box. Why is this different on the web? And if a written prohibition has no legal standing, why do so many companies pay lawyers to write click-through "terms of service" agreements?

me:

> > Why is this different on the web?
> 
> Let's go through what happens when I visit a web site. I type a URL in my bar, and hit enter. My web browser makes a request via http to a server, and the server inspects the request, determines if I should see the content or not, and returns either a 200 if I am allowed, and a 403 if I'm not. So, by viewing their pages, I'm literally asking permission, and being allowed.
> 
> It sounds to me like a misconfiguration of their server; it's not doing what they want it to.

### I'd like to do some crazy ajax, yet have permalinks

This is an example of where the spec is obviously deficient, and so
something had to be done.

As the web grew, AJAXy 'web applications' started to become more and
more the norm. And so applications wanted to provide deep-linking
capabilities to users, but there's a problem: they couldn't manipulate
the URL with Javascript without causing a redirect. They _could_
manipulate the anchor, though. You know, that part after the #. So,
Google came up with a convention: [Ajax Fragments](http://code.google.com/web/ajaxcrawling/docs/getting-started.html).
This fixed the problem in the short term, but then the spec got fixed in
the long term: [pushState](http://dev.w3.org/html5/spec-author-view/history.html).
This lets you still provide a nice deep URL to your users, but not have
that awkward #!.

In this case, there was a legitimate technical issue with the spec, and
so it's valid to invent something. But then the standard improved, and
so people should stop using #! as HTML5 gains browser support.

### In conclusion

Seriously, most of the problems that you're solving are social, not
technical. The web is decades old at this point, most people have
considered these kinds of problems in the past. That doesn't mean that
they always have the right answer, but they usually do have an answer,
and it'd behoove you to know what it is before you invent something on
your own.
