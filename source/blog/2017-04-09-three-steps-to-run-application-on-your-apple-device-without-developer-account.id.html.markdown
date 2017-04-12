---
title: 3 Langkah Menjalakan Aplikasi iOS di Perangkat Apple Tanpa Akun Developer
date: 2017-04-09 14:32 UTC
tags: xcode
---

Bagi Anda yang memulai iOS development, menggunakan aplikasi di simulator tidak terasa sama dengan menggunakan aplikasi di perangkat asli. Ada beberapa fitur yang tidak tersedia di simulator (dan susah juga kalau mau pamer ke teman-teman aplikasi yang sudah kamu buat!). Untungnya, sekarang menjalakan aplikasi di perangkat asli Apple sudah gratis dan mudah, tanpa perlu akun developer. READMORE

Here are the things that you need to prepare :

- 💻 Mac OS machine running latest Xcode
- 📱 Apple device (more recent ones the better)
- Apple account (the same account for downloading apps in the App Store)
- Your app (if you don't have one yourself, [make a simple one](https://github.com/codebar/ios-tutorials/blob/master/introduction/tutorial.md))

### 1. Add your account in Xcode

- From the menubar, go to `Xcode > Preferences...`
- Click the `Accounts` tab (the second tab)
- On bottom left, press the + icon
- Select `Add Apple ID...`
- Insert your Apple ID's credentials

![add_apple_id](blog/2017-04-09-three-steps-to-run-application-on-your-apple-device-without-developer-account/01_add_apple_id.png "Add your Apple ID")

### 2. Configure your project's signing

- Go to `Navigator` area, select `Project navigator` tab, select your project name
- Select your app target in the `Targets` tab
- In the `Signing` area, select your account as the team name

![select_team](blog/2017-04-09-three-steps-to-run-application-on-your-apple-device-without-developer-account/02_select_team.png "Select team")

### 3. Configure your device 📱

- Plug your Apple device to your development machine (this will trigger Xcode to [processes symbol files from your devices](http://stackoverflow.com/a/19706886/851515), which will take a sometime)
- Instead of running on simulator, select your device instead
![select device](blog/2017-04-09-three-steps-to-run-application-on-your-apple-device-without-developer-account/03_a_select_device.png "Select your apple device")
- Press the play button to run the app!
- Errm... not so fast. We need to allow codesign to access our keychain, press `Always Allow`
![allow keychain](blog/2017-04-09-three-steps-to-run-application-on-your-apple-device-without-developer-account/03_b_allow_keychain.png "Allow codesign to access keychain")
- Almost there, but you will be prompted to verify your account in your device
![verify alert](blog/2017-04-09-three-steps-to-run-application-on-your-apple-device-without-developer-account/03_c_verify_alert.png "Verify account developer")
- Go to `Settings` > `General` > `Profiles & Device Management`, tap your account under `Developer App`, tap `Trust '<your apple account email>'`, and confirm by tapping `Trust` again
![verify account](blog/2017-04-09-three-steps-to-run-application-on-your-apple-device-without-developer-account/03_d_verify_account.png "Verify account in your device")
- Back at Xcode, press play button to build and run again
- 🎉

It's great to see that Apple makes it easy for us to try our app in our actual hands. Happy testing!

---

I wrote this article as a pull request to enhance [codebar](https://codebar.io)'s awesome [iOS workshop session](https://codebar.io/events/intro-to-ios) tutorial written by [Yvette Cook](https://twitter.com/ynzc).
