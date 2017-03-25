---
title: How to Name Your Notification
date: 2017-03-25 01:29 UTC
tags: swift, objective-c, notification
---

Lately, I researched more into [`Notification`](https://developer.apple.com/reference/foundation/nsnotification) class (or what we know as `NSNotification` pre-swift 3), a class that we can use for many-to-many communication in our app. Whilst searching for more references, I stumbled upon [Hermes Pique's article](http://www.hpique.com/2013/12/nsnotificationcenter-part-1/), a good old article that gives you more in-depth on how to use `Notification` class.

That article refers to an [Apple documentation](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CodingGuidelines/Articles/NamingIvarsAndTypes.html#//apple_ref/doc/uid/20001284-1002560) on how to name your `Notification` class. That's cool, I never realised that Apple has this kind of documents. 😅

The naming formula

```
[Name of associated class] + [Did | Will] + [UniquePartOfName] + Notification
```

Using this guide, I named my `Notification`s to be like:

* `ArtistsRepositoryDidStartUpdateNotification`
* `ArtistsRepositoryDidUpdateNotification`
* `ArtistsRepositoryDidFailToUpdateNotification`

And not like

* `DidUpdate // which class is being updated?`
* `DidFailToLoad // which process is failing? `

Please use sensible names to your `Notification` class if you want to be loved by your co-workers. It really helps to name your notifications properly since it is a highly decoupled mechanism, you will only get it right if you use the right names!
