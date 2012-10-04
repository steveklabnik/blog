---
title: "Run Rails with custom patches"
date: 2012-10-04 04:47
---

I often see comments [like this](https://github.com/rails/rails/pull/7397#issuecomment-9132009)
in the Rails bugtracker. Generally, someone is running an older version of
Rails, and some bug they face has been fixed on edge. But they may be running
a version that's too old to recieve fixes, or need a fix that has yet to be
included in an actual release. What to do?

Luckily, [Bundler](http://gembundler.com/) exists. It makes it super easy to
run your own Rails. Check it out:

## Step 1: Fork you!

Go to GitHub, hit up [rails/rails](http://github.com/rails/rails), and click
that fork button. My own personal fork of Rails is
[here](https://github.com/steveklabnik/rails), for example, so in the rest of
these examples, I'll be using my own username. If you're me, you can use it
too, but seriously, stop being me. If you're not me, substitute your own
username.

## Step 2: apply patch

Let's get our copy going locally:

```
$ git clone git@github.com:steveklabnik/rails.git
$ cd rails
```

We'll apply the patch from the example comment above. In this case, the person
wants to have this patch work on Rails 3.1.

You have two options here: Rails keeps a branch open for every minor version,
and also tags every release. You can pick between the stable branch and a
particular release. The stable branch should work just fine, but maybe you're
on a specific Rails release for a reason. For example, the latest version of
Rails 3.1 is 3.1.8, but this person says they're on 3.1.1. If they use the
3-1-stable branch, they'll also get all the changes from 3.1.1-3.1.8, as well
as unreleased changes that may exist on that branch. That's possibly too much
for you, so we'll just work off of 3.1.1. This is probably a bad idea, since
[3.1.6 included several security
fixes](http://weblog.rubyonrails.org/2012/6/12/ann-rails-3-1-6-has-been-released/),
but you're an adult, do dumb things if you want to.

```
$ git checkout v3.1.1
```

You'll see a big message about a detached HEAD. Don't worry about it.

If you want the stable branch for extra fixes,

```
$ git checkout 3-1-stable
```

Now, it's a good idea to make our own branches, so that we don't get confused
with upstream. So let's make a new branch:

```
$ git checkout -b my_patched_rails
```

Awesome. Now, we can grab the commit we wanted. We can do this with
`cherry-pick`:

```
$ git cherry-pick 8fc8763fde2cc685ed63fcf640cfae556252809b
```

I found this SHA1 by checking out [this
page](https://github.com/rails/rails/pull/7397/commits), which is linked at the
top of the pull request.

If there are multiple commits you need, you can do one of two things: either
`cherry-pick` the merge commit, in which case you'll probably need to pass
the `-m1` option, or simply `cherry-pick` them all in order.

You may get conflicts. Yay backporting! If `git` whines at you, do what you
normally do. Resolve the merge, then `git commit`.

Finally, push it back up to your GitHub:

```
$ git push origin my_patched_rails
```

Congrats! You've got your own custom Rails. Now it's time to use it.

## Step 3: update Gemfile

Go to your Rails app, and edit this line in your Gemfile:

```
gem 'rails', "3.1.1"
```

change it to this:

```
gem 'rails', :git => "https://github.com/steveklabnik/rails", :branch => "my_patched_rails"
```

It's that easy! Now bundle:

```
$ bundle update
```

You should see it mention something about checking out a certain copy of Rails.

## Step 4: Profit!

That's it! Congrats, you're using Rails with your patch.

## But I'm on 2.3, I'm not running Bundler!

[Do this](http://gembundler.com/v0.9/rails23.html).
