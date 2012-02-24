---
published: true
title: Some People Understand REST and HTTP
layout: post
---

This is a follow-up post to my post [here][1]. You probably want to
read that first.

UPDATE: Please note that '[REST is over'](/posts/2012-02-23-rest-is-over).
'Hypermedia API' is the proper term now.

## A few words on standards versus pragmatism

When I wrote my first post on this topic, I tried to take a stance that
would be somewhat soft, yet forceful. Engineering is the art of making
the proper trade-offs, and there are times when following specifications
is simply not the correct decision. With that said, my motivation for
both of these posts is to eradicate some of the ignorance that some
developers have about certain areas of the HTTP spec and Fielding's REST
paper. If you understand the correct way, yet choose to do something
else for an informed reason, that's absolutely, 100% okay. There's no
use throwing out the baby with the bathwater. But ignorance is never a
good thing, and most developers are ignorant when it comes to the
details of REST.

Secondly, while I think that REST is the best way to develop APIs, there
are other valid architectural patterns, too. Yet calling non-REST APIs
'RESTful' continues to confuse developers as to what "RESTful" means.
I'm not sure what exactly we should call "RESTish" APIs (hey, there we
go, hmmm...) but I'm also not under the illusion that I personally will
be able to make a huge dent in this. Hopefully you, humble reader, will
remember this when dealing with APIs in the future, and I'll have made a
tiny dent, though.

## So who _does_ understand REST?

As it turns out, there are two companies that you've probably heard of
who have APIs that are much more RESTful than many others: [Twilio][2]
and [GitHub][3]. Let's take a look at GitHub first.

### GitHub: logically awesome

GitHub's developer resources are not only beautiful, but thorough. In
addition, they make use of lots more of REST.

#### The good

GitHub uses [custom MIME][4] types for all of their responses. They're
using the vendor extensions that I talked about in my post, too. For
example:

  application/vnd.github-issue.text+json

Super cool.

Their [authentication][5] works in three ways: HTTP Basic, OAuth via an
Authentication Header, or via a parameter. This allows for a maximum
amount of compatibility across user agents, and gives the user some
amount of choice.

Their [Pagination][6] uses a header I didn't discuss in part I: the Link
header. [Here](http://tools.ietf.org/html/rfc5988)'s a link to the
reference. Basically, Link headers enable HATEOAS for media types which
aren't hypertext. This is important, especially regarding JSON, since
JSON isn't hypermedia. More on this at the end of the post. Anyway, so
pagination on GitHub:

    $ curl -I "https://api.github.com/users/steveklabnik/gists"
    HTTP/1.1 200 OK
    Server: nginx/1.0.4
    Date: Sun, 07 Aug 2011 16:34:48 GMT
    Content-Type: application/json
    Connection: keep-alive
    Status: 200 OK
    X-RateLimit-Limit: 5000
    X-RateLimit-Remaining: 4994
    Link: <https://api.github.com/users/steveklabnik/gists?page=2>; rel="next", <https://api.github.com/users/steveklabnik/gists?page=33333>; rel="last"
    Content-Length: 29841

The Link header there shows you how to get to the next page of results.
You don't need to know how to construct the URL, you just have to parse
the header and follow it. This, for example, is a great way to connect a
resource that's not text-based, such as a PNG, to other resources.

#### The bad

There's really only one place that GitHub doesn't knock it out of the
park with their new API, and that's HATEOAS. GitHub's API isn't
discoverable, because there's no information at the root:

    $ curl -I https://api.github.com/
    HTTP/1.1 302 Found
    Server: nginx/1.0.4
    Date: Sun, 07 Aug 2011 16:44:02 GMT
    Content-Type: text/html;charset=utf-8
    Connection: keep-alive
    Status: 302 Found
    X-RateLimit-Limit: 5000
    Location: http://developer.github.com
    X-RateLimit-Remaining: 4993
    Content-Length: 0

Well, at least, this is how they present it. If you ask for JSON:

    $ curl -I https://api.github.com/ -H "Accept: application/json"
    HTTP/1.1 204 No Content
    Server: nginx/1.0.4
    Date: Sun, 07 Aug 2011 16:45:32 GMT
    Connection: keep-alive
    Status: 204 No Content
    X-RateLimit-Limit: 5000
    X-RateLimit-Remaining: 4991
    Link: <users/{user}>; rel="user", <repos/{user}/{repo}>; rel="repo", <gists>; rel="gists"

You do get Links, but you have to construct things yourself. As a user,
you get the same thing. It doesn't change the links to point to your
repos, it doesn't give you links to anything else that you can do with
the API.

Instead, the root should give you a link to the particular resources
that you can actually view. Maybe something like this:

    $ curl -I https://api.github.com/ -H "Accept: application/json" -u
"username:password"
    HTTP/1.1 204 No Content
    Server: nginx/1.0.4
    Date: Sun, 07 Aug 2011 16:45:32 GMT
    Connection: keep-alive
    Status: 204 No Content
    X-RateLimit-Limit: 5000
    X-RateLimit-Remaining: 4991
    Link: </gists/public>; rel="public_gists", </user/repos>; rel="repos", <gists>; rel="gists"

And a bunch more, for all of the other resources that are available.
This would make the API truly discoverable, and you wouldn't be forced
to read their gorgeous documentation. :)

### Twilio

I've always really enjoyed Twilio. Their API is incredibly simple to
use. I once hooked up a little "Text me when someone orders something
from my site" script, and it took me about fifteen minutes. Good stuff.

#### The good

Twilio has got the HATEOAS thing down. Check it out, their home page
says that the base URL is "https://api.twilio.com/2010-04-01". Without
looking at any of the rest of their docs, (I glanced at a page or two,
but I didn't really read them fully yet), I did this:

    $ curl https://api.twilio.com/2010-04-01
    <?xml version="1.0"?>
    <TwilioResponse>
      <Version>
        <Name>2010-04-01</Name>
        <Uri>/2010-04-01</Uri>
        <SubresourceUris>
          <Accounts>/2010-04-01/Accounts</Accounts>
        </SubresourceUris>
      </Version>
    </TwilioResponse>

I introduced some formatting. Hmm, okay, Accounts. Let's check this out:

    $ curl https://api.twilio.com/2010-04-01/Accounts<?xml version="1.0"?>
    <TwilioResponse><RestException><Status>401</Status><Message>Authenticate</Message><Code>20003</Code><MoreInfo>http://www.twilio.com/docs/errors/20003</MoreInfo></RestException></TwilioResponse>

Okay, so I have to be authenticated. If I was, I'd get something like
this:

    <TwilioResponse>
      <Account>
        <Sid>ACba8bc05eacf94afdae398e642c9cc32d</Sid>
        <FriendlyName>Do you like my friendly name?</FriendlyName>
        <Type>Full</Type>
        <Status>active</Status>
        <DateCreated>Wed, 04 Aug 2010 21:37:41 +0000</DateCreated>
        <DateUpdated>Fri, 06 Aug 2010 01:15:02 +0000</DateUpdated>
        <AuthToken>redacted</AuthToken>
        <Uri>/2010-04-01/Accounts/ACba8bc05eacf94afdae398e642c9cc32d</Uri>
        <SubresourceUris>
          <AvailablePhoneNumbers>/2010-04-01/Accounts/ACba8bc05eacf94afdae398e642c9cc32d/AvailablePhoneNumbers</AvailablePhoneNumbers>
          <Calls>/2010-04-01/Accounts/ACba8bc05eacf94afdae398e642c9cc32d/Calls</Calls>
          <Conferences>/2010-04-01/Accounts/ACba8bc05eacf94afdae398e642c9cc32d/Conferences</Conferences>
          <IncomingPhoneNumbers>/2010-04-01/Accounts/ACba8bc05eacf94afdae398e642c9cc32d/IncomingPhoneNumbers</IncomingPhoneNumbers>
          <Notifications>/2010-04-01/Accounts/ACba8bc05eacf94afdae398e642c9cc32d/Notifications</Notifications>
          <OutgoingCallerIds>/2010-04-01/Accounts/ACba8bc05eacf94afdae398e642c9cc32d/OutgoingCallerIds</OutgoingCallerIds>
          <Recordings>/2010-04-01/Accounts/ACba8bc05eacf94afdae398e642c9cc32d/Recordings</Recordings>
          <Sandbox>/2010-04-01/Accounts/ACba8bc05eacf94afdae398e642c9cc32d/Sandbox</Sandbox>
          <SMSMessages>/2010-04-01/Accounts/ACba8bc05eacf94afdae398e642c9cc32d/SMS/Messages</SMSMessages>
          <Transcriptions>/2010-04-01/Accounts/ACba8bc05eacf94afdae398e642c9cc32d/Transcriptions</Transcriptions>
        </SubresourceUris>
      </Account>
    </TwilioResponse>

Awesome. I can see my all of the other resources that I can interact
with. Other than knowing how to authenticate, I can follow the links
from the endpoint, and discover their entire API. Rock. This is the way
things are supposed to be.

#### The bad

This:

    $ curl https://api.twilio.com/2010-04-01/Accounts -H "Accept: application/json"
    <?xml version="1.0"?>
    <TwilioResponse><RestException><Status>401</Status><Message>Authenticate</Message><Code>20003</Code><MoreInfo>http://www.twilio.com/docs/errors/20003</MoreInfo></RestException></TwilioResponse>

Versus this:

    $ curl https://api.twilio.com/2010-04-01/Accounts.json
    {"status":401,"message":"Authenticate","code":20003,"more_info":"http:\/\/www.twilio.com\/docs\/errors\/20003"}

:/ Returning JSON when your resource ends with '.json' isn't bad, but
not respecting the Accept header, even when you return the right MIME
type, is just unfortunate.

## ... and a little Announcement

It seems that this is a topic that people are really interested in. Part
I of this article was pretty well-received, and I got lots of great
email and feedback from people. It was also made pretty clear by [a few](
http://twitter.com/#!/wayneeseguin/status/97733413611638784) people that
they want more content from me on this topic.

So I decided to write a book about it. You can check out the site for
"[Get Some REST][7]", and put in your email address. Then you'll get
updated when I start pre-release sales.

So what's in "Get Some REST"? It's going to be a full description of how
to build RESTful web applications, from the ground up. Designing your
resources, laying out an API, all the details. I'm going to try to keep
most of the content language-agnostic, but provide code samples in
Rails 3.1, as well.

I plan on writing a bunch of content, and then releasing the book at
half-price in beta. Early adopters will be able to get their two cents
in, and I'll cover things they still have questions on. It'll be
available under a liberal license, in PDF, ePub, all that good stuff.

I've also set up a Twitter account at [@getsomerestbook](http://twitter.com/#!/getsomerestbook). I'll be tweeting updates about the book, and also other good content
related to RESTful design. Oh, and if you're on
[rstat.us](http://rstat.us), I also have an account that'll syndicate
the same content at [@getsomerestbook](http://rstat.us/users/getsomerestbook) too.

   [1]: /2011/07/03/nobody-understands-rest-or-http.html
   [2]: http://www.twilio.com/docs/api/rest/
   [3]: http://developer.github.com/
   [4]: http://developer.github.com/v3/mimes/
   [5]: http://developer.github.com/v3/#authentication
   [6]: http://developer.github.com/v3/#pagination
   [7]: http://getsomere.st

