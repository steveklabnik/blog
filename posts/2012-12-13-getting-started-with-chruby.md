---
title: "Getting started with chruby"
date: 2012-12-13 09:13
---

If you're looking for crazy simplicity in your 'switch between multiple Rubies'
life, you may want to check out [chruby](https://github.com/postmodern/chruby).
Written by Postmodern, it's basically the simplest possible thing that can
work. As in, [76 lines of shell
script](https://github.com/postmodern/chruby/blob/master/share/chruby/chruby.sh).

For that, you get:

### Features

* Updates `$PATH`.
  * Also adds RubyGems `bin/` directories to `$PATH`.
* Correctly sets `$GEM_HOME` and `$GEM_PATH`.
  * Users: gems are installed into `~/.gem/$ruby/$version`.
  * Root: gems are installed directly into `/path/to/$ruby/$gemdir`.
* Additionally sets `$RUBY`, `$RUBY_ENGINE`, `$RUBY_VERSION` and `$GEM_ROOT`.
* Optionally sets `$RUBYOPT` if second argument is given.
* Calls `hash -r` to clear the command-lookup hash-table.
* Fuzzy matching of Rubies by name.
* Defaults to the system Ruby.
* Supports [bash] and [zsh].
* Small (~80 LOC).
* Has tests.

### Anti-Features

* Does not hook `cd`.
* Does not install executable shims.
* Does not require Rubies be installed into your home directory.
* Does not automatically switch Rubies upon login or when changing directories.
* Does not require write-access to the Ruby directory in order to install gems.

Kinda crazy, eh?

## Installing

Most of the time, I install things from `homebrew`, but I actually prefered
to run the `setup.sh` script:

```
wget https://github.com/downloads/postmodern/chruby/chruby-0.2.3.tar.gz
tar -xzvf chruby-0.2.3.tar.gz
cd chruby-0.2.3/
./scripts/setup.sh
```

You can see the source for that script
[here](https://github.com/postmodern/chruby/blob/master/scripts/setup.sh).
You'll end up with an MRI, JRuby, and Rubinius all installed in `/opt/rubies`,
and after restarting your shell, you should be good to go!

## Usage

To see what Rubies you've got, just `chruby`:

```
$ chruby
   ruby-1.9.3-p327
   jruby-1.7.0
   rubinius-2.0.0-rc1
```

to pick one:

```
$ chruby 1.9.3
```

Pretty damn simple.

## Getting more Rubies?

The setup script will install [ruby-build](https://github.com/sstephenson/ruby-build#readme), so just use that to get more rubies:

```
ruby-build 1.9.3-p327 /opt/rubies/ruby-1.9.3-p327
```

You'll then need to update your list of Rubies in your `.bashrc` or `.zshrc`:

```
RUBIES=(
  # other rubies here
  /opt/rubies/ruby-1.9.3-p327
)
```

If you find this tedius, you can just glob them:

```
RUBIES=(/opt/rubies/*)
```

## Automatic switching?

[Not yet](https://github.com/postmodern/chruby/issues/40). This is pretty much
the only thing keeping me from saying 'zomg use this for sure now.'

## How good is it?

I don't know, I've been using it for less than 24 hours. Seems good.
