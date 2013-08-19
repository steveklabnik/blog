---
title: "How to squash commits in a GitHub pull request"
date: 2012-11-08 23:13
---

So you've contributed some code to an open source project, say, Rails. And
they'd like you to squash all of the commits in your pull request. But you're
not a git wizard; how do you make this happen?

Normally, you'd do something like this. I'm assuming `upstream` is a git remote
that is pointing at the official project repository, and that your changes are
in your 'omgpull' branch:

```
$ git fetch upstream
$ git checkout omgpull 
$ git rebase -i upstream/master

< choose squash for all of your commits, except the first one >
< Edit the commit message to make sense, and describe all your changes >

$ git push origin omgpull -f
```

GitHub will then automatically update your pull request with the new commits.
Super easy!
