---
title: 3 Langkah Menjalakan Aplikasi iOS di Perangkat Apple Tanpa Akun Developer
date: 2017-04-09 14:32 UTC
tags: xcode
---

Bagi Anda yang memulai iOS development, menggunakan aplikasi di simulator tidak terasa sama dengan menggunakan aplikasi di perangkat asli. Ada beberapa fitur yang tidak tersedia di simulator (dan susah juga kalau mau pamer ke teman-teman aplikasi yang sudah kamu buat!). Untungnya, sekarang menjalakan aplikasi di perangkat asli Apple sudah gratis dan mudah, tanpa perlu akun developer. READMORE

Ada beberapa yang harus disiapkan :

- 💻 Komputer Mac OS yang punya Xcode (versinya makin baru makin baik)
- 📱 Perangkat Apple (versi OS-nya makin baru makin baik)
- Akun Apple (akun yang sama untuk download aplikasi iOS)
- Aplikasimu (kalau belum buat, [bisa buat yang sederhana](https://github.com/codebar/ios-tutorials/blob/master/introduction/tutorial.md))

### 1. Tambah akunmu di Xcode

- Dari menubar, pilih `Xcode > Preferences...`
- Aktifkan `Accounts` tab (tab kedua)
- Di bawah kiri, klik ikon +
- Pilih `Add Apple ID...`
- Masukkan username dan password Apple ID-mu

![add_apple_id](blog/2017-04-09-three-steps-to-run-application-on-your-apple-device-without-developer-account/01_add_apple_id.png "Add your Apple ID")

### 2. Konfigurasi *signing* proyek

- Dari area `Navigator`, pilih tab `Project navigator`, klik nama proyekmu
- Pilih app target yang sesuai di tab `Targets`
- Di bagian `Signing`, pilih akun yang baru ditambahkan sebagai nama tim

![select_team](blog/2017-04-09-three-steps-to-run-application-on-your-apple-device-without-developer-account/02_select_team.png "Select team")

### 3. Konfigurasi perangkat 📱

- Colokkan perangkat Apple ke komputer (ini akan membuat Xcode untuk [memproses berkas simbol dari perangkat](http://stackoverflow.com/a/19706886/851515), ini akan memakan waktu beberapa saat)
- Ganti pilihan menjalakan dari simulator ke perangkat
![select device](blog/2017-04-09-three-steps-to-run-application-on-your-apple-device-without-developer-account/03_a_select_device.png "Select your apple device")
- Klik tombol play untuk menjalankan aplikasi!
- Errm... ternyata belum. Kita perlu mengizinkan aplikasi codesign untuk mengakses *keychain*, klik `Always Allow`
![allow keychain](blog/2017-04-09-three-steps-to-run-application-on-your-apple-device-without-developer-account/03_b_allow_keychain.png "Allow codesign to access keychain")
- Sedikit lagi, Xcode akan bilang bahwa akun harus terverifikasi oleh perangkat
![verify alert](blog/2017-04-09-three-steps-to-run-application-on-your-apple-device-without-developer-account/03_c_verify_alert.png "Verify account developer")
- Sekarang di perangkat iOS, dari aplikasi `Settings`, klik `General` > `Profiles & Device Management`, pilih akun di `Developer App`, pilih `Trust '<your apple account email>'`, dan konfirmasi akhir dengan memilih `Trust` lagi
![verify account](blog/2017-04-09-three-steps-to-run-application-on-your-apple-device-without-developer-account/03_d_verify_account.png "Verify account in your device")
- Kembali ke Xcode, klik tombol play untuk menjalankan aplikasi di perangkat Apple
- 🎉

Baguslah Apple mempermudah kita untuk mencoba aplikasi kita di perangkat Apple langsung. Selamat mencoba!
