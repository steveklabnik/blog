---
title: "Introducing Metadown"
date: 2011-01-23 07:45
---

Because I don't have enough gems made already, I made another one last night:
[metadown](https://rubygems.org/gems/metadown).

## What's Metadown do?

This blog originally used Jekyll. When I moved it to my own personal blog
implementation, I noticed something: Markdown doesn't actually have support
for adding YAML at the top of your files, like Jekyll does. I always _knew_
this, I just didn't think about it before. And I love using Markdown, so I
ended up extracting my own version of this trick into Metadown.

Basically, sometimes you need metadata about your markup file. YAML is
a nice format for writing key/value pairs, lists, and other things... so
I've let you smash the two of them together in one file by adding some
`---`s at the top.

## Gimme an Example

```
require 'metadown'

data = Metadown.render("hello world")
data.output #=> "<p>hello, world</p>"
data.metadata #=> "{}"

text = <<-MARKDOWN
---
key: "value"
---
hello world
MARKDOWN

data = Metadown.render(text)
data.output #=> "<p>hello, world</p>\n"
data.metadata #=> {"key" => "value"}
```

## Where's the code?

It's implemented using a custom parser for Redcarpet, has a test suite, and
works on every Ruby that's not JRuby. You can [check out the source
here](https://github.com/steveklabnik/metadown). Issues and Pull Requests
welcome. There's at least one thing that I know I'll need to add to it in
the near future.
