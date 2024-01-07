import 'dart:async';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../main.dart';

/*class AdHelper {
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
}*/
class AdHelper {
  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-7852842965403016/6853464172";
    } else if (Platform.isIOS) {
      return "ca-app-pub-7852842965403016/5672968273";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-7852842965403016/4162316688";
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

void loadApplovinRewarded(Function(RewardedAd) callback, {Function? errorCallback}) async {
  print(isLoading);
  if (isLoading = true) {
    timer1?.cancel();
  }
  isLoading = true;
  RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        // Called when an ad is successfully received.

        onAdLoaded: (ad) {
          callback(ad);
          isLoading = false;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            // Called when the ad showed the full screen content.
              onAdShowedFullScreenContent: (ad) {},
              // Called when an impression occurs on the ad.
              onAdImpression: (ad) {},
              // Called when the ad failed to show full screen content.
              onAdFailedToShowFullScreenContent: (ad, err) {
                // Dispose the ad here to free resources.
                ad.dispose();
              },
              // Called when the ad dismissed full screen content.
              onAdDismissedFullScreenContent: (ad) {
                // Dispose the ad here to free resources.
                ad.dispose();
              },

              // Called when a click is recorded for an ad.
              onAdClicked: (ad) {});
        },

        // Called when an ad request failed.
        onAdFailedToLoad: (LoadAdError error) {
          if (errorCallback != null) errorCallback();
          isLoading = false;
        },
      )
  );
}

void showApplovinInterstitial(String adUnitName) async {
  InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          ad.onPaidEvent = (ad, value, precision, currencyCode){
            FirebaseAnalytics.instance
                .logAdImpression(adFormat: "Interstitial",
                adPlatform: "AdMob",
                adUnitName: adUnitName,
                value: value,
                currency: currencyCode);
          };
          ad.show();
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('InterstitialAd failed to load: $error');
        },
      ));


}
