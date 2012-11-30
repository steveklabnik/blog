---
title: "Draper 1.0.0.beta1 release"
date: 2012-11-30 14:07
---

I'm happy to announce the release of Draper 1.0.0.beta1 today. If you use
Draper, I'd appreciate you checking out the beta release in your app, kicking
the tires, and letting me know what's up.

You can get it by installing it from Rubygems:

```
$ gem install draper --pre
```

or by putting it in your Gemfile:

```
gem "draper", "1.0.0.beta1"
```

Notable changes include:

* Renaming `Draper::Base` to `Draper::Decorator`. This is the most significant
  change you'll need to upgrade your application. [https://github.com/drapergem/draper/commit/025742cb3b295d259cf0ecf3669c24817d6f2df1](https://github.com/drapergem/draper/commit/025742cb3b295d259cf0ecf3669c24817d6f2df1)
* Added an internal Rails application for integration tests. This won't affect
  your application, but we're now running a set of Cucumber tests inside of a
  Rails app in both development and production mode to help ensure that we
  don't make changes that break Draper. [https://github.com/drapergem/draper/commit/90a4859085cab158658d23d77cd3108b6037e36f](https://github.com/drapergem/draper/commit/90a4859085cab158658d23d77cd3108b6037e36f)
* Add `#decorated?` method. This gives us a free RSpec matcher,
  `is_decorated?`. [https://github.com/drapergem/draper/commit/834a6fd1f24b5646c333a04a99fe9846a58965d6](https://github.com/drapergem/draper/commit/834a6fd1f24b5646c333a04a99fe9846a58965d6)
* `#decorates` is no longer needed inside your models, and should be removed.
  Decorators automatically infer the class they decorate. [https://github.com/drapergem/draper/commit/e1214d97b62f2cab45227cc650029734160dcdfe](https://github.com/drapergem/draper/commit/e1214d97b62f2cab45227cc650029734160dcdfe)
* Decorators do not automatically come with 'finders' by default. If you'd like
  to use `SomeDecorator.find(1)`, for example, simply add `#has_finders` to
  the decorator to include them. [https://github.com/drapergem/draper/commit/42b6f78fda4f51845dab4d35da68880f1989d178](https://github.com/drapergem/draper/commit/42b6f78fda4f51845dab4d35da68880f1989d178)
* To refer to the object being decorated, `#source` is now the preferred
  method. [https://github.com/drapergem/draper/commit/1e84fcb4a0eab0d12f5feda6886ce1caa239cb16](https://github.com/drapergem/draper/commit/1e84fcb4a0eab0d12f5feda6886ce1caa239cb16)
* `ActiveModel::Serialization` is included in Decorators if you've requred
  `ActiveModel::Serializers`, so that decorators can be serialized. [https://github.com/drapergem/draper/commit/c4b352799067506849abcbf14963ea36abda301c](https://github.com/drapergem/draper/commit/c4b352799067506849abcbf14963ea36abda301c)
* Properly support Test::Unit [https://github.com/drapergem/draper/commit/087e134ed0885ec11325ffabe8ab2bebef77a33a](https://github.com/drapergem/draper/commit/087e134ed0885ec11325ffabe8ab2bebef77a33a)

And many small bug fixes and refactorings.

Before the actual release of 1.0.0, I want to improve documentation and handle
a few other things, but we currently have no confirmed and one possible bug
in Draper as it stands, so your feedback as I clean up these last few things
would be excellent. Please file issues on the tracker if you find anything.

Thank you! <3 <3 <3
  
