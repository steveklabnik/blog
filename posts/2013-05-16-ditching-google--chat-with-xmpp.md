---
title: "Ditching Google: Chat with XMPP"
date: 2013-05-16 13:30
---

Last week, I decided that it was time to migrate one of my services away from
Google: XMPP for IM. The nice thing about XMPP is that you don't have to
totally drop support for your old identity: since Google still uses it
([for now](http://eschnou.com/entry/whats-next-google--dropping-smtp-support--62-24930.html)),
you can get online with both.

Here's how:

----------------

I set mine up with [Digital Ocean](http://digitalocean.com/), because my
friends told me it was rad. It was pretty damn easy.

Once you have a server, you need to set up all the usual stuff: a
non-privledged user account, yadda, yadda. I'm assuming you can do that.

## Install ejabberd

I picked [ejabberd](http://www.ejabberd.im/) for my server software because
it's used by a lot of people.

Anyway, since I use Arch Linux, installing was as easy as

```bash
$ sudo pacman -S ejabberd
```

After that was over, time to edit the config. `ejabberd` is written in Erlang,
and so it uses Erlang for its config. Don't worry! It's easy. Just copy and 
paste these bits in, or change them if there's something like them in your
config:

```erlang
{hosts, ["localhost", "xmpp.steveklabnik.com"]}.
{acl, admin, {user, "steve", "xmpp.steveklabnik.com"}}.
```

These change my host to `xmpp.steveklabnik.com` as well as `localhost` and set my admin user to
`steve@xmpp.steveklabnik.com`.

Next up, we boot the node:

```bash
sudo ejabberdctl start
```

And then register a way to administer things via the web interface:

```
sudo ejabberdctl register steve xmpp.steveklabnik.com $password
```

Of course, change those to be your values, and change $password to your
password. Now that you've typed a password into the command line, it's good
to clean out your bash history. When I did this, typing `history` showed
this:

```bash
 35  sudo ejabberdctl register ....
```

So, do this:

```bash
$ history -d 35
$ history -w
```

Or, to nuke _everything_:

```bash
$ history -c
$ history -w
```

Anywho, now that that's over, you need to go to your domain registrar and
insert an A record pointing at your server. I use
[NameCheap](https://www.namecheap.com/).

Now that that's done, hit this page in your browser:

```text
http://xmpp.steveklabnik.com:5280/admin/
```

The trailing slash is important, and obviously, you need to change it to
be your server. Given that the DNS isn't cached wrong, you should get a popup
asking you to log in. Do so with the credentials you typed in on the command
line up there. If you can log in, great! Everything should be working.

Let's turn off registration, though. Go back to your `ejabberd` config,
`/etc/ejabberd/ejabberd.cfg`:

```erlang
{access, register, [{deny, all}]}.
```

You probably have one that says `allow`, so just change it. Check in your admin
panel on the site that it's the same.

--------------------

Bam! That's it. This whole process took me about an hour, including writing
this blog post. I do have some experience with VPSes, though.

If I can help free you of Google in any way, ping me at
[steve@xmpp.steveklabnik.com](xmpp:steve@xmpp.steveklabnik.com).
