---
layout: post
title: "A Hypermedia API Reading List"
date: 2011-02-11 15:00
---

Originally, this post was titled "A RESTful Reading List," but please note that [REST is over. Hypermedia API is the new nomenclature.](/posts/2012-02-23-rest-is-over)

I've been doing an intense amount of research on Hypermedia APIs over the last
few months, and while I didn't save every resource I found, I've made a list
here of the most important.

I'll be updating this post as I get new resources, so check back!

## The book list

If you want to go from 'nothing to everything,' you can do it by reading just a
few books, actually. I'm going to make all of these links affiliate. I purchase
a _lot_ of books myself, maybe suggesting things to you can help defray the
cost of my massive backlog. All are easily searchable on Amazon if you're not
comfortable with that.

Start off with <a href="http://www.amazon.com/gp/product/0596529260/ref=as_li_ss_tl?ie=UTF8&tag=stesblo026-20&linkCode=as2&camp=1789&creative=390957&creativeASIN=0596529260">Restful Web Services</a><img src="http://www.assoc-amazon.com/e/ir?t=stesblo026-20&l=as2&o=1&a=0596529260" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
 by Leonard Richardson and Sam Ruby. This book is fantastic from getting you from
zero knowledge to "I know how Rails does REST by default," which is how most
people do REST. But as you know, that's flawed. However, understanding this stuff
is crucial, not only for when you interact with REST services, but also for
understanding how Hypermedia APIs work differently. This baseline of knowledge
is really important.

It also comes in <a href="http://www.amazon.com/gp/product/0596801688/ref=as_li_ss_tl?ie=UTF8&tag=stesblo026-20&linkCode=as2&camp=1789&creative=390957&creativeASIN=0596801688">cookbook form</a><img src="http://www.assoc-amazon.com/e/ir?t=stesblo026-20&l=as2&o=1&a=0596801688" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
You really only need one or the other; pick whichever format you like.

Next up, read <a href="http://www.amazon.com/gp/product/0596805829/ref=as_li_ss_tl?ie=UTF8&tag=stesblo026-20&linkCode=as2&camp=1789&creative=390957&creativeASIN=0596805829">REST in Practice: Hypermedia and Systems Architecture</a><img src="http://www.assoc-amazon.com/e/ir?t=stesblo026-20&l=as2&o=1&a=0596805829" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
This book serves as a great _bridge_ to understanding Hypermedia APIs from the
RESTful world. Chapters one through four read like Richardson & Ruby; yet they
start slipping in the better hypermedia terminology. Chapter five really starts
to dig into how Hypermedia APIs work, and is a great introduction. Chapter six
covers scaling, chapter seven is an introduction to using ATOM for more than an
RSS replacement, nine is about security, and eleven is a great comparison of
how Hypermedia and WS-\* APIs differ. All in all, a great intermediate book.

To really start to truly think in Hypermedia, though, you _must_ read <a href="http://www.amazon.com/gp/product/1449306578/ref=as_li_ss_tl?ie=UTF8&tag=stesblo026-20&linkCode=as2&camp=1789&creative=390957&creativeASIN=1449306578">Building Hypermedia APIs with HTML5 and Node</a><img src="http://www.assoc-amazon.com/e/ir?t=stesblo026-20&l=as2&o=1&a=1449306578" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
Don't let the title fool you, as Mike says in the introduction:

> [HTML5, Node.js, and CouchDB] are used as tools illustrating points about
> hypermedia design and implementation.

This is not a Node.js book. I find Node slightly distasteful, but all the
examples were easy to follow, even without more than a cursory working
knowledge.

Anyway, the book: Mike says something else that's really important in the intro:

> While the subject of the REST architectural style comes up occasionally, this
> book does not explore the topic at all. It is true that REST identifies
> hypermedia as an important aspect of the style, but this is not the case for
> the inverse. Increasing attention to hypermedia designs can improve the
> quality and functionality of many styles of distributed network architecture
> including REST.

And, in the afterward:

> However, the aim of this book was not to create a definitive work on
> designing hypermedia APIs. Instead, it was to identify helpful concepts,
> suggest useful methodologies, and provide pertinent examples that encourage
> architects, designers, and developers to see the value and utility of
> hypermedia in their own implementations.

I think these two statements, taken together, describe the book perfectly. The
title is "Building Hypermedia APIs," not "Designing." So why recommend it on
an API design list? Because understanding media types, and specifically
hypermedia-enabled media types, is the key to understanding Hypermedia APIs.
Hence the name.

Mike is a great guy who's personally helped me learn much of the things that
I know about REST, and I'm very thankful to him for that. I can't recommend
this book highly enough.

However, that may leave you wondering: Where's the definitive work on how to
actually build and design a Hypermedia API? Did I mention, totally unrelated
of course, that [I'm writing a book](http://getsomere.st)? ;)

Yes, it still has REST in the title. Think about that for a while, I'm sure
you can see towards my plans. I'm planning on a beta release as soon as I'm
recovered from some surgery this week, but I'm not sure how long that will
take, exactly. So keep your eyes peeled.

### Books I don't recommend

<a href="http://www.amazon.com/gp/product/1449310508/ref=as_li_ss_tl?ie=UTF8&tag=stesblo026-20&linkCode=as2&camp=1789&creative=390957&creativeASIN=1449310508">REST API Design Rulebook</a><img src="http://www.assoc-amazon.com/e/ir?t=stesblo026-20&l=as2&o=1&a=1449310508" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
, while I haven't actually read it, seems quite terrible. Let me copy an
[Amazon review](http://www.amazon.com/review/R2F4STDF7XS7U3/ref=cm_cr_dp_perm?ie=UTF8&ASIN=1449310508&nodeID=283155&tag=&linkCode=):

> The first chapters give a good feel for the vocabulary, and some good
> techniques for implementing REST. A lot of the 'rules', especially those
> related to basic CRUD operations, are clean and simple with useful examples.
> 
> Unfortunately, the later chapters get more and more focused on specifying
> something called 'WRML', which is a concept/language newly introduced in this
> book as far as I can tell.
> 
> Personally I would recommend ignoring the sections dealing with WRML (or keep
> them in mind as a detailed example of one possible way of handling some of
> the REST issues).
> 
> As to WRML itself: yuck. It appears to be an attempt to drag in some of the
> unnecessary complexity of SOAP with little added benefit. Not recommended.

Looking up information about WRML, I can agree, 100%. Ugh. So nasty. So this
gets a big fat downvote from me.

### Books I want to read

There aren't any in this category. Should there be? You tell me!

## Web resources

There are so many, this will just be a partial list for now.

Of course, [Fielding's dissertation](http://www.ics.uci.edu/~fielding/pubs/dissertation/top.htm)
is essential.

Roy has also written [REST APIs Must be Hypertext
Driven](http://roy.gbiv.com/untangled/2008/rest-apis-must-be-hypertext-driven).
This post is central for understanding why "Hypermedia API" is a much better
name than REST, and why hypermedia in general is so essential.

I've written [this post about
HATEOAS](http://timelessrepo.com/haters-gonna-hateoas). It's a pretty basic,
simple introduction to the topic.

I gave a talk called [Everything you know about REST is wrong](http://vimeo.com/30764565).

[This talk by Jon Moore](http://vimeo.com/20781278) was instrumental in giving me
a mental breakthrough about HATEAOS. He was kind enough to [share some
code with me](https://gist.github.com/1445773) that he used in the presentation
as well. This is also an earlier example of the usage of "Hypermedia APIs."

A classic: [How I explained REST to my wife](http://tomayko.com/writings/rest-to-my-wife).
A great story, simple and easy to explain.

Another classic is [How to GET a
cup of coffee](http://www.infoq.com/articles/webber-rest-workflow). It 
does a great job of explaining how to model your business processes as state
machines, and then convert them to HTTP.

In which Mike Mayo has a realization that HATEOAS is not simply academic:
[http://mikemayo.org/2012/how-i-learned-to-stop-worrying-and-love-rest](http://mikemayo.org/2012/how-i-learned-to-stop-worrying-and-love-rest)

A recent resource that's popped up is [Designing a RESTful Web API](http://publish.luisrei.com/rest.html). It's a nice, basic overview of lots of things.

## Related resources

<a href="http://www.amazon.com/gp/product/1449308929/ref=as_li_ss_tl?ie=UTF8&tag=stesblo026-20&linkCode=as2&camp=1789&creative=390957&creativeASIN=1449308929">APIs: A Strategy Guide</a><img src="http://www.assoc-amazon.com/e/ir?t=stesblo026-20&l=as2&o=1&a=1449308929" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
seems really interesting. This isn't about REST or Hypermedia APIs specifically,
but more making a case for why you'd want an API in the first place. Which is
a related topic for all of us API enthusiasts, for sure. I haven't read it yet,
but it's on the related list.

<a href="http://www.amazon.com/gp/product/0262572338/ref=as_li_ss_tl?ie=UTF8&tag=stesblo026-20&linkCode=as2&camp=1789&creative=390957&creativeASIN=0262572338">Protocol: How Control Exists after Decentralization</a><img src="http://www.assoc-amazon.com/e/ir?t=stesblo026-20&l=as2&o=1&a=0262572338" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
is one of my favorite books ever. This book manages to be both a hard computer
science book as well as referencing a broad range of philosophy, history, and
other fields as well.

If sentences like

> A perfect exmaple of a distributed network is the rhizome described in
> Deleuze and Guattari's _A Thousand Plateaus_. Reacting specifically to what
> they see as the totalitarianism inherent in centralized and even
> decentralized networks, Deleuze and Guattari instead describe the rhizome, a
> horizontal meshwork derived from botany. The rhizome links many autonomous
> nodes together in a manner that is neither linear nor hierarchical. Rhizomes
> are heterogeneous and connective, that is to say, "Any point of a rhizome can
> be connected to anything other."

immediately followed by a hardcore, low-level diagram of the four levels of
networking: application layer, transport layer, internet layer, and link layer.
With full (and accurate) descriptions of TCP, IP, DNS, the SYN-ACK/SYN-ACK
handshake, and HTTP following gets you all hot and bothered, you _need_ to read
this book. Hell, if you don't like literature stuff, the politics in this book
are amazing. This book draws the connections between _why_ the APIs we're
building matter, and for that matter, the systems that we programmers create.
Seriously, I can't recommend this book enough.

<a href="http://www.amazon.com/gp/product/0801882575/ref=as_li_ss_tl?ie=UTF8&tag=stesblo026-20&linkCode=as2&camp=1789&creative=390957&creativeASIN=0801882575">Hypertext 3.0: Critical Theory and New Media in an Era of Globalization</a><img src="http://www.assoc-amazon.com/e/ir?t=stesblo026-20&l=as2&o=1&a=0801882575" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
is related, and absolutely interesting. Here's the eight main sections:

1. Hypertext: An introduction
2. Hypertext and Critical Theory
3. Reconfiguring the Text
4. Reconfiguring the Author
5. Reconfiguring Writing
6. Reconfiguring Narrative
7. Reconfiguring Literary Education
8. The Politics of Hypertext: Who Controls the Text?

While not _directly_ useful for those designing APIs, those of us who like to
draw broad connections between disciplines will find that this book has lots
of interesting parallels. Especially around the politics angle, as well
as reconfiguring narrative.


