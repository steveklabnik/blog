---
layout: post
title: "Rubinius Is Awesome"
date: 2011-10-04 08:40
comments: true
categories:
---

You walk into work tomorrow morning, and your boss says this:

> Boss: Hey, we're gonna need to go ahead and have you implement
> require_relative in rubinius. We have some new servers coming in, and we'll
> be running it in production, but we use some 1.9.2 features of MRI that
> haven't been implemented yet. So if you could just go ahead and get to
> implementing that, that would be terrific, OK?

Wat do?

(Disregard that your boss would never say this. I kinda wish some of mine
would...)

> You: Excuse me, I believe you have my stapler...

Err, sorry.

> You: No problem, boss. Rubinius is mostly just Ruby, and it has a really
> helpful core team. I'm sure it won't be a big deal.

Would you say this? Well, you should. I'm not gonna lie and say that _every_
feature is super simple to implement, or rbx-2.0 would be out already, but for
a language interpreter, Rubinius is one of the easiest I've ever tried to get
into. I actually did implement require_relative last night, and it took me about
an hour and a half.

This is my story.

(note: dramatazation. Actual wording made unneccesarily silly to protect the
innocent. please do try this at home)

```text lol.txt
$ ssh stevessecretserver
$ tmux attach
<brings up irssi, I'm already in #rubinius on Freenode>
#rubinius: steveklabnik: hey, I need require\_relative to run my app. How hard
would you think that is to implement?
#rubinius: evan: Naw, man, it'd take like fifteen minutes. Go check out
http://rubygems.org/gems/rbx-require-relative, it's alredy basically got what
you want
#rubinius: steveklabnik: sweet.
#rubinius: brixen: just grep for 'def require'
#rubinius: brixen: and run bin/mspec -tx19 core/kernel/require\_relative to
run the RubySpecs for it.
```

Armed with this knowledge, I found where require is defined in rbx:

```ruby kernel/common/kernel.rb https://github.com/rubinius/rubinius/blob/589f1b08bfece6b86c1332a976704eb792025401/kernel/common/kernel.rb#L737
def require(name)
  Rubinius::CodeLoader.require name
end
module_function :require
```

Of course, I had to look at CodeLoader:

```ruby kernel/common/codeloader.rb https://github.com/rubinius/rubinius/blob/589f1b08bfece6b86c1332a976704eb792025401/kernel/common/codeloader.rb#L30
# Searches for and loads Ruby source files and shared library extension
# files. See CodeLoader.require for the rest of Kernel#require
# functionality.
def require
  Rubinius.synchronize(self) do
    return false unless resolve_require_path
    return false if CodeLoader.loading? @load_path

    if @type == :ruby
      CodeLoader.loading @load_path
    end
  end

  if @type == :ruby
    load_file
  else
    load_library
  end

  return @type
end
```

Hmm, see `CodeLoader.require`. There are codeloader18 and codeloader19
files...

```ruby kernel/common/codeloader19.rb https://github.com/rubinius/rubinius/blob/589f1b08bfece6b86c1332a976704eb792025401/kernel/common/codeloader19.rb
module Rubinius
  class CodeLoader

    # Searches $LOAD_PATH for a file named +name+. Does not append any file
    # extension to +name+ while searching. Used by #load to resolve the name
    # to a full path to load. Also used by #require when the file extension is
    # provided.
    def search_load_path(name, loading)
      $LOAD_PATH.each do |dir|
        path = "#{dir}/#{name}"
        return path if loadable? path
      end

      return name if loading and loadable? "./#{name}"

      return nil
    end
  end
end
```

Okay. So we define specific stuff into the 19 file. There's also a
kernel19. So I worked this up:

```ruby kernel/common/kernel19.rb
# Attempt to load the given file, returning true if successful. Works just
# like Kernel#require, except that it searches relative to the current
# directory.
#
def require_relative(name)
  Rubinius::CodeLoader.require_relative(name)
end
module_function :require_relative
```

```ruby kernel/common/codeloader19.rb
# requires files relative to the current directory. We do one interesting
# check to make sure it's not called inside of an eval.
def self.require_relative(name)
  scope = Rubinius::StaticScope.of_sender
  script = scope.current_script
  if script
    require File.join(File.dirname(script.data_path), name)
  else
    raise LoadError.new "Something is wrong in trying to get relative path"
  end
end
```

But then... running the specs gives me bunches of errors. What gives?

```text lol.txt
<back in irc>
#rubinius: steveklabnik: yo, my specs are failing, and I'm a n00b. Halp
pl0x?
#rubinius: brixen: oh, yeah, well, the StaticScope is the current scope,
and you're down another method, so that's _totally_ gonna screw up
your paths. Just get it above and pass it down. Oh, and File.join is
dumb, File.expand_path that shit!
#rubinius: steveklabnik: words.
```

So then I made this one little change:

```ruby kernel/common/kernel19.rb
# Attempt to load the given file, returning true if successful. Works just
# like Kernel#require, except that it searches relative to the current
# directory.
#
def require_relative(name)
  scope = Rubinius::StaticScope.of_sender
  Rubinius::CodeLoader.require_relative(name, scope)
end
module_function :require_relative
```

```ruby kernel/common/codeloader19.rb
# requires files relative to the current directory. We do one interesting
# check to make sure it's not called inside of an eval.
def self.require_relative(name, scope)
  script = scope.current_script
  if script
    require File.expand_path(name, File.dirname(script.data_path))
  else
    raise LoadError.new "Something is wrong in trying to get relative path"
  end
end
```

```bash
$ bin/mspec -tx19 core/kernel/require_relative
rubinius 2.0.0dev (1.9.2 cade3517 yyyy-mm-dd JI) [x86_64-apple-darwin10.8.0]
.....................

Finished in 0.191995 seconds

1 file, 20 examples, 47 expectations, 0 failures, 0 errors
```

![awwww yeah](/images/awwwyeah.jpg)

One more pull request, and I've got a patch in on rbx. I had one a few
months ago, but this one was way cooler.

## In conclusion

Even if I didn't have some code to look at, because Rubinius is just Ruby, it
was really easy to dive in and check out the code, because it's all Ruby.
Seriously. Rubinius is just Ruby. Just Ruby. Ruby.

So dive in and add some features today! If having an awesome alternate Ruby
implementation isn't enough for you, the rbx team will bribe you with
special stickers for committers, and sweet black-on-black tshirts for
people with 10 commits or more!
