---
layout: post
title: "Devise: ActionController::RoutingError (No Route Matches [GET] /users/sign_out)"
date: 2011-12-11 15:38
comments: true
categories:
---

Just a quick note about Devise, and its RESTful implications. I ran across this
error today, and thought I'd share.

I was trying to log out, so I hit the normal route for such things with my browser. Here's the error:

```
Devise: ActionController::RoutingError (No Route Matches [GET] /users/sign_out)
```

Uhhhhh what? I run rake routes...

```
$ rake routes | grep destroy_user
    destroy_user_session DELETE /users/sign_out(.:format)      {:action=>"destroy", :controller=>"devise/sessions"}
```

So, wtf? Well, there is that pesky `DELETE`... Googling for this error led me to
[this commit](https://github.com/plataformatec/devise/commit/f3385e96abf50e80d2ae282e1fb9bdad87a83d3c).
Looks like they changed some behavior, you can't just go to that page anymore
and log out. Bummer. But why?

## HTTP verbs: transfer semantics, not state

As I've been doing my research for [my book on REST](http://getsomere.st/), I've
been doing a lot of reading about HTTP. And I kept coming across these kinds of
curious comments in the spec. For example:

{% blockquote HTTP sec 9.6: PUT http://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html#sec9.6 %}
HTTP/1.1 does not define how a PUT method affects the state of an origin server.
{% endblockquote %}

Uhhh... what? Don't we all know that PUT means that we should be updating a
resource? And that we have to send the whole representation?

When trying to get to the bottom of this, I came across this:
 comment from Fielding:

{% blockquote Roy Fielding http://www.imc.org/atom-protocol/mail-archive/msg05425.html Re: Meaning of PUT, with (gasp) evidence %}
FWIW, PUT does not mean store.  I must have repeated that a million
times in webdav and related lists.  HTTP defines the intended
semantics of the communication -- the expectations of each party.
The protocol does not define how either side fulfills those expectations,
and it makes damn sure it doesn't prevent a server from having
absolute authority over its own resources.  Also, resources are
known to change over time, so if a server accepts an invalid Atom
entry via PUT one second and then immediately thereafter decides
to change it to a valid entry for later GETs, life is grand.
{% endblockquote %}

Soooooooo wtf?

Let's take a look again at what `PUT` does:

{% blockquote %}
The PUT method requests that the enclosed entity be stored under the supplied Request-URI. If the Request-URI refers to an already existing resource, the enclosed entity SHOULD be considered as a modified version of the one residing on the origin server. If the Request-URI does not point to an existing resource, and that URI is capable of being defined as a new resource by the requesting user agent, the origin server can create the resource with that URI.
{% endblockquote %}

It says "store," Roy says "I don't mean store." Uhhhh...

Here's my 'translated for the laymen' version of that quote:

{% blockquote %}
PUT means 'I'd like to later GET something at this URI.' If something is already
there, update it. If there isn't anything there, then create it.
{% endblockquote %}

That's it. It's talking about the semantics of what goes on: create or update.
It doesn't actually say anything about how this is implemented. But if you PUT
something to a URI, a GET needs to 200 afterwards. So what's the difference between PUT and POST?

{% blockquote HTTP sec 9.5: POST http://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html#sec9.5 %}
The POST method is used to request that the origin server accept the entity
enclosed in the request as a new subordinate of the resource identified by the
Request-URI in the Request-Line.

The actual function performed by the POST method is determined by the server and
is usually dependent on the Request-URI. The posted entity is subordinate to
that URI in the same way that a file is subordinate to a directory containing
it, a news article is subordinate to a newsgroup to which it is posted, or a
record is subordinate to a database.

The action performed by the POST method might not result in a resource that can
be identified by a URI.
{% endblockquote %}

Again, it's really vague about what it _does_. With POST, it basically says "You
have no idea what a POST does." What you _do_ know is the semantics of the
action, POST 'requests a new subordinate, but it might not create something.'

The _main_ difference is actually mentioned here:


{% blockquote HTTP sec 9.1.2: Idempotent Methods http://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html#sec9.1.2 %}
Methods can also have the property of "idempotence" in that (aside from error or
expiration issues) the side-effects of N > 0 identical requests is the same as
for a single request. The methods GET, HEAD, PUT and DELETE share this property.
{% endblockquote %}

Semantics again. PUT is _idempotent_, and POST is not. They could both be used
for creation, they could both be used for updating. With POST, you don't need a
URI, and PUT specifies a specfic one. That's it. Nowhere in those two sentences
states 'store in the database,' nowhere does it says 'full representation,'
nowhere does it say 'POST is create and PUT is update.' However you fulfill
these semantics are up to you, but the semantics are what's important.

## So wtf does this have to do with Devise?

The issue is that Devise's old semantics were wrong. A GET to `/users/sign_out` shouldn't modify state:

{% blockquote HTTP sec 9.1.1: Safe Methods http://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html#sec9.1.1 %}
In particular, the convention has been established that the GET and HEAD methods
SHOULD NOT have the significance of taking an action other than retrieval. These
methods ought to be considered "safe".
{% endblockquote %}

When Devise used GETs to log you out, that was a violation of the semantics of
GET. Here's the interesting part, though: Since POST is a super generic 'unsafe
action' method, you could also use POST to represent a logging out. POST also
has unsafe, non-idempotent semantics. DELETE specifically says delete, and POST
says 'any action,' and 'delete' is a subset of 'any action.' So DELETE is
_better_, but POST is not _wrong_, categorically.

## Fixing the 'bug'

So how do we take care of this? Personally, I did the pragmatic thing. In
`/config/initializers/devise.rb`

```
config.sign_out_via = :delete
config.sign_out_via = :get if Rails.env.test?
```

Now, during normal operations, we have our usual DELETE semantics, but in our
test environment, we can just hit it with GET. This way we don't have to hit a page, use Javascript to make a link with DELETE, and hit the page. This keeps my test times down, means I can run my tests with rack-test and not Selenium, and still gives me a high level of confidence that my tests work properly, even though it's technically not the exact same thing as production.

## In conclusion

The HTTP spec defines _semantics_ but not implementation details. Semantics
should be obeyed. But in testing, obeying them 100% may not be worth it.
