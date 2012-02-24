---
layout: post
title: "Implementing HATEOAS with Presenters"
date: 2011-12-30 11:00
---

I'm a big fan of using the presenter pattern to help separate logic from
presentation. There's a great gem named
[Draper](https://github.com/jcasimir/draper) that can help facilitate this
pattern in your Rails apps. When doing research for
[my book about REST](http://getsomere.st), I realized that the presenter
pattern is a great way to create responses that comply with the hypermedia
constraint, a.k.a. HATEOAS. I wanted to share with you a little bit about
how to do this.

Please note that '[REST is over'](/posts/2012-02-23-rest-is-over).

Note: We'll be creating HTML5 responses in this example, as HTML is a hypermedia
format, and is therefore conducive to HATEOAS. JSON and XML don't cut it.

## First, some setup

I fired up a brand new Rails app by doing this:

```
$ rails new hateoas_example
$ cd hateoas_example
$ cat >> Gemfile
gem "draper"
^D
$ bundle
$ rails g resource post title:string body:text
$ rake db:migrate
$ rails g draper:decorator Post
```

Okay, now we should be all set up. We've got a Rails app, it's got draper
in the Gemfile, we have a Post resource, and our PostDecorator.

## The View

I like to do the view first, to drive our what we need elsewhere. Here
it is:

```
<h2>Title</h2>
<p><%= @post.title %></p>

<h2>Body</h2>
<p><%= @post.body %></p>

<h2>Links</h2>
<ul>
  <% @post.links.each do |link| %>
    <li><%= link_to link.text, link.href, :rel => link.rel %></li>
  <% end %>
</ul>
```

We're displaying our title and body, but we also want to spit out some links.
These links should have a few attributes we need. I might even (shhhhhhh)
<small>extract this link thing out into a helper to add the rel stuff every
time</small>. It just depends. For this example, I didn't feel like it.

## The Controller

Well, we know we're gonna need a `@post` variable set, so let's get that going
in our controller:

``` ruby 
class PostsController < ApplicationController
  def show
    @post = PostDecorator.find(params[:id])
  end
end
```

Super simple. Yay Draper!

## The Presenter

We know we need a `links` method that returns some links, and those links need to
have rel, href, and text attributes. No problem!

``` ruby
class Link < Struct.new(:rel, :href, :text)
end

class PostDecorator < ApplicationDecorator
  decorates :post

  def links
    [self_link, all_posts_link]
  end

  def all_posts_link
    Link.new("index", h.posts_url, "All posts")
  end

  def self_link
    Link.new("self", h.post_url(post), "This post")
  end
end
```

Now, we could have just returned an array of three-element arrays, but
I really like to use the Struct.new trick to give us an actual class.
It makes error messages quite a bit better, and reminds us that we
don't happen to have an array, we have a Link.

We construct those links by taking advantage of the 'index' and 'self' rel
attributes that are [defined in the registry](http://www.iana.org/assignments/link-relations/link-relations.xml).

## The output

That gives us this:

```
<!DOCTYPE html>
<html>
<head>
  <title>HateoasSample</title>
  <link href="/assets/application.css?body=1" media="screen" rel="stylesheet" type="text/css" />
<link href="/assets/posts.css?body=1" media="screen" rel="stylesheet" type="text/css" />
  <script src="/assets/jquery.js?body=1" type="text/javascript"></script>
<script src="/assets/jquery_ujs.js?body=1" type="text/javascript"></script>
<script src="/assets/posts.js?body=1" type="text/javascript"></script>
<script src="/assets/application.js?body=1" type="text/javascript"></script>
  <meta content="authenticity_token" name="csrf-param" />
<meta content="0k+SQVv6yr0d12tGWYx7KNXUWaf6f+wgUUNITsAOnHI=" name="csrf-token" />
</head>
<body>

<h2>Title</h2>
<p>A post, woo hoo!</p>

<h2>Body</h2>
<p>this is some text that's the body of this post</p>

<h2>Links</h2>
<ul>
    <li><a href="http://localhost:3000/posts/1" rel="self">This post</a></li>
    <li><a href="http://localhost:3000/posts" rel="index">All posts</a></li>
</ul>


</body>
</html>
```

You'll probably want to make a layout that ignores all of the JS stuff, but
for this example, I just left it as-is. It's just that easy. Happy linking!

