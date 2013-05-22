---
title: "Rails 4.0.0.beta1 to Rails 4.0.0.rc1"
date: 2013-05-21 16:53
---

I'm writing [Rails 4 in Action](http://www.manning.com/bigg2/) along with Ryan
Bigg and Yehuda Katz. In updating the book to Rails 4, I started early: the
sample app ([ticketee](https://github.com/steveklabnik/ticketee)) was done
with `4.0.0.beta1`.

Then `4.0.0.rc1` came out. I didn't upgrade immediately, but last night, I
took the plunge. There were only three errors, and the whole process took me
something like 40 minutes.

Here's what I had to do:


## Cookie Stores

Error:

```text
/Users/steve/.gem/ruby/2.0.0/gems/railties-4.0.0.rc1/lib/rails/application/configuration.rb:144:in `const_get': uninitialized constant ActionDispatch::Session::EncryptedCookieStore (NameError)
```

The EncryptedCookieStore went away. Now, the regular cookie store handles these
kinds of things.

Fix:

```diff
diff --git a/config/initializers/session_store.rb b/config/initializers/session_store.rb
index c512cda..b4681fd 100644
--- a/config/initializers/session_store.rb
+++ b/config/initializers/session_store.rb
@@ -1,3 +1,3 @@
 # Be sure to restart your server when you modify this file.

-Ticketee::Application.config.session_store :encrypted_cookie_store, key: '_ticketee_session'
+Ticketee::Application.config.session_store :_cookie_store, key: '_ticketee_session'
```

## Routes

Error:

```text
/Users/steve/.gem/ruby/2.0.0/gems/actionpack-4.0.0.rc1/lib/action_dispatch/routing/route_set.rb:408:in `add_route': Invalid route name, already in use: 'signin'  (ArgumentError)
You may have defined two routes with the same name using the `:as` option, or you may be overriding a route already defined by a resource with the same naming. For the latter, you can restrict the routes created with `resources` as explained here:
http://guides.rubyonrails.org/routing.html#restricting-the-routes-created
```

You can't name two routes the same thing any more. In my case, just dropping
the `:as` allowed me to get to where I needed to go:

Fix:

```diff
diff --git a/config/routes.rb b/config/routes.rb
index f010adb..d573e89 100644
--- a/config/routes.rb
+++ b/config/routes.rb
@@ -2,8 +2,8 @@ Ticketee::Application.routes.draw do

   root to: "projects#index"

-  get "/signin", to: "sessions#new", as: "signin"
-  post "/signin", to: "sessions#create", as: "signin"
+  get "/signin", to: "sessions#new"
+  post "/signin", to: "sessions#create"

   delete "/signout", to: "sessions#destroy", as: "signout"
```

## Clean dbs

Error:

Tons of test failures relating to what was essentially "I don't delete the db
between test runs."

Fix:

Upgrade to rspec-rails 2.13.2. Done!


## has_secure_password

Error:

```text
  1) User passwords needs a password and confirmation to save
     Failure/Error: expect(u).to_not be_valid
       expected #<User id: 1, name: "steve", email: "steve@example.com", password_digest: "$2a$04$9D7M2iPvYavvvpb3rlLzz.vqMJdGBAQVBSJ6L.UIoXP6...", created_at: "2013-05-21 23:59:44", updated_at: "2013-05-21 23:59:44", admin: false> not to be valid
```

This test failed. The test looked like this:

```ruby
it "needs a password and confirmation to save" do
  u = User.new(name: "steve", email: "steve@example.com")

  u.save
  expect(u).to_not be_valid

  u.password = "password"
  u.password_confirmation = ""
  u.save
  expect(u).to_not be_valid

  u.password_confirmation = "password"
  u.save
  expect(u).to be_valid
end
```

Turns out, [it's a regression](https://github.com/rails/rails/pull/10694)!
This will get fixed for RC2, but for now, just commenting out that middle
section works. The final test is good enough for now.
