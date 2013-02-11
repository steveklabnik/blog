---
title: "Ruby on Rails maintenance policy"
date: 2013-02-11 11:56
---

Recently, the Rails team has committed to a specific policy related to release
maintenance. Due to the rapid pace of recent releases, it's good to understand
how your apps relate to this policy.

The policy was originally posted on Google Groups, here: [https://groups.google.com/forum/?fromgroups=#!topic/rubyonrails-security/G4TTUDDYbNA](https://groups.google.com/forum/?fromgroups=#!topic/rubyonrails-security/G4TTUDDYbNA).

Here's a copy if you don't want to read Google Groups:

<hr >

Since the most recent patch releases there has been some confusion about what versions of Ruby on Rails are currently supported, and when people can expect new versions.  Our maintenance policy is as follows. 

Support of the Rails framework is divided into four groups: New features, bug fixes, security issues, and severe security issues.  They are handled as follows:

## New Features

New Features are only added to the master branch and will not be made available in point releases.

## Bug fixes

Only the latest release series will receive bug fixes. When enough bugs are fixed and its deemed worthy to release a new gem, this is the branch it happens from.

Currently included series: 3.2.x

## Security issues:

The current release series and the next most recent one will receive patches and new versions in case of a security issue. 

Currently included series: 3.2.x, 3.1.x

## Severe security issues:

For severe security issues we will provide new versions as above, and also the last major release series will receive patches and new versions. The classification of the security issue is judged by the core team.

Currently included series: 3.2.x, 3.1.x, 2.3.x

## Unsupported Release Series

When a release series is no longer supported, it's your own responsibility to deal with bugs and security issues.  We may provide back-ports of the fixes and publish them to git, however there will be no new versions released.  If you are not comfortable maintaining your own versions, you should upgrade to a supported version.

You should also be aware that Ruby 1.8 will reach End of Life in June 2013, no further ruby security releases will be provided after that point.  If your application is only compatible ruby 1.8 you should upgrade accordingly.


-- 
Cheers,

Koz
