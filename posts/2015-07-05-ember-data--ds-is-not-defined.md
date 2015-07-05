---
title: "Ember Data: DS is not defined"
date: 2015-07-05 14:45
---

I’m doing a little Ember app, and if there’s one thing I’ve learned from
writing software, it’s to blog about error messages. Two-years-later me has
ended up finding my own posts when searching for help!

So today, when getting started with Ember Data 1.13, I was trying to use the
new `JSONAPIAdapter`. I saw this code snippet:

```
App.ApplicationAdapter = DS.JSONAPIAdapter.extend({
    namespace: 'v1',
});
```

Using that gave me an error when `ember serve`-ing, though:

```
app.js: line 16, col 26, ‘DS’ is not defined.
```

Turns out, `DS` isn’t in scope by default, even though `ember-cli` installs
Ember Data by default.

Fixing this just means importing it at the top of `app/app.js`:

```
import DS from 'ember-data';
```

Easy enough!
