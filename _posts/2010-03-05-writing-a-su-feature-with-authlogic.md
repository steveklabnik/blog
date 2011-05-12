---
published: true
title: Writing a "su" feature with Authlogic
layout: post
---

Sometimes, when responding to a support request, it's nice to see what your
users see. At the same time, you don't want to ask your users for their
passwords, out of respect for their privacy. So what do you do?

Well, *NIX systems have a program called su.  Here's what man su has to say:

> NAME
>        su - run a shell with substitute user and group IDs
>
> SYNOPSIS
>        su [OPTION]... [-] [USER [ARG]...]
>
> DESCRIPTION
>        Change the effective user id and group id to that of USER.


su can be thought of as "substitute user" or "switch user." It's a command
system administrators use to assume the identity of one of their users, or a
way for someone with the root password on the system to switch to the root
account itself. So how can we incorporate this into a web application?


Well, we want to first log ourselves out, and then log in as the user we're
su-ing to. That's it. The tricky part, however, comes in when we're logging
in: as we said before, we don't want to ask for their password. Luckily,
Authlogic provides a way to create our UserSession object directly from a User
object by just passing it to create.


This lets us write a controller method to do this pretty easily:


>   def su
>     @user = User.find params[:id]
>     current_user_session.destroy
>     UserSession.create!(@user)
>     flash[:notice] = "You've been su-d to that user."
>     redirect_to dashboard_path
>   end

Add in a route:

> map.admin_su "/admin/su/:id", :controller => "admin", :action => "su"

And to a view somewhere in your administrative tools:

> <%= link_to "log in as this user", admin_su_path(@user) %>

And we're good to go!

One last thing about this, though: You don't want to let anyone who's not an
administrator do this, for obvious reasons. My administrative controllers
always include a block like this:

>   access_control do
>     allow :admin
>   end

acl9 makes this really easy, but it's really important.

So there you have it. Easy as pie.

EDIT: This post made the Rails subreddit, and [brettbender posted his code][1]
to get you back to admin. Here it is:


> I used this article to help build a su feature for a rails app I'm working
on. thought I would share the code to let you su / exit-su back to the
original user you were logged in as. You just need to add a link somewhere
persistent if your session contains an entry for :su_user that links to the
unsu action.
> 
> Inside your admin controller, make sure you limit access to these actions:
> 
>     def su
>       @user = User.find params[:id]
> 
>       # change these 3 lines to apply to your session representation
>       session[:su_user] = self.current_user.id
>       self.current_user = @user
> 
>       flash[:notice] = "You've been logged in as #{@user.login}."
>       redirect_to "/"
>     end
> 
>     def unsu
>       redirect_url = "/"
>       if(session.has_key?(:su_user))
>         self.current_user = User.find session[:su_user]
>         session.delete :su_user
>         flash[:notice] = "You have exited your switch user session. You are
>         redirect_url = "/admin/users/"
>       else
>         flash[:error] = "Sorry, we couldn't find your original user."
>       end
> 
>       redirect_to redirect_url
>     end

   [1]: http://www.reddit.com/r/rails/comments/cb0da/writing_a_su_feature_with_authlogic/c0rf26w

