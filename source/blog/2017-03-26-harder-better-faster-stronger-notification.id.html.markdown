---
title: Notifikasi yang Lebih Keras, Bagus, Cepat dan Kuat
date: 2017-03-26 11:55 UTC
tags: notification, objective-c, swift
---

Di tempat saya bekerja sekarang, kami sedang memikirkan ulang cara lain mengkomunikasikan perubahan yang terjadi di kelas model. Perubahan ini harus tersiarkan ke kelas-kelas lain. Sepertinya, ini akan terdengar sebagai contoh kasus yang tepat untuk memperkenalkan konsep reaktif, namun ini bukan artikel untuk menjelaskan bagaimana menggunakan `ReactiveCococa` atau `RxSwift`. Sebaliknya, perkenankan saya mengingatkan kembali kepada teman lama kita, `Notification` and `NotificationCenter`. READMORE

## Kebutuhan

Di artikel ini, saya akan bercerita tentang kebutuhan dan rancangan sementara versi lebih baiknya kelas `Notification` (atau yang di masanya dikenal sebagai `NSNotification`). Harap dicatat artikel ini hanya akan membahas kelas `Notification` yang _custom_. Notifikasi `UIKit` adalah di luar cakupan artikel ini.

![harder_better](blog/2017-03-26-harder-better-faster-stronger-notification/harder_better.jpg "Harder better faster stronger")

* __Harder__, lebih sulit untuk membuat kesalahan. Tidak ada lagi menamakan notifikasi dengan `String`.
* __Better__, kompatibilitas yang lebih baik dengan Objective-C. Aplikasi kami berumur 5 tahun, sehingga penting untuk bisa digunakan oleh kelas-kelas Objective-C.
* __Faster__, penciptaan _post_ dan _observer_ yang cepat. Menyiarkan dan mendengarkan perubahan akan menjadi lebih mudah.
* __Stronger__, informasi tipe yang lebih kuat. `Notification` mempunyai tipe informasi yang lemah, Anda bisa memberikan kelas apapun sebagai `object`-nya dan _dictionary_ apapun sebagai `userInfo`-nya.

_Memang kebutuhannya ini sedikit terdengar memaksa, saya membuatnya agar referensi Daft Punk saya relevan dengan artikel ini._

## Rancangan 1: Rancangan dari Swift Talk

Langkah awal saya diinspirasikan dari pekerjaan orang lain, adalah Chris dan Florian dari [Swift Talk](https://talk.objc.io) yang mengajarkan pemirsanya bagaimana membungkus `Notification` menggunakan protokol. Ide dasarnya adalah protokol tersebut mempunyai nama untuk notifikasi dan objeknya itu sendiri di-_assign_ sebagai `object`-nya.

```swift

// MARK: Rancangan 1
protocol Notifiable {
    static var notificationName: Notification.Name { get }
}

extension NotificationCenter {
    func post<A: Notifiable>(notifiable: A) {
        post(name: A.notificationName, object: notifiable)
    }

    func observe<A: Notifiable>(using block: @escaping (A) -> Void) -> NSObjectProtocol {
        return addObserver(forName: A.notificationName, object: nil, queue: nil) {
            notification in
            if let notif = notification.object as? A {
                block(notif)
            }
        }
    }
}
```

Mari kita buat contoh sederhana untuk memperjelas rancangan ini dan kenapa ini lebih baik dari rancangan `Notification` sebelumnya. Misalkan kita mempunyai _counter_ global di aplikasi kita dan kita mau mendapatkan nilainya setiap kali ada perubahan. Kita akan membuat kelas notifikasi `CounterDidChangeNotification` yang memenuhi protokol `Notifable`. Kita menggunakan kelas daripada _struct_ karena ini akan digunakan oleh kelas Objective-C juga. Jangan lupa gunakan [nama yang bagus untuk kelas notifikasimu](/blog/id/how-to-name-your-notification.html).

```swift

// MARK: Rancangan 1 - call site
final class CounterDidChangeNotification: NSObject {
    let count: Int
    init(_ count: Int) {
        self.count = count
        super.init()
    }
}

extension CounterDidChangeNotification: Notifiable {
    static var notificationName: Notification.Name {
        return Notification.Name(rawValue: "CounterDidChangeNotification")
    }
}

// MARK: Post and observe 'CounterDidChangeNotification'
notificationCenter.post(CounterDidChangeNotification(10))

notificationCenter.observe { (notification: CounterDidChangeNotification) in
    print("latest count \(notification.count)") // akan mencetak "latest count 10"
}
```

Rancangan antarmuka `Notification` kita sekarang lebih aman dan lebih punya informasi ketimbang antarmuka dari `Foundation`. Bila kita ingin menyiarkan menggunakan yang disediakan `Foundation`, fungsinya memerlukan namanya dan juga objek yang bisa jadi apa saja atau bahkan `nil` . Cara mendengerkan notifikasi dari `Foundation` juga tidak kalah ribet, fungsinya sama juga memerlukan nama dan _block_-nya harus mengetahui caranya mengambil informasi dari kelas `Notification`, bisa saja `object`-nya yang penting, atau informasi di dalam `userInfo` yang penting.

Sedangkan di rancangan `Notification` kita, sewaktu menyiarkan kita tinggal membuat instansi dari `Notifiable` lalu disiarkan menggunakan fungsi `post`. Mendengarkan notifikasi lebih canggih lagi, kita tinggal memberikan informasi tentang kelas apa yang kita sedang ingin dengarkan di dalam _block_. Swift cukup pintar untuk mendapatkan informasi tersebut hanya dari tipenya (untuk kasus ini adalah dari kode `{ (notification: CounterDidChangeNotification) in ... }`). Sisa informasi seperti nama dan bagaiaman cara mengolah objek notifikasi sudah diurus oleh fungsi yang kita tulis.

## Rancangan 2: Penamaan Otomatis

Kita bisa membuat rancangan pertama lebih baik lagi yaitu menggunakan nama kelas kita sebagai nama notifikasi dengan ekstensi protokol kita.

```swift
// MARK: Rancangan 2
protocol Notifiable {
    static var notificationName: Notification.Name { get }
}

extension Notifiable {
    static var notificationName: Notification.Name {
        return Notification.Name(String(describing: self))
    }
}
```

Kita tidak perlu memberikan nama secara manual lagi kepada notifikasi kita karena implementasi ekstensi protokol `Notifiable` akan menggunakan nama kelas itu sendiri. Perlu dicatat, kita tetap bisa memberikan nama secara manual jika diperlukan dengan cara mengimplementasikan properti `notificationName` di kelas kita.

Kelas `CounterDidChangeNotification` kita sudah lebih sederhana, sekarang kita bisa membuat kelas tersebut bisa disiarkan hanya dengan membubuhi protokol `Notifiable`.

```swift
// MARK: Rancangan 2 - call site
final class CounterDidChangeNotification: NSObject, Notifiable {
    let count: Int

    init(_ count: Int) {
        self.count = count
        super.init()
    }
}
```

Sekarang, menyiarkan sebuah kelas menjadi bertambah mudah, mantap! 👍

![great](blog/2017-03-26-harder-better-faster-stronger-notification/dp.gif "great")

## Rancangan 3: Teman lama kita

Sekarang bagian yang tersulit: Objective-C. Mari kita lihat fungsi `NotificationCenter` kita di _header file_.

```objc
@interface NSNotificationCenter (SWIFT_EXTENSION(Notification))
@end
```

Apakah kita bisa lihat fungsi ekstensi yang sudah kita tambahkan? Nah, itu dia, Objective-C tidak mengertik konsep ekstensi protokol dan fungsi generik dari Swift. Jadi bagaimana caranya agar kelas kita dapat digunakan oleh kelas-kelas Objective-C?

Langkah pertama, kita ubah protokol `Notifiable` menjadi kelas basis sehingga kita bisa membuat kelas-kelas turunannya mempunyai cara menamakan notifikasinya secara dinamis.

Terkadang membuat kode yang kompatibel dengan Objective-C terasa seperti berjalan mundur. Seringkali kita dengar "Jangan gunakan _subclassing_ kalau tidak mau kelas mempunyai tingkah laku yang sulit dicari asalnya darimana, gunakan ekstensi protokol, dsb". _Subclassing_ itu sah-sah saja, tidak ada yang buruk dengan itu. _Subclassing_ adalah salah satu kakas yang baik, apalagi untuk kasus kita yang memerlukan kompatibilitas dengan Objective-C dan hanya mempunyai satu tingkat keturunan.

```swift
// MARK: Rancangan 3
class Notifiable: NSObject {
    static var notificationName: Notification.Name {
        return Notification.Name(String(describing: self))
    }
}
```

Langkah selanjutnya, kita membuat fungsi `post` kita kompatibel dengan Objective-C dengan cara mengganti tipe generik dengan kelas baru `Notifiable`. Fungsi satunya lagi, `observe` sedikit lebih rumit. Kemampuan Objective-C dalam mengenal kelas generik terbatas, sehingga kita memberikan informasi tipe kelas kita lewat parameter. Rancangan ini memang tidak mempunyai informasi selengkap fungsi pasangannya di Swift, tapi paling tidak kita bisa membuatnya lebih aman karena _block_ yang kita berikan tidak akan terpanggil jika tipenya tidak sesuai.

Cara kerjanya seperti petugas imigrasi saja, mereka menyocokkan visa turis dengan negara kunjungannya, bila turis punya visa yang benar maka petugas akan mengizinkan turis melewati gerbang imigrasi. Nah mirip-mirip, fungsi kita akan menyocokkan nama kelas dari object notifikasi dan nama kelas dari parameter, bila nama objek notifikasi benar maka fungsi kita akan memanggil _block_ dengan menggunakan objek tersebut.

```swift
// MARK: Lanjutan Rancangan 3
func post(notifiable: Notifiable) {
    post(name: type(of: notifiable).notificationName, object: notifiable)
}

func observe(classType: Notifiable.Type, using block: @escaping (Any) -> ()) -> NSObjectProtocol {
    return addObserver(forName: classType.notificationName, object: nil, queue: nil) {
        notification in

        guard let notificationObject = notification.object else { return }
        let expectedType = String(describing: classType)
        let type = String(describing: type(of: notificationObject))
        if expectedType == type  {
            block(notificationObject)
        }
    }
}
```

Sekarang mari kita cek kembali _header file_ kita, maka 2 fungsi kita akan terlihat di ekstensi `NotificationCenter`!

```objc
@interface NSNotificationCenter (SWIFT_EXTENSION(Notification))
- (void)postWithNotifiable:(Notifiable * )notifiable;
- (id <NSObject>)observeWithClassType:(SWIFT_METATYPE(Notifiable))classType using:(void (^)(id))block;
@end
```

Langkah terakhir, adalah gunakan fungsi `observe` baru kita dengan cara _force cast_ type `id` dengan kelas yang kita inginkan. Lihat seksama bagaimana parameter tipe di parameter pertama harus sama dengan tipe yang digunakan _block_ di parameter kedua.

```objc
// MARK: Rancangan 3 - call site
[self.notificationCenter
    observeWithClassType:CounterDidChangeNotification.class
    using:^(CounterDidChangeNotification *notification) {
    NSLog(@"latest count %ld", (long)notification.count) // akan mencetak "latest count 10"
}];
```

Ajib! Sekarang kita mempunyai rancangan fungsi untuk menyiarkan dan mendengarkan notifikasi yang kompatibel di dua bahasa (Swift dan Objective-C) 🙌 Saya cukup puas dengan rancangan ini, namun bila ada ide atau teknik yang bisa membuat kelas `Notification` ini lebih aman dan mudah digunakan, mohon bagi-bagi.

Untuk melihat bagaimana cara kerja kelas `Notification` di atas, saya mempersiapkan aplikasi contoh bila memerlukan : [Notification sample](2017-03-26-harder-better-faster-stronger-notification/Notification.zip).
