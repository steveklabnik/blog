---
layout: post
title: "Redcarpet Is _awesome_!"
date: 2011-12-21 11:00
comments: true
categories: 
---

It's true.

If you haven't used it yet, [Redcarpet](https://github.com/tanoku/redcarpet) is
the Markdown parser that [GitHub uses](https://github.com/blog/832-rolling-out-the-redcarpet)
to work all that magic on their site. So of course, it's awesome.

## You can use it and abuse it

What makes it _really_ awesome is the custom renderers feature. Here's the one
from the documentation:

``` ruby
# create a custom renderer that allows highlighting of code blocks
class HTMLwithAlbino < Redcarpet::Render::HTML
  def block_code(code, language)
    Albino.safe_colorize(code, language)
  end
end

markdown = Redcarpet::Markdown.new(HTMLwithAlbino)
```

You can guess what that does: uses some library called Albino to render code
blocks. There are a whole bunch of hooks you can use to make a custom renderer.
They make it super easy to do something neat with markdown.

So I did.

## Check it: outline generation

I'm working on... this project. And it needs to render a bunch of articles that
are Markdown files. There will be a sidebar. I want to have links to each
section. But I'm a good programmer, which means I'm lazy. So why bother making
my own sidebar? Especially when I can abuse Redcarpet to do it.

Oh, and disclaimer: normally, I'm all about super clean code. Last night, that
wasn't the mood I was in. This code is probably terrible. That's part of the
fun! Please feel free to {clean up,obfuscate,golf,unit test} this code,
<a href="mailto:steve@steveklabnik.com">email me</a>, and tell me how awesome
you are.

With that disclaimer out of the way, round one:

``` ruby
class OutlineRenderer < Redcarpet::Render::HTML
  attr_accessor :outline

  def initialize
    @outline = []
    super
  end

  def header(text, header_level)
    text_slug = text.gsub(/\W/, "_").downcase
    
    self.outline << [header_level, "<a href='##{text_slug}'>#{text}</a>"]

    "<h#{header_level} id='#{text_slug}'>#{text}</h#{header_level}>"
  end
end
```

Every time we hit a header, Redcarpet gives us the text and the header level.
We grab the text, turn it into a slug, and then append a two-element array to
our outline. It keeps track of the level of this header, and makes a link from
the slug. Then, we spit out a header tag, adding on an `id` element that we
linked to in our link.

Next up, rendering:

``` ruby
renderer = OutlineRenderer.new
r = Redcarpet::Markdown.new(renderer)
content = r.render(some_content)
outline = renderer.outline
```

This instantiates our Renderer, creates our Markdown parser, and renders the
content. We also grab the outline we made. Sweet.

Finally, rendering the outline:

``` ruby
def format_outline(outline)
  prev_level = 2

  "<ul>" + outline.inject("") do |html, data|
    level, link = data
    if prev_level < level
      html += "<ul>"
    elsif prev_level > level
      html += "</ul>"
    end
    prev_level = level
    html += "<li>#{link}</li>"
    html
  end + "</ul>"
end
```

This... is amazing. And terrible. Don't drink scotch and code, kids. Or do,
whatever. This takes our `Array` of `Array`s that we made with our renderer
and runs `inject` over it. If our previous level is less than the new level,
we indent with a `<ul>`, and if it's greater, we outdent with a `</ul>`.
Then we render our link, and wrap the whole thing in its own set of `<ul>`s.
Done!

We can call this helper method in our layout, and bam! We get automatic
outlines generated for our Markdown files. Like I said, this is quick and
dirty, but for a first pass, I don't feel too bad about it. Get it done, and
then get it done right.
