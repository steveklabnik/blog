---
title: "Travis build matrix for Rails"
date: 2013-03-10 14:06
---

Do you have a gem that needs to test against multiple versions of Rails? Doing
it all can be complex, and while I have lots to say about this topic, but
here's one of the pieces: Travis build matrix.

Here's what you want:

```
anguage: ruby
rvm:
  - 1.8.7
  - 1.9.2
  - 1.9.3
  - 2.0.0
  - ruby-head
env:
  - "RAILS_VERSION=3.2"
  - "RAILS_VERSION=3.1"
  - "RAILS_VERSION=3.0"
  - "RAILS_VERSION=master"
matrix:
  allow_failures:
    - rvm: ruby-head
    - env: "RAILS_VERSION=master"
  exclude:
    - rvm: 2.0.0
      env: "RAILS_VERSION=3.0"
    - rvm: 2.0.0
      env: "RAILS_VERSION=3.1"
    - rvm: 1.8.7
      env: "RAILS_VERSION=master"
    - rvm: 1.9.2
      env: "RAILS_VERSION=master"
    - rvm: ruby-head
      env: "RAILS_VERSION=3.0"
    - rvm: ruby-head
      env: "RAILS_VERSION=3.1"
```

Here's what all this does:

1. 1.8.7 and 1.9.2 is supported across all of the 3.x series, but not master
2. 2.0.0 is supported on Rails 3.2 (as of the upcoming 3.2.13, but it will
   probably work with your gem with 3.2.12) and master, but not 3.0 or 3.1.
3. We want to allow failures on ruby-head, because it's not likely to be stable
4. We also want to allow failures for Rails master, because sometimes it's not
   stable either
5. ruby-head should only be built against master


What do you think? [Tweet at me](http://twitter.com/steveklabnik) if you have
suggestions for improving this matrix.
