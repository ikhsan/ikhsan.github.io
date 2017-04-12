---
title: 3 Steps to Run Application on Your Apple Device without Developer Account
date: 2017-04-09 14:32 UTC
tags: xcode, itunes
---

For people who started iOS development, running your app in the app simulator won't be the same as running on your own device. There are features that don't exist in the simulator (and it's harder to show to your friends what you've made!). Luckily, it's free and easy to run your app on a physical device without a developer account. READMORE

Here are the things that you need to prepare :

- Mac OS machine running latest Xcode 💻
- Apple device (more recent ones the better) 📱
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
