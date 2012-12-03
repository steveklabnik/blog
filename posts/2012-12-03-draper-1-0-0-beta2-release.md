---
title: "Draper 1.0.0.beta2 release"
date: 2012-12-03 08:30
---

I've relased the second beta for Draper 1.0.0! Many thanks to all of you who
gave the first beta a shot. We've fixed some issues, and I'd apprecaite you
giving this one a try.

You can get it by installing it from Rubygems:

```
$ gem install draper --pre
```

or by putting it in your Gemfile:

```
gem "draper", "1.0.0.beta2"
```

## CHANGELOG

These are the changes since beta1. To find out what's new in beta1, please
[see my previous post](/posts/2012-11-30-draper-1-0-0-beta1-release).

* `has_finders` is now `decorates_finders`. [https://github.com/haines/draper/commit/33f18aa062e0d3848443dbd81047f20d5665579f](https://github.com/haines/draper/commit/33f18aa062e0d3848443dbd81047f20d5665579f)

* If a finder method is used, and the source class is not set and cannot be inferred, an `UninferrableSourceError` is raised. [https://github.com/haines/draper/commit/8ef5bf2f02f7033e3cd4f1f5de7397b02c984fe3](https://github.com/haines/draper/commit/8ef5bf2f02f7033e3cd4f1f5de7397b02c984fe3)

* Class methods are now properly delegated again. [https://github.com/haines/draper/commit/731995a5feac4cd06cf9328d2892c0eca9992db6](https://github.com/haines/draper/commit/731995a5feac4cd06cf9328d2892c0eca9992db6)

* We no longer `respond_to?` private methods on the source. [https://github.com/haines/draper/commit/18ebac81533a6413aa20a3c26f23e91d0b12b031](https://github.com/haines/draper/commit/18ebac81533a6413aa20a3c26f23e91d0b12b031)

* Rails versioning relaxed to support Rails 4 [https://github.com/drapergem/draper/commit/8bfd393b5baa7aa1488076a5e2cb88648efaa815](https://github.com/drapergem/draper/commit/8bfd393b5baa7aa1488076a5e2cb88648efaa815)
