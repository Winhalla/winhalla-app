import 'dart:io';

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
}