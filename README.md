# Winhalla Mobile App
Download available [here](https://play.google.com/store/apps/details?id=com.winhalla.app)

## Technical data
Made with Flutter in Dart
Tech details :
* Google, apple and Steam 3rd party sign-in 
* Firebase crashlytics, analytics, notifications, dynamic links for partnerships, and remote config for A/B tests
* Applovin MAX with mediation for ads (no official plugin used to exist)
* Persistent storage with flutter_secure_storage 
* State management with Provider
* HTTP requests to the associated [API](https://github.com/Winhalla/winhalla-api)
* Responsive with responsive_sizer

First ever flutter project for me, many things went weird or wrong, but I now know what mistakes not to make.
Most of the code here relatively makes sense, so it should be understandable. Especially since dart is an easy language to browse code in, in my opinion.

Please use branch master to avoid sending crashlytics or analytics reports by mistake.

If anybody wants to change the Applovin plugin to the newly released one, well, thanks.

I don't plan in editing this repo anymore, this project has shown by data that it was financially unsustainable.

## Branch map
master : main dev branch  
debug : an abandonned project of a debug version of the app  
deployment : clone of master with additions such as crashlytics, analytics and changes such as server IP, ect.  

apple-login : an old branch that was used to develop Apple login integration while keeping maintenance on master possible  
quest-animation : same as apple-login but for quests animations  
responsive-test : same  
tutorial : same  