import 'dart:async';
import 'dart:io';

import 'package:applovin_max/applovin_max.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import '../main.dart';

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

bool isLoading = false;
Timer? timer1;

void loadApplovinRewarded(Function() callback, {Function? errorCallback, Function? rewardCallback}) async {
  print(isLoading);
  if (isLoading = true) {
    timer1?.cancel();
  }
  isLoading = true;
  AppLovinMAX.loadRewardedAd(AdHelper.rewardedApplovinUnitId);
  AppLovinMAX.setRewardedAdListener(RewardedAdListener(
      onAdLoadedCallback: (ad) {
        callback();
        isLoading = false;
      },
      onAdLoadFailedCallback: (reason, error) {
        if (errorCallback != null) errorCallback();
        isLoading = false;
      },
      onAdDisplayedCallback: (ad) {},
      onAdDisplayFailedCallback: (reason, error) {},
      onAdClickedCallback: (ad) {},
      onAdHiddenCallback: (ad) {},
      onAdReceivedRewardCallback: (ad, reward) {
        if(rewardCallback !=null) rewardCallback();
      }));
}

void showApplovinInterstitial(String adUnitName) async {
  AppLovinMAX.loadInterstitial(AdHelper.interstitialApplovinUnitId);
  AppLovinMAX.setInterstitialListener(InterstitialListener(
      onAdLoadedCallback: (ad) {
        AppLovinMAX.showInterstitial(AdHelper.interstitialApplovinUnitId);
      },
      onAdLoadFailedCallback: (_, __) {print(__);},
      onAdDisplayedCallback: (ad) {
        FirebaseAnalytics.instance.logAdImpression(
            adFormat: "Interstitial",
            adPlatform: ad.networkName,
            adUnitName: adUnitName,
            value: ad.revenue,
            currency: "USD");
      },
      onAdDisplayFailedCallback: (_, __) {print(__);},
      onAdClickedCallback: (_) {},
      onAdHiddenCallback: (ad) {
      }));
}
