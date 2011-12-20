---
layout: post
title: "Write Better Cukes With the Rel Attribute"
date: 2011-12-20 09:22
comments: true
categories: 
---

The other day, I was working on some Cucumber features for a project, and I
discovered a neat technique that helps you to write better Cucumber steps.

Nobody wants to be [cuking it wrong](http://elabs.se/blog/15-you-re-cuking-it-wrong),
but what does that really mean? Here's Jonas' prescription:

{% blockquote %}
A step description should never contain regexen, CSS or XPath selectors, any
kind of code or data structure. It should be easily understood just by reading
the description.
{% endblockquote %}

Great. Let's [pop the why stack](http://www.theregister.co.uk/2007/06/25/thoughtworks_req_manage/)
a few times, shall we?

**Q1**: Why do we want to have descriptions not use regexen, CSS selectors, or code?<br/>
**A1**: To give it a simpler language.

**Q2**: Why do we want it to be in a simpler language?<br />
**A2**: So that it's easily understandable for stakeholders.

**Q3**: Why do we want it to be easily understandable for stakeholders?<br />
**A3**: Because then we can share a [common language](http://domaindrivendesign.org/node/132).

**Q4**: Why is a common language important?<br />
**A4**: A shared language assists in making sure our model matches the desires of our stakeholders.

**Q5**: Why do we want to match the desires of our stakeholders?<br />
**A5**: That's the whole reason we're on this project in the first place!

Anyway, that's what it's really all about: developing that common language.
Cukes should be written in that common language so that we can make sure we're
on track. So fine: common language. Awesome. Let's do this. 

## Write some cukes in common language

Time to write a cuke:

```
Scenario: Editing the home page
  Given I'm logged in as an administrator
  When I go to the home page
  And I choose to edit the article
  And I fill in some content
  And I save it
  Then I should see that content
```

Basic CMS style stuff. I'm not going to argue that this is the best cuke in the
world, but it's pretty good. What I want to do is examine some of these steps
in more detail. How would you implement these steps?

``` ruby
When /^I choose to edit the article$/ do
  pending
end

When /^I fill in some content$/ do
  pending
end

When /^I save it$/ do
  pending
end

Then /^I should see that content$/ do
  pending
end
```

Go ahead. Write them down somewhere. I'll wait.<br /><br /><br /><br /><br /><br />

... done yet?

<br /><br /><br /><br />

## Implementing a step

Done? Okay! Before I show you my implementation, let's talk about this step:

``` ruby
When /^I choose to edit the article$/
```

When writing this step, I realized something. When trying to write steps like
these, there's a danger in tying them too closely to your specific HTML. It's
why many people don't write view tests: they're brittle. I actually like view
tests, but that's another blog post. Point is this: we know we're going to
follow a link, and we know that we want that link to go somewhere that will
let us edit the article. We don't really care _where_ it is in the DOM, just
that somewhere, we've got an 'edit article' link. How to pull this off?

### First idea: id attribute

You might be thinking "I'll give it an id attribute!" Here's the problem with
that: ids have to be unique, per page. With article editing, that might not be
a problem, but it's certainly not a general solution. So that's out.

### Second time: class attribute

"Okay, then just use a class. Your blog sucks." Well, let's check out what
[the HTML5 spec says about classes](http://www.w3.org/TR/html5/elements.html#classes).

{% blockquote %}
Basically nothing about semantics.
{% endblockquote %}

Okay, so that's paraphrased. But still, the spec basically says some stuff
about the details of implementing classes, but absolutely nothing about the
semantics of a class. In practice, classes are largely used for styling
purposes. We don't want to conflate our styling with our data, so overloading
class for this purpose might work, but feels kinda wrong.

### What about the text?

We could match on the text of the link. After all, that's what people use to
determine what links to click on. The link with the text "Edit this post" lets
us know that that link will let us edit a post.

Matching on the text is brittle, though. What happens when marketing comes
through and changes the text to read "Edit my post"? Our tests break. Ugh.

There's got to be a better way. Otherwise, I wouldn't be writing this blog post.

### The best way: the rel attribute

When doing research for [my book on REST](http://getsomere.st), I've been doing
a lot of digging into various standards documents. And one of the most important
attributes from a REST perspective is one that nobody ever talks about or uses:
the `rel` attribute. From [the HTML5 spec](http://www.w3.org/TR/html5/links.html#attr-hyperlink-rel):

{% blockquote %}
The rel attribute on a and area elements controls what kinds of links the
elements create. The attribue's value must be a set of space-separated tokens.
The allowed keywords and their meanings are defined below.
{% endblockquote %}

Below? That's [here](http://www.w3.org/TR/html5/links.html#linkTypes):


{% blockquote %}
The following table summarizes the link types that are defined by this
specification. This table is non-normative; the actual definitions for the link
types are given in the next few sections.

alternate: Gives alternate representations of the current document.
author: Gives a link to the current document's author.
bookmark: Gives the permalink for the nearest ancestor section.
{% endblockquote %}

Hey now! Seems like we're on to something. There's also [RFC 5988](http://tools.ietf.org/html/rfc5988),
"Web Linking". [Section four](http://tools.ietf.org/html/rfc5988#section-4)
talks about Link Relation Types:

{% blockquote %}
In the simplest case, a link relation type identifies the semantics
of a link.  For example, a link with the relation type "copyright"
indicates that the resource identified by the target IRI is a
statement of the copyright terms applying to the current context IRI.

Link relation types can also be used to indicate that the target
resource has particular attributes, or exhibits particular
behaviours; for example, a "service" link implies that the identified
resource is part of a defined protocol (in this case, a service
 description).
{% endblockquote %}

Bam! Awesome! This is exactly what we want!

## So how do we use rel attributes?

I'll be going into more depth about these kinds of topics in [my book](http://getsomere.st),
but here's the TL;DR:

1. There are a set of official types. Try to use those if they're
applicable, but they're quite general, so that's often not the case.
2. You can put whatever else you want. Space delineated.
3. The best way is to use a URI and then make a resource at that URI
that documents the relation's semantics.

We'll go with option two for now, for simplicity.

## Making our link, with semantics.

Here's what a link with our newly minted relation looks like:

``` html
<a href="/posts/1/edit" rel="edit-post">Edit this post</a>
```

Super simple. Just that one little attribute. Now we can write a step to match:

``` ruby
When /^I choose to edit the article$/ do
  find("//a[@rel='edit-article']").click
end
```

This code matches what we'd do as a person really well. "Find the link that
edits an article, and click on it." We've not only made the title of our step
match our idea of what a person would do, but the code has followed suit.
Awesome. We can move this link anywhere on the page, our test doesn't break.
We can change the text of the link, and our test doesn't break. So cool.

## Better tests through web standards

Turns out that diving around in standards has some practical benefits after all,
eh? Think about the relationship between your cukes, your tests, and your API
clients: Cucumber, through Selenium, is an automated agent that interacts with
your web service. API clients are automated agents that interact with your web
service. Hmmmm...

If you want to know more about this, that's what [my book](http://getsomere.st)
is for. I'll be covering topics like this in depth, and explaining standards in
simple language.

Seriously. Did you sign up for [my book](http://getsomere.st) yet? ;)
