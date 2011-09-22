---
layout: post
title: "Extracting Domain Models: A Practical Example"
date: 2011-09-22 10:25
comments: true
categories:
---

Hey everyone! We've been doing a lot of refactoring on rstat.us lately, and I
wanted to share with you a refactoring that I did. It's a real-world example
of doing the domain models concept that I've been talking about lately.

## Step one: check the tests

> I don't know how much more emphasized step 1 of refactoring could be: don't touch anything that doesn't have coverage. Otherwise, you're not refactoring; you're just changing shit.
> - Hamlet D'Arcy

One of the best reasons to extract extra domain models is that they're often
much easier to test. They have less dependencies, less code, and are much
simpler than the Mega Models that happen if you have a 1-1 model to table
ratio.

Let's check out the code. It's in our User model:

```ruby app/models/user.rb https://github.com/hotsh/rstat.us/blob/362cb38031/app/models/user.rb#L209
# Send an update to a remote user as a Salmon notification
def send_mention_notification update_id, to_feed_id
  f = Feed.first :id => to_feed_id
  u = Update.first :id => update_id

  base_uri = "http://#{author.domain}/"
  salmon = OStatus::Salmon.new(u.to_atom(base_uri))

  envelope = salmon.to_xml self.to_rsa_keypair

  # Send envelope to Author's Salmon endpoint
  uri = URI.parse(f.author.salmon_url)
  http = Net::HTTP.new(uri.host, uri.port)
  res = http.post(uri.path, envelope, {"Content-Type" => "application/magic-envelope+xml"})
end
```

You're probably saying "this is pretty reasonable." Prepare to get shocked...

This code has very little to do with the user, other than using some of the
User's attributes. This really could be factored out into a domain object
whose job it is to push Salmon notifications. But first, let's see if we can get
some tests in place so we know _everything_ isn't broken. Examining this method,
we need two things: an `update_id` and a `feed_id`. Here's my first stab at an
integration test:

```ruby test/models/notify_via_salmon_test.rb
describe "salmon update" do
  it "integration regression test" do
    feed = Feed.create
    update = Update.create

    salmon = double(:to_xml => "<xml></xml>")
    uri = double(:host => "localhost", :port => "9001", :path => "/")
    Ostatus::Salmon.should_receive(:new).and_return(salmon)
    Uri.should_receive(:parse).and_return(uri)
    Net::HTTP.should_receive(:new).and_return(mock(:post => true))

    user = User.create
    user.send_mention_notification(update.id, feed.id)
  end
end
```

This is an integration test, we're obviously testing stuff with a ton of models.
After running `ruby test/models/notify_via_salmon.rb` about a zillion times, I
ended up with this running test:

```ruby test/models/notify_via_salmon.rb
require 'minitest/autorun'
require 'rspec/mocks'

require 'mongo_mapper'
require 'whatlanguage'
MongoMapper.connection = Mongo::Connection.new("localhost")
MongoMapper.database = 'rstatus-test'

require_relative '../../app/models/feed'
require_relative '../../app/models/update'
require_relative '../../app/models/author'
require_relative '../../app/models/authorization'

$:.unshift("lib")
require_relative '../../app/models/user'

require 'ostatus'

describe "salmon update" do
  before :each do
    User.all.each(&:destroy)
    RSpec::Mocks::setup(self)
  end

  it "integration regression test" do
    author = Author.create
    user = User.create!(:username => "steve", :author => author)

    feed = user.feed
    update = Update.create!(:feed_id => feed.id, :author_id => author.id, :text => "hello world")

    salmon = double(:to_xml => "<xml></xml>")
    uri = double(:host => "localhost", :port => "9001", :path => "/")
    OStatus::Salmon.should_receive(:new).and_return(salmon)
    URI.should_receive(:parse).and_return(uri)
    Net::HTTP.should_receive(:new).and_return(mock(:post => true))

    user.send_mention_notification(update.id, feed.id)
  end
end
```

Holy. Fuck. Seriously. Let me just quote [Avdi Grimm](http://avdi.org):

{% blockquote Avdi Grimm, http://avdi.org/devblog/2011/04/07/rspec-is-for-the-literate/ "Rspec is for the Literate" %}
Mocks, and to some degree RSpec, are like the Hydrogen Peroxide of programming: they fizz up where they encounter subtle technical debt.
{% endblockquote %}

This test class is insane. It runs faster than many people's integration tests,
clocking in at about 0.4 seconds. But that's still an order of magnitude faster
than I'd like. A suite with 200 tests would still take over a minute. Also, look
at all this junk that we have to do for setup.

All of this pain and effort doesn't mean that testing sucks: it means that our
implementation is terrible. So let's use that to guide us. We'll try to fix this
code by eliminating all of this junk.

## Step two: simple extraction

First, let's extract this out to a domain model. Here's the new code:

```ruby app/models/user.rb
# Send an update to a remote user as a Salmon notification
def send_mention_notification update_id, to_feed_id
  NotifyViaSalmon.mention(update_id, to_feed_id)
end
```

```ruby app/models/notify_via_salmon.rb
module NotifyViaSalmon
  extend self

  def mention(update_id, to_feed_id)
    f = Feed.first :id => to_feed_id
    u = Update.first :id => update_id

    base_uri = "http://#{author.domain}/"
    salmon = OStatus::Salmon.new(u.to_atom(base_uri))

    envelope = salmon.to_xml self.to_rsa_keypair

    # Send envelope to Author's Salmon endpoint
    uri = URI.parse(f.author.salmon_url)
    http = Net::HTTP.new(uri.host, uri.port)
    res = http.post(uri.path, envelope, {"Content-Type" => "application/magic-envelope+xml"})
  end
end
```

Now, when we run the test (via `ruby test/models/notify_via_salmon_test.rb`) we
see an error:

```
1) Error:
test_0001_integration_regression_test(SalmonUpdateSpec):
NameError: undefined local variable or method `author' for NotifyViaSalmon:Module
    /Users/steveklabnik/src/rstat.us/app/models/notify_via_salmon.rb:8:in `mention'
```

This is a form of Lean On The Compiler. This test is now failing because it's
relying on stuff that used to be internal to the User, and we don't have that
stuff now. After doing this a few times, we're left with this:

```ruby app/models/user.rb
# Send an update to a remote user as a Salmon notification
def send_mention_notification update_id, to_feed_id
  NotifyViaSalmon.mention(self, update_id, to_feed_id)
end
```

```ruby app/models/notify_via_salmon.rb
module NotifyViaSalmon
  extend self

  def mention(user, update_id, to_feed_id)
    f = Feed.first :id => to_feed_id
    u = Update.first :id => update_id

    base_uri = "http://#{user.author.domain}/"
    salmon = OStatus::Salmon.new(u.to_atom(base_uri))

    envelope = salmon.to_xml user.to_rsa_keypair

    # Send envelope to Author's Salmon endpoint
    uri = URI.parse(f.author.salmon_url)
    http = Net::HTTP.new(uri.host, uri.port)
    res = http.post(uri.path, envelope, {"Content-Type" => "application/magic-envelope+xml"})
  end
end
```

Okay. Now we're cooking. We have a test that's isolated, yet still does what we
thought it did before.

## Step three: break dependencies

Next step: let's break the hard dependency this method has on both Feed and
Update. We can do this by moving the finds up into the User method instead of
keeping them in the mention method:

```ruby app/models/user.rb
# Send an update to a remote user as a Salmon notification
def send_mention_notification update_id, to_feed_id
  feed = Feed.first :id => to_feed_id
  update = Update.first :id => update_id

  NotifyViaSalmon.mention(self, update, feed)
end
```

```ruby app/models/notify_via_salmon.rb
module NotifyViaSalmon
  extend self

  def mention(user, update, feed)
    base_uri = "http://#{user.author.domain}/"
    salmon = OStatus::Salmon.new(update.to_atom(base_uri))

    envelope = salmon.to_xml user.to_rsa_keypair

    # Send envelope to Author's Salmon endpoint
    uri = URI.parse(feed.author.salmon_url)
    http = Net::HTTP.new(uri.host, uri.port)
    res = http.post(uri.path, envelope, {"Content-Type" => "application/magic-envelope+xml"})
  end
end
```

Okay. Tests passing. Sweet. Now we can try testing _just_ the mention method.
Let's try it by killing most of that crap that was in our test:

```ruby test/models/notify_via_salmon_test.rb
require 'minitest/autorun'
require 'rspec/mocks'

require_relative '../../app/models/notify_via_salmon'

describe "salmon update" do
  before :each do
    RSpec::Mocks::setup(self)
  end

  it "integration regression test" do
    NotifyViaSalmon.mention(stub, stub, stub)
  end
end
```

Let's try running this and seeing what happens:

```
$ ruby test/models/notify_via_salmon_test.rb
Loaded suite test/models/notify_via_salmon_test
Started
E
Finished in 0.000992 seconds.

  1) Error:
test_0001_integration_regression_test(SalmonUpdateSpec):
RSpec::Mocks::MockExpectationError: Stub received unexpected message :author with (no args)
```

First of all, daaaaamn. 0.001 seconds. Nice. Secondly, okay, we are getting some
messages sent to our stubs. Let's flesh them out to make things pass:

```ruby test/models/notify_via_salmon_test.rb
require 'minitest/autorun'
require 'rspec/mocks'
require 'ostatus'

require_relative '../../app/models/notify_via_salmon'

describe "salmon update" do
  before :each do
    RSpec::Mocks::setup(self)
  end

  it "integration regression test" do
    user = stub(:author => stub(:domain => "foo"), :to_rsa_keypair => stub)
    update = stub(:to_atom => "")
    feed = stub(:author => stub(:salmon_url => ""))

    salmon = stub(:to_xml => "")
    OStatus::Salmon.should_receive(:new).and_return(salmon)

    uri = stub(:host => "", :port => "", :path => "")
    URI.should_receive(:parse).and_return(uri)
    Net::HTTP.should_receive(:new).and_return(stub(:post => ""))

    NotifyViaSalmon.mention(user, update, feed)
  end
end
```

Okay! Note how similar this looks to the previous test. We're still mocking a
bunch of 'external' stuff. But other than that, our test is pretty simple: we
make three stubs, and we call our mention method.

### Step four: repeat

We could do some more work on this method. There are a few things that are
a bit smelly: the nested stub of User is not great. The fact that we're stubbing
out three external dependencies isn't great. But before we get to that, let's
check out another method that looks similar:
`send_{follow,unfollow}_notification`. Here's some code:

```ruby app/models/user.rb https://github.com/hotsh/rstat.us/blob/362cb38031/app/models/user.rb#L167
# Send Salmon notification so that the remote user
# knows this user is following them
def send_follow_notification to_feed_id
  f = Feed.first :id => to_feed_id

  salmon = OStatus::Salmon.from_follow(author.to_atom, f.author.to_atom)

  envelope = salmon.to_xml self.to_rsa_keypair

  # Send envelope to Author's Salmon endpoint
  uri = URI.parse(f.author.salmon_url)
  http = Net::HTTP.new(uri.host, uri.port)
  res = http.post(uri.path, envelope, {"Content-Type" => "application/magic-envelope+xml"})
end

# Send Salmon notification so that the remote user
# knows this user has stopped following them
def send_unfollow_notification to_feed_id
  f = Feed.first :id => to_feed_id

  salmon = OStatus::Salmon.from_unfollow(author.to_atom, f.author.to_atom)

  envelope = salmon.to_xml self.to_rsa_keypair

  # Send envelope to Author's Salmon endpoint
  uri = URI.parse(f.author.salmon_url)
  http = Net::HTTP.new(uri.host, uri.port)
  res = http.post(uri.path, envelope, {"Content-Type" => "application/magic-envelope+xml"})
end
```

Look familliar? Yep! 90% the same code! We'll do the same process to these
methods, just like the other one. Check out this code and test:

```ruby app/models/user.rb
# Send Salmon notification so that the remote user
# knows this user is following them
def send_follow_notification to_feed_id
  feed = Feed.first :id => to_feed_id

  NotifyViaSalmon.follow(self, feed)
end

# Send Salmon notification so that the remote user
# knows this user has stopped following them
def send_unfollow_notification to_feed_id
  feed = Feed.first :id => to_feed_id

  NotifyViaSalmon.unfollow(self, feed)
end

# Send an update to a remote user as a Salmon notification
def send_mention_notification update_id, to_feed_id
  feed = Feed.first :id => to_feed_id
  update = Update.first :id => update_id

  NotifyViaSalmon.mention(self, update, feed)
end
```

```ruby app/models/notify_via_salmon.rb
module NotifyViaSalmon
  extend self

  def mention(user, update, feed)
    base_uri = "http://#{user.author.domain}/"
    salmon = OStatus::Salmon.new(update.to_atom(base_uri))

    envelope = salmon.to_xml user.to_rsa_keypair

    # Send envelope to Author's Salmon endpoint
    uri = URI.parse(feed.author.salmon_url)
    http = Net::HTTP.new(uri.host, uri.port)
    res = http.post(uri.path, envelope, {"Content-Type" => "application/magic-envelope+xml"})
  end

  def follow(user, feed)
    salmon = OStatus::Salmon.from_follow(user.author.to_atom, feed.author.to_atom)

    envelope = salmon.to_xml user.to_rsa_keypair

    # Send envelope to Author's Salmon endpoint
    uri = URI.parse(feed.author.salmon_url)
    http = Net::HTTP.new(uri.host, uri.port)
    res = http.post(uri.path, envelope, {"Content-Type" => "application/magic-envelope+xml"})
  end

  def unfollow(user, feed)
    salmon = OStatus::Salmon.from_unfollow(user.author.to_atom, feed.author.to_atom)

    envelope = salmon.to_xml user.to_rsa_keypair

    # Send envelope to Author's Salmon endpoint
    uri = URI.parse(feed.author.salmon_url)
    http = Net::HTTP.new(uri.host, uri.port)
    res = http.post(uri.path, envelope, {"Content-Type" => "application/magic-envelope+xml"})
  end
end
```

```ruby test/models/notify_via_salmon_test.rb
require 'minitest/autorun'
require 'rspec/mocks'
require 'ostatus'

require_relative '../../app/models/notify_via_salmon'

describe NotifyViaSalmon do
  before :each do
    RSpec::Mocks::setup(self)
  end

  it ".mention" do
    user = stub(:author => stub(:domain => "foo"), :to_rsa_keypair => stub)
    update = stub(:to_atom => "")
    feed = stub(:author => stub(:salmon_url => ""))

    salmon = stub(:to_xml => "")
    OStatus::Salmon.should_receive(:new).and_return(salmon)

    uri = stub(:host => "", :port => "", :path => "")
    URI.should_receive(:parse).and_return(uri)
    Net::HTTP.should_receive(:new).and_return(stub(:post => ""))

    NotifyViaSalmon.mention(user, update, feed)
  end

  it ".follow" do
    user = stub(:author => stub(:domain => "foo", :to_atom => ""), :to_rsa_keypair => stub)
    feed = stub(:author => stub(:salmon_url => "", :to_atom => ""))

    salmon = stub(:to_xml => "")
    OStatus::Salmon.should_receive(:from_follow).and_return(salmon)

    uri = stub(:host => "", :port => "", :path => "")
    URI.should_receive(:parse).and_return(uri)
    Net::HTTP.should_receive(:new).and_return(stub(:post => ""))

    NotifyViaSalmon.follow(user, feed)
  end

  it ".unfollow" do
    user = stub(:author => stub(:domain => "foo", :to_atom => ""), :to_rsa_keypair => stub)
    feed = stub(:author => stub(:salmon_url => "", :to_atom => ""))

    salmon = stub(:to_xml => "")
    OStatus::Salmon.should_receive(:from_unfollow).and_return(salmon)

    uri = stub(:host => "", :port => "", :path => "")
    URI.should_receive(:parse).and_return(uri)
    Net::HTTP.should_receive(:new).and_return(stub(:post => ""))

    NotifyViaSalmon.unfollow(user, feed)
  end
end
```

Now we can see some of these patterns start to emerge, eh? All of this stuff is
starting to come together. Let's get rid of the URI and Net::HTTP stuff, as it's
just straight up identical in all three. Pretty basic Extract Method:

```ruby app/models/notify_via_salmon.rb
module NotifyViaSalmon
  extend self

  def mention(user, update, feed)
    base_uri = "http://#{user.author.domain}/"
    salmon = OStatus::Salmon.new(update.to_atom(base_uri))

    send_to_salmon_endpoint(salmon, user.to_rsa_keypair, feed.author.salmon_url)
  end

  def follow(user, feed)
    salmon = OStatus::Salmon.from_follow(user.author.to_atom, feed.author.to_atom)

    send_to_salmon_endpoint(salmon, user.to_rsa_keypair, feed.author.salmon_url)
  end

  def unfollow(user, feed)
    salmon = OStatus::Salmon.from_unfollow(user.author.to_atom, feed.author.to_atom)

    send_to_salmon_endpoint(salmon, user.to_rsa_keypair, feed.author.salmon_url)
  end

  protected

  def send_to_salmon_endpoint(salmon, keypair, uri)
    envelope = salmon.to_xml keypair

    # Send envelope to Author's Salmon endpoint
    uri = URI.parse(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    res = http.post(uri.path, envelope, {"Content-Type" => "application/magic-envelope+xml"})
  end
end
```

We run our tests, it still all works. Now we can just mock out the endpoint
method, and all of our tests on the individual methods become much, much simpler:

```ruby test/models/notify_via_salmon_test.rb
require 'minitest/autorun'
require 'rspec/mocks'
require 'ostatus'

require_relative '../../app/models/notify_via_salmon'

describe NotifyViaSalmon do
  before :each do
    RSpec::Mocks::setup(self)
  end

  it ".mention" do
    user = stub(:author => stub(:domain => "foo"), :to_rsa_keypair => stub)
    update = stub(:to_atom => "")
    feed = stub(:author => stub(:salmon_url => ""))

    NotifyViaSalmon.should_receive(:send_to_salmon_endpoint)

    NotifyViaSalmon.mention(user, update, feed)
  end

  it ".follow" do
    user = stub(:author => stub(:domain => "foo", :to_atom => ""), :to_rsa_keypair => stub)
    feed = stub(:author => stub(:salmon_url => "", :to_atom => ""))

    salmon = stub(:to_xml => "")
    OStatus::Salmon.should_receive(:from_follow).and_return(salmon)

    NotifyViaSalmon.should_receive(:send_to_salmon_endpoint)

    NotifyViaSalmon.follow(user, feed)
  end

  it ".unfollow" do
    user = stub(:author => stub(:domain => "foo", :to_atom => ""), :to_rsa_keypair => stub)
    feed = stub(:author => stub(:salmon_url => "", :to_atom => ""))

    salmon = stub(:to_xml => "")
    OStatus::Salmon.should_receive(:from_unfollow).and_return(salmon)

    NotifyViaSalmon.should_receive(:send_to_salmon_endpoint)

    NotifyViaSalmon.unfollow(user, feed)
  end
end
```

We've managed to get rid of all of the mocking of the URI stuff. It's all
details now. We also have great information about what is actually needed for
this test: we know exactly what our objects expect the caller to pass. We're
only depending on ourselves and some external libraries. Our tests are fast.
Overall, I'm feeling much better about this code than I was before.

## In conclusion

I hope you'll take a few things away from this post.

**Start with tests first!** If you don't do this, it's very easy to introduce
simple errors. Don't be that guy. You know, the one that has to make [pull requests like this...](https://github.com/hotsh/rstat.us/pull/398/files)
I suck.

**Don't be afraid to change the tests!** As soon as you've verified that you've
transcribed the code correctly, don't be afraid to just nuke things and start
again. Especially if you have integration level tests that confirm that your
features actually _work_, your unit tests are expendable. If they're not useful,
kill them!

**Mock like a motherfucker.** When done correctly, mocks allow you to help
design your code better, make your tests fast, and truly isolate the unit under
test. It's pretty much all upside, unless you suck at them.

**Extract, extract, extract!** Adele Goldberg once said, “In Smalltalk,
everything happens somewhere else.” Make tons of little methods. They help
to provide seams that are useful for testing. Smaller methods are also easier to
understand.

**Refactoring is a marathon.** Even with all this work, this code isn't the best.
The tests could even use a little TLC. But it's still better than it was before.
Those who ship, win. Make things a little better, `git commit && git push`, repeat.
