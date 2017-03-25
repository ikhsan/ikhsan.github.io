---
title: Cara Menamakan Kelas Notifikasi
date: 2017-03-25 01:29 UTC
tags: swift, objective-c, notification
---

Akhir-akhir ini saya mempelajari lebih dalam kelas [`Notification`](https://developer.apple.com/reference/foundation/nsnotification) (atau yang dulu kita kenal sebagai `NSNotification`), sebuah kelas yang kita bisa gunakan untuk komunikasi _many-to-many_ untuk aplikasi kita. Sembari belajar, saya menemukan [artikel dari Hermes Pique](http://www.hpique.com/2013/12/nsnotificationcenter-part-1/) yang (cukup jadul namun) sangat menarik tentang bagaimana cara memakai `Notification` secara mendalam (artikel tersebut masih menggunakan Objective-c).

Artikel tersebut juga mereferensikan sebuah [dokumentasi Apple](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CodingGuidelines/Articles/NamingIvarsAndTypes.html#//apple_ref/doc/uid/20001284-1002560) yang menarik dan cocok untuk saya, yaitu petunjuk bagaimana cara menamakan kelas `Notification`. Ternyata ada juga ya dokumentasi tersebut, saya tidak pernah menyadarinya. 😅

Rumusnya adalah

```
[Name of associated class] + [Did | Will] + [UniquePartOfName] + Notification
```

Jadi, mengikuti rumus tersebut, berikut adalah nama-nama yang saya sematkan kepada kelas-kelas `Notification` saya:

* `ArtistsRepositoryDidStartUpdateNotification`
* `ArtistsRepositoryDidUpdateNotification`
* `ArtistsRepositoryDidFailToUpdateNotification`

Jangan pakai nama-nama seperti ini jika tidak ingin dijauhi dari teman kantor Anda

* `DidUpdate // apa yang diupdate?`
* `DidFailToLoad // kelas apa yang gagal`

Jadi pilih-pilihlah nama yang baik untuk kelas kalian, pasti teman-teman kantor Anda akan senang bekerja dengan (kode) Anda.
