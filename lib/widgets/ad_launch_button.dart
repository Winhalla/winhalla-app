import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/src/provider.dart';
import 'package:winhalla_app/utils/ad_helper.dart';
import 'package:winhalla_app/utils/ffa_match_class.dart';
import 'package:winhalla_app/utils/get_uri.dart';
import 'package:winhalla_app/utils/user_class.dart';

import 'package:flutter_applovin_max/flutter_applovin_max.dart';

class AdButton extends StatefulWidget {
  final Widget child;
  final Widget adNotReadyChild;
  final Widget adErrorChild;
  final String goal;
  const AdButton(
      {Key? key,
      required this.child,
      required this.goal,
      this.adNotReadyChild = const SizedBox(
        height: 0,
        width: 0,
      ),
      this.adErrorChild = const SizedBox(
        height: 0,
        width: 0,
      )})
      : super(key: key);

  @override
  _AdButtonState createState() => _AdButtonState();
}

class _AdButtonState extends State<AdButton> {
  bool _lastAdError = false;
  bool isAdReady = false;
  late RewardedAd _rewardedAd;
  late User user;
  FfaMatch? match;

  bool isMAXRewardedVideoAvailable = false;

  Future<void> _initGoogleMobileAds() async {
    await RewardedAd.load(
      serverSideVerificationOptions: ServerSideVerificationOptions(
          userId: user.value["steam"]["id"],
          customData: widget.goal == "earnMoreSoloMatch"
              ? match?.value["_id"]
              : widget.goal),
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          setState(() {
            isAdReady = true;
          });
          if (_lastAdError == true) {
            _lastAdError = false;
            ad.show(onUserEarnedReward: (_, __) {});
          }
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) async {
              _initGoogleMobileAds();
              setState(() {
                isAdReady = false;
              });
              if (match != null) {
                Future.delayed(const Duration(milliseconds: 500), () async {
                  await match?.refresh(context, user);
                });
              } else {
                await user.refresh();
                user.keyFx["rebuildHomePage"]();
              }
            },
          );
        },
        onAdFailedToLoad: (err) async {
          print('Failed to load a rewarded ad: ${err.code} : ${err.message}');
          await FlutterApplovinMax.initRewardAd(AdHelper.rewardedApplovinUnitId);
          bool isReady = await FlutterApplovinMax.isRewardLoaded(maxEventListner) ?? false;
          setState(() {
            isMAXRewardedVideoAvailable = isReady;
          });
        },
      ),
    );
  }

  Future<void> playAd() async {
    if (user.inGame?["showActivity"] == false) user.toggleShowMatch(true);
    if (isMAXRewardedVideoAvailable) {
      FlutterApplovinMax.showRewardVideo(
          (AppLovinAdListener? event) => maxEventListner(event));
    } else if (_lastAdError) {
      _initGoogleMobileAds();
    } else if (isAdReady) {
      _rewardedAd.show(onUserEarnedReward: (rewardedAd, rewardItem) {});
    }
  }

  @override
  void initState() {
    user = context.read<User>();
    user.setKeyFx(playAd, "playAd");
    if (widget.goal == "earnMoreSoloMatch") {
      match = context.read<FfaMatch>();
    }
    if (!kDebugMode || true) _initGoogleMobileAds();
    super.initState();
  }

  void maxEventListner(AppLovinAdListener? event) async {
    print("--------------------------$event-----------------------------");
    if (event == AppLovinAdListener.adLoaded) {
      setState(() {
        isMAXRewardedVideoAvailable = true;
      });
    }

    if (event == AppLovinAdListener.onUserRewarded) {
      setState(() {
        isMAXRewardedVideoAvailable = false;
      });

      await user.callApi
          .get(
              "/admob/getReward?user_id=${user.value["steam"]["id"]}&custom_data=${widget.goal == "earnMoreSoloMatch" ? match?.value["_id"] : widget.goal}");

      //refresh UI
      if (match != null) {
        Future.delayed(const Duration(milliseconds: 500), () async {
          await match?.refresh(context, user);
        });
      } else {
        await user.refresh();
        user.keyFx["rebuildHomePage"]();
      }
    }

    if (event == AppLovinAdListener.adLoadFailed) {
      return setState(() {
        _lastAdError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        child: isAdReady || isMAXRewardedVideoAvailable
            ? widget.child
            : _lastAdError
                ? widget.adErrorChild
                : widget.adNotReadyChild,
        onTap: playAd);
  }
}
