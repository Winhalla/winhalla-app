import 'dart:async';
import 'dart:io';

import 'package:flutter_applovin_max/flutter_applovin_max.dart';

class AdHelper {

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-7852842965403016/1142933036";
    } else if (Platform.isIOS) {
      return "ca-app-pub-7852842965403016/5672968273";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-7852842965403016/6620962717";
    } else if (Platform.isIOS) {
      return "ca-app-pub-7852842965403016/7538189067";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }
  static String get rewardedApplovinUnitId {
    if (Platform.isAndroid) {
      return "e4781c6fa48968ce";
    } else if (Platform.isIOS) {
      return "5108a8032a9f6142";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }
  static String get interstitialApplovinUnitId {
    if (Platform.isAndroid) {
      return "3170fb7b5c6632f3";
    } else if (Platform.isIOS) {
      return "d33b6eaa76bbf870";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }
}

void loadApplovinRewarded(Function(Timer?) callback, {Function? errorCallback}) async {
  await FlutterApplovinMax.initRewardAd(AdHelper.rewardedApplovinUnitId);
  int times = 0;
  bool hasPerformedCallback = false;
  void timerCallback(Timer? timer) async {
    if(hasPerformedCallback == true) return timer?.cancel();
    times ++;

    // Load unsuccessful after 16 tries (5s)
    if(times == 16) {
      if(errorCallback != null) errorCallback();
      timer?.cancel();
      return;
    }

    bool? isRewardedAdReady = await FlutterApplovinMax.isRewardLoaded((_)=>null);
    // Load successful
    if(isRewardedAdReady == true){
      hasPerformedCallback = true;
      timer?.cancel();
      callback(timer);
    }
  }
  timerCallback(null);
  Timer.periodic(const Duration(milliseconds: 333), timerCallback);
}

void showApplovinInterstitial() async {
  await FlutterApplovinMax.initInterstitialAd(AdHelper.interstitialApplovinUnitId);
  int times = 0;
  bool hasShownPopup = false;
  void timerCallback(Timer? timer) async {
    if(hasShownPopup == true) return timer?.cancel();
    times ++;
    if(times == 16) return timer?.cancel();
    bool? isRewardedAdReady = await FlutterApplovinMax.isInterstitialLoaded((_)=>null);
    if(isRewardedAdReady == true){
      hasShownPopup = true;
      timer?.cancel();
      try{
        await FlutterApplovinMax.showInterstitialVideo((AppLovinAdListener? event) {
          print("--------------------------$event-----------------------------");
          if(event == AppLovinAdListener.adHidden){
            FlutterApplovinMax.initInterstitialAd(AdHelper.interstitialApplovinUnitId);
          }
        });
      } catch(e){
        timer?.cancel();
      }
    }
  }
  timerCallback(null);
  //! convert to a function to call it before the first timer call
  Timer.periodic(const Duration(milliseconds: 333), timerCallback);
}