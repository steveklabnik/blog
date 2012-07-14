---
title: "Why I don't like factory_girl"
date: 2012-07-14 13:39
---

Once upon a time, I was building my First Serious Rails App. I was drawn to
Rails in the first place because of automated testing and ActiveRecord; I felt
the pain of not using an ORM and spending about a week on every deploy making
sure that things were still okay in production. So of course, I tried to write
a pretty reasonable suite of tests for the app.

To gloss over some details to protect the innocent, this app was a marketplace:
some people owned Things, and some people wanted to place Orders. Only certain
Things could fulfill an Order, so of course, there was also a ThingType table
that handled different types of Things. Of course, some Types came in multiple
Sizes, so there also needed to be a Size Table and a ThingTypeSize table so
that a User could own a Thing of a certain Type and a certain Size.

Stating that creating my objects for tests was difficult would be an
understatement.

Then I read a blog post about FactoryGirl. Holy crap! This would basically save
me. With one simple `Factory(:thing)` I could get it to automatically build a
valid list of all that other crap that I needed!

So of course, I had to write my spec for a thing:

``` ruby
describe Order do
  it "generates quotes only from Things that are of the right size" do
    order = Factory(:order)
    thing = Factory(:thing, :size => order.size)
    thing = Factory(:thing)
    order.quote!
    order.quote.thing.should == thing
  end
end
```

This test worked. It also generated around 15 objects, saved them in the
database, and queried them back out. I don't have the code running anymore, but
it was like 30-40 queries, and took a second or two to run.

That was one test. I was trying to test a lot, even though I wasn't good at
test first yet, so my suite got to be pretty big. Also, sometimes my factories
weren't the best, so I'd spend a day wondering why certain things would start
failing. Turns out I'd defined them slightly wrong, validations started to
fail, etc.

## How did we get here?

This story is one of Ruby groupthink gone awry, basically. Of course, we know
that fixtures get complicated. They get complicated because we have these crazy
ActiveRecord models, don't use plain Ruby classes when appropriate, and
validations make us make extra objects just to get tests to pass. Then fixtures
get out of date. So let's introduce a pattern!

Of course, since we know that Factories are really useful when things get
complicated, let's make sure to use them from the start, so we don't have to
worry about them later. Everyone started doing this. Here's how new Rails apps
get started:

``` plain
steve at thoth in ~/tmp
$ rails new my_app
      create  
      create  README.rdoc
<snip>
      create  vendor/plugins/.gitkeep
         run  bundle install
Fetching gem metadata from https://rubygems.org/.........
<snip>
Using uglifier (1.2.6) 
Your bundle is complete! Use `bundle show [gemname]` to see where a bundled gem is installed.

steve at thoth in ~/tmp
$ cd my_app 

steve at thoth in ~/tmp/my_app
$ cat >> Gemfile
gem "rspec-rails"
gem "factory_girl_rails"
^D

steve at thoth in ~/tmp/my_app
$ bundle
Fetching gem metadata from https://rubygems.org/........
<snip>
steve at thoth in ~/tmp/my_app
steve at thoth in ~/tmp/my_app
$ rails g rspec:install                                                   
      create  .rspec
       exist  spec
      create  spec/spec_helper.rb

$ rails g resource foo
      invoke  active_record
      create    db/migrate/20120714180554_create_foos.rb
      create    app/models/foo.rb
      invoke    rspec
      create      spec/models/foo_spec.rb
      invoke      factory_girl
      create        spec/factories/foos.rb
      invoke  controller
      create    app/controllers/foos_controller.rb
      invoke    erb
      create      app/views/foos
      invoke    rspec
      create      spec/controllers/foos_controller_spec.rb
      invoke    helper
      create      app/helpers/foos_helper.rb
      invoke      rspec
      create        spec/helpers/foos_helper_spec.rb
      invoke    assets
      invoke      coffee
      create        app/assets/javascripts/foos.js.coffee
      invoke      scss
      create        app/assets/stylesheets/foos.css.scss
      invoke  resource_route
       route    resources :foos

steve at thoth in ~/tmp/my_app
$ rake db:migrate                                                         
==  CreateFoos: migrating =====================================================
-- create_table(:foos)
   -> 0.0065s
==  CreateFoos: migrated (0.0066s) ============================================

$ cat > spec/models/foo_spec.rb
require 'spec_helper'

describe Foo do
  it "does something" do
    foo = Factory(:foo)
    foo.something!
  end
end
^D

$ bundle exec rake spec       
/Users/steve/.rvm/rubies/ruby-1.9.3-p194/bin/ruby -S rspec ./spec/controllers/foos_controller_spec.rb ./spec/helpers/foos_helper_spec.rb ./spec/models/foo_spec.rb
*DEPRECATION WARNING: Factory(:name) is deprecated; use FactoryGirl.create(:name) instead. (called from block (2 levels) in <top (required)> at /Users/steve/tmp/my_app/spec/models/foo_spec.rb:5)
F

Pending:
  FoosHelper add some examples to (or delete) /Users/steve/tmp/my_app/spec/helpers/foos_helper_spec.rb
    # No reason given
    # ./spec/helpers/foos_helper_spec.rb:14

Failures:

  1) Foo does something
     Failure/Error: foo.something!
     NoMethodError:
       undefined method `something!' for #<Foo:0x007f82c70c07a0>
     # ./spec/models/foo_spec.rb:6:in `block (2 levels) in <top (required)>'

Finished in 0.01879 seconds
2 examples, 1 failure, 1 pending

Failed examples:

rspec ./spec/models/foo_spec.rb:4 # Foo does something

Randomized with seed 27300

rake aborted!
/Users/steve/.rvm/rubies/ruby-1.9.3-p194/bin/ruby -S rspec ./spec/controllers/foos_controller_spec.rb ./spec/helpers/foos_helper_spec.rb ./spec/models/foo_spec.rb failed

Tasks: TOP => spec
(See full trace by running task with --trace)
```

Woo! Failing test! Super easy. But what about that test time?

```
Finished in 0.01879 seconds
```

Now, test time isn't everything, but a hundredth of a second. Once we hit a
hundred tests, we'll be taking almost two full seconds to run our tests.

What if we just `Foo.new.something!`?

```
Finished in 0.00862 seconds
```

A whole hundredth of a second faster. A hundred tests now take one second
rather than two.

Of course, once you add more complicated stuff to your factories, your test
time goes up. Add a validation that requires an associated model? Now that test
runs twice as slow. You didn't change the test at all! But it got more
expensive.

Now, a few years in, we have these massive, gross, huge, long-running test
suites.

## What to do?

Now, I don't think that test times are the end-all-be-all of everything. I
really enjoyed [this post](http://gmoeck.github.com/2012/07/09/dont-make-your-code-more-testable.html)
that floated through the web the other day. I think that the 'fast tests
movement' or whatever (which I am/was a part of) was a branding mistake. The
real point wasn't about fast tests. Fast tests are really nice! But that's
not a strong enough argument alone.

The point is that we forgot what testing is supposed to help in the first
place.

## Back to basics: TDD

A big feature of tests is to give you feedback on your code. Tests and code
have a symbiotic relationship. Your tests inform your code. If a test is 
complicated, your code is complicated. Ultimately, because tests are a client
of your code, you can see how easy or hard your code's interfaces are.

So, we have a pain in our interface: our objects need several other ones to
exist properly. How do we fix that pain?

The answer that the Rails community has taken for the last few years is 'sweep
it under the rug with factories!' And that's why we're in the state we're in.
One of the reasons that this happened was that FactoryGirl is a pretty damn
good implementation of Factories. I do use FactoryGirl (or sometimes
Fabrication) in my request specs; once you're spinning up the whole stack,
factories can be really useful. But they're not useful for actual unit tests.
Which I guess is another way to state what I'm saying: we have abandoned
unit tests, and now we're paying the price.

So that's what it really boils down to: the convenience of factories has set
Rails testing strategies and software design back two years.

You live and learn.
