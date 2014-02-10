---
title: "Announcing emoji 1.0"
date: 2014-02-10 22:11
---

A long time ago, I wanted an emoji gem. So I set out to make one. Turns out,
emoji are damn complex. [Emoji
Licensing](http://words.steveklabnik.com/emoji-licensing) was one of the
results.  Who'd have guessed the hard part of making a gem was the legal part!
Next up was that the 'emoji' gem was waaaay out of date: it was a library for
converting between Japanese telecoms' emoji, which was important years ago, but
not now that they're just UTF-8. So I contacted the owner, who graciously gave
me the gem.

Well, after doing the legal and social work, it turns out that some other
people were interested in the idea as well! In the end, [I didn't write very
much actual
code](https://github.com/steveklabnik/emoji/commits?author=steveklabnik), and
[Winfield](https://github.com/wpeterson) really stepped up and made the code
side happen.

So today, I'm very happy to have just released version 1.0 of the emoji gem,
and to officially hand off maintainership to Winfield. Thanks for all your hard
work!

Install it with

```
$ gem install emoji
```

And find the source on GitHub:
[https://github.com/steveklabnik/emoji](https://github.com/steveklabnik/emoji)
