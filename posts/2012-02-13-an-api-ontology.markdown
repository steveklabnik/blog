---
layout: post
title: "An API Ontology"
date: 2011-02-12 15:00
---

As I've done research on APIs for [Get Some REST](http://getsomere.st), I've
become increasingly interested in different styles of API. I currently see most
real-world deployed APIs fit into a few different categories. All have their
pros and cons, and it's important to see how they relate to one other.

You may find this amusing if you've [read some of the
literature](http://www.ics.uci.edu/~fielding/pubs/dissertation/net_arch_styles.htm)
on the topic, but I've created this list in a top-down way: APIs as black
boxes, rather than coming up with different aspects of an API and categorizing
them based on that. I also decided to look at actually deployed APIs, rather
than theoretical software architectures.

If you have an API that doesn't fit into one of these categories, I'd love to
hear about it. I'd also like to further expand these descriptions, if you have
suggestions in that regard, please drop me a line, too.

## HTTP GET/POST

### Synopsis:

Provide simple data through a simple GET/POST request.

### Examples:

* [http://placekitten.com/](http://placekitten.com/)
* [http://code.google.com/apis/maps/documentation/staticmaps/](http://code.google.com/apis/maps/documentation/staticmaps/)
* [http://loripsum.net/api](http://loripsum.net/api)

### Description:

Simple data is made available via an HTTP GET or POST request. The vast majority of
these services seem to return images, but data is possible as well.

These API are technically a sub-type of \*-RPC, but I feel that their lack of business
process makes them feel different. It's basically just one specific remote procedure,
available over HTTP.

## \*-RPC
### Synopsis:

Remote procedure call; call a function over the web.

### Examples:

* [http://codex.wordpress.org/XML-RPC_Support](http://codex.wordpress.org/XML-RPC_Support)
* [http://www.flickr.com/services/api/request.rest.html](http://www.flickr.com/services/api/request.rest.html)
* [http://services.sunlightlabs.com/docs/Sunlight_Congress_API/](http://services.sunlightlabs.com/docs/Sunlight_Congress_API/)

### Description:

Similiar to how structured programming is built around functions, so is RPC.
Rather than call functions from your own programs, RPC is a way to call
functions over the Internet.

All calls are made through some sort of API endpoint, and usually sent
over HTTP POST.

Major flavors include XML-RPC and JSON-RPC, depending on what format data is
returned in.

Note that while Flickr's API says REST, it is very clearly RPC. Yay terminology!

## SOAP
### Synopsis:

Serialize and send objects over the wire.

### Examples:

* [http://www.flickr.com/services/api/request.soap.html](http://www.flickr.com/services/api/request.soap.html)
* [https://cms.paypal.com/us/cgi-bin/?cmd=_render-content&content_ID=developer/e_howto_api_soap_PayPalSOAPAPIArchitecture](https://cms.paypal.com/us/cgi-bin/?cmd=_render-content&content_ID=developer/e_howto_api_soap_PayPalSOAPAPIArchitecture)
* [http://www.salesforce.com/us/developer/docs/api/Content/sforce_api_quickstart_intro.htm](http://www.salesforce.com/us/developer/docs/api/Content/sforce_api_quickstart_intro.htm)

### Description:

SOAP stands for "Simple Object Access Protocol," and that describes it pretty
well. The idea behind these APIs is to somehow serialize your objects and then
send them over the wire to someone else.

This is usually accomplished by downloading a WSDL file, which your IDE can
then use to generate a whole ton of objects. You can then treat these as local,
and the library will know how to make the remote magic happen.

These are much more common in the .NET world, and have fallen out of favor in
startup land. Many larger businesses still use SOAP, though, due to tight
integration with the IDE.

## "REST"

### Synopsis:

Ruby on Rails brought respect for HTTP into the developer world. A blending of
RPC, SOAP, and hypermedia API types.

### Examples:

* [http://developer.github.com/](http://developer.github.com/)
* [https://dev.twitter.com/](https://dev.twitter.com/)
* [http://developers.facebook.com/docs/reference/api/](http://developers.facebook.com/docs/reference/api/)

### Description:

Originally, REST was synonymous with what is now called "Hypermedia APIs."
However, after large amounts of misunderstanding, REST advocates are
rebranding REST to "Hypermedia APIs" and leaving REST to the RESTish folks.
See '[REST is over'](/posts/2012-02-23-rest-is-over) for more.

REST is basically "RPC and/or SOAP that respects HTTP." A large problem with
RPC and SOAP APIs is that they tunnel everything through one endpoint, which
means that they can't take advantage of many features of HTTP, like auth and 
caching. RESTful APIs mitigate this disadvantage by adding lots of endpoints;
one for each 'resource.' The SOAPish ones basically allow you to CRUD objects
over HTTP by using tooling like ActiveResource, and the RPC ones let you
perform more complicated actions, but always with different endpoints.

## Hypermedia

### Synopsis:

Hypermedia is used to drive clients through various business processes. The
least understood and deployed API type, with one exception: the World Wide
Web.

### Examples:

* [http://www.twilio.com/docs/api/rest](http://www.twilio.com/docs/api/rest)
* [http://www.spire.io/docs/tutorials/rest-api.html](http://www.spire.io/docs/tutorials/rest-api.html)
* [http://kenai.com/projects/suncloudapis/pages/Home](http://kenai.com/projects/suncloudapis/pages/Home)

### Description:

Originally called REST, Hypermedia APIs take full advantage of HTTP. They
use hypermedia formats to drive business processes, providing the ultimate
decoupling of clients and servers.

You can tell an API is Hypermedia by providing only one API endpoint, but
which accepts requests at other endpoints that are provided by discovery.
You navigate through the API by letting the server's responses guide you.
