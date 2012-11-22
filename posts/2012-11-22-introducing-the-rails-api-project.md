---
title: "Introducing the Rails API Project"
date: 2012-11-22 09:29
---

Ruby on Rails is a great tool to build websites incredibly quickly and easily.
But what about applications that aren't websites? Rails is still a first-class
choice for this use-case, but why settle for good when you could be the best?

That's why I'm happy to introduce Rails API: a set of tools to build excellent
APIs for both heavy Javascript applications as well as non-Web API clients.

What
----

Rails' greatest feature is making trivial choices for you. By following
conventions, you're able to avoid bikeshedding and only focus on the actual
decisions that matter for your application, while automatically building in
best-practices. Rails API will do this for the API use-case.

Here are some initial thoughts on what Rails API will do for you:

### A simpler stack

First, we can remove many parts of Rails that aren't important in an API
context: many middleware don't make sense, and all of ActionView can go away.

To check out exactly what we mean, look at [this
part](https://github.com/rails-api/rails-api#choosing-middlewares) of the
README, which explains which middlewares we include. The default stack has 22,
we have 14.

Similarly, the structure of ActionController::Base is interesting: it includes
a ton of modules that implement various features. This means that we can build
an alternate 'controller stack' that doesn't include all of the ones that are
in Base. Check out [this
portion](https://github.com/rails-api/rails-api#choosing-controller-modules) of
the README for a demonstration of the modules we do include. Base includes 29
modules, we include 11.

### Consistent Javascript output

One of the biggest issues when building a distributed system is messages that
are sent between components. In most Rails-based APIs, this means the JSON that
your server side emits, and the JSON that your client consumes. By forming best
practices around what JSON is sent around, we can simplify things for
server-side and client-side developers.

The generation of this JSON should be as transparent and simple as possible
on both sides. ActiveModel::Serializers is key here. Many new APIs are settling
on HAL as a JSON variant that is important to them, and so we'll be considering
it heavily.

### Authentication

APIs don't need to handle cookie-based auth, and so a lot of that
infrastructure isn't important. Handling other kinds of auth in a simple way is
incredibly important.

### JavaScript as a first-class citizen

JavaScript is just as important as Ruby for these kinds of applications, and
should be equally as important with respect to tooling, directory layout, and
documentation.

This also means that it should be easy to use the various Javascript frameworks
and testing tools. We have representatives from the Ember team on-board, but
using other frameworks should be equally fantastic.

### Hypermedia

Many people are interested in building Hypermedia APIs on top of Rails, and
so building best-practices around this style should be taken care of, and
building them should be easy.

Where
-----

You can find the organization on GitHub at [https://github.com/rails-api](https://github.com/rails-api)

Originally, these two repositories were located at [https://github.com/spastorino/rails-api](https://github.com/spastorino/rails-api) and [https://github.com/josevalim/active_model_serializers](https://github.com/josevalim/active_model_serializers).

We have a Google Group for discussion here: [https://groups.google.com/forum/?fromgroups#!forum/rails-api-core](https://groups.google.com/forum/?fromgroups#!forum/rails-api-core)

Who
---

Currently, 

* Carlos Antonio
* Rafael França
* Santiago Pastorino
* Steve Klabnik
* Yehuda Katz
* Tom Dale
* José Valim

