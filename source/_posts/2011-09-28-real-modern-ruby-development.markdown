---
layout: post
title: "(Real) Modern Ruby Development"
date: 2011-09-28 06:31
comments: true
categories:
---

I came across a blog post the other day titled [Modern Ruby Development](http://ascarter.net/2011/09/25/modern-ruby-development.html).
While it's a perfectly fine blog post (other than the digs at rvm...) it really
should have been titled something more along the lines of "My default tooling
to build a Rails application." I thought of this yesterday, as I was invited
to show up at [Vertigo](http://www.vertigo.com/) and show them how we do things
in the Open Source world. Vertigo builds lots of cool things, but they tend to
be very .NET centric, and it was neat for both of us to see how the other half
lives.

Shortly before my 'presentation,' we decided that I'd basicaly just build a
little web app in front of them. Live coding to the max! We decided for maximum
awesome, and since I was in town for the Twilio conference, that I'd make a
Twilio app that they could text and it'd text you 'hello world: you said #{msg}"
back. I thought I'd share that process with you, too. I ended up throwing away
the code, though, because I committed my account credentials into the git repo
to simplify things, so I'll just be describing it to you. Check my other posts
for code stuff. ;)

## rvm --rvmrc --create 1.9.2@hello\_text

First up: decide what Ruby you're using. I talked breifly about MRI, Rubinius,
and JRuby, and some pros and cons for each. I still tend to use MRI for my
production code at the moment, but soon, rbx will become my default.

I use rvm because it does exactly what I want.

## mvim README.md

I really enjoy [README driven development](http://tom.preston-werner.com/2010/08/23/readme-driven-development.html).
I didn't actually demo this due to time constraints, but I generally write at
least a minimal README.md before doing anything else. During Windy City Rails,
Tom shared something that he likes doing: `mv README.md SPEC.md`. That way,
you can keep your actual README in sync with what the code does right now, but
have the final one that you want to work towards too.

## git push origin

Now that we have a file, we can push it up to GitHub. A few clicks on the web,
a `git add remote` and `git push -u origin master` and we're off to the races.

## mvim Gemfile && bundle

Next up we talked about Bundler, Gemfiles, and managing gems. I talked about
the ability to run your own private gem server for internal gems, and how
easy it is to build and publish a gem.

## mkdir spec

I then generally type this. I would be lying to you if I told you that I do TDD
100% of the time. Sometimes, I get lazy. But I try to. And since testing is such
a huge part of Ruby culture, and we have world-class testing tools, this is
where I started.

I wrote specs for a model class called SmsGateway. This class would handle
sending a message to a phone via Twilio. I was able to show off rspec, talk
about DSLs, mocking, and TDD.

## mvim something.rb

In this case it's sms\_gateway.rb, but you know what I mean. Write some code,
`rspec spec/sms_gateway_spec.rb`, repeat. Red, Green, Refactor. Wheee!

## mvim .travis.yml

I wanted to show Travis off, so in my demo I did this before implementing the
gateway class, but normally I'd do this after the first spec passes.
Continuous Integration and even Continuous Deployment are awesome. Travis
makes it super easy.

## Sign up for external services

I went over to Twilio's site, registered a new account, and got my credentials.
I used their docs to figure out where to put them, and how to get it all going
inside my gateway class (I just mocked it out before), and talked about how
needing to Google for docs is a weakness of Ruby.

## heroku create && git push heroku master

Then I showed them how to get going with Heroku, and how easy it was to start
giving them hundreds of dollars per month when you need to scale. .NET people
are used to paying for everything. ;)

I also showed off one of my latest projects, which is an IRC bot that lets me
deploy rstat.us into production. I have some serious Hubot envy. :D

## ... repeat!

I'd be lying if I said it worked the first time, I accidentally made a loop
where the app texted itself. Whoops! But that was cool, and showing off my
debugging process (I'm a `puts/throw params` debugger) was fun, as well. After
realizing what I did wrong, we had the app working.

## It's not quite perfect

This dev process isn't perfect yet. Nothing ever is. I'm always trying to
improve upon it, but I'm pretty happy with how quickly I'm able to turn out
new projects with a reasonable amount of quality. What's your workflow? How
does mine suck? [Email me](mailto:steve@steveklabnik.com), I'd love to hear
about it.
