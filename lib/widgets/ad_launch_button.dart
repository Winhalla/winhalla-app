import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:winhalla_app/utils/ad_helper.dart';
import 'package:winhalla_app/utils/ffa_match_class.dart';
import 'package:winhalla_app/utils/user_class.dart';
import 'package:winhalla_app/widgets/coin_dropdown.dart';

class AdButton extends StatefulWidget {
  final Widget child;
  final Widget adNotReadyChild;
  final Widget adErrorChild;
  final String goal;
  final void Function()? hideItself;

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
      ),
      this.hideItself})
      : super(key: key);

  @override
  _AdButtonState createState() => _AdButtonState();
}

class _AdButtonState extends State<AdButton> {
  bool _lastAdError = false;

  late User user;
  FfaMatch? match;

  RewardedAd? nextAd;

  Future<void> _initAds() async {
    loadApplovinRewarded((ad) {
      ad.onPaidEvent = (ad, value, precision, currencyCode) {
        FirebaseAnalytics.instance.logAdImpression(
            adFormat: "Rewarded",
            adPlatform: "AdMob",
            adUnitName: "adLaunchButton_" + widget.goal,
            value: value,
            currency: currencyCode);
      };
      if (mounted) {
        setState(() {
          nextAd = ad;
        });
      }
    }, errorCallback: () {
      if (mounted) {
        setState(() {
          _lastAdError = true;
        });
      }
    });
  }

  Future<void> playAd() async {
    if (user.inGame?["showActivity"] == false) user.toggleShowMatch(true);
    if (nextAd != null) {
      nextAd!.show(
          onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) async {
        if (mounted) {
          setState(() {
            nextAd = null;
          });
        }
        if (widget.goal == "earnMoreSoloMatch") {
          FirebaseAnalytics.instance.logEvent(name: "RewardedAdMatchShown");
        }
        if (widget.goal.startsWith("earnQuick")) {
          FirebaseAnalytics.instance.logEvent(name: "QuickEarnShown");
        }
        await user.callApi.get(
            "/admob/getReward?user_id=${user.value["steam"]["id"]}&custom_data=${widget.goal == "earnMoreSoloMatch" ? match?.value["_id"] : widget.goal}");
        if (widget.goal.startsWith("earnQuick")) {
          showCoinDropdown(context, user.value['user']["coins"],
              int.tryParse(widget.goal.substring(9)) ?? 60);
        }
        //refresh UI
        if (match != null) {
          Future.delayed(const Duration(milliseconds: 500), () async {
            await match?.refresh(context, user);
          });
        } else {
          await user.refresh();
          if (widget.goal == "dailyChallenge") {
            user.keyFx["rebuildHomePage"]();
          }
        }
        if (widget.hideItself != null) widget.hideItself!();
      });
    } else if (_lastAdError) {
      _initAds();
    }
  }

  @override
  void initState() {
    user = context.read<User>();
    user.setKeyFx(playAd, "playAd");
    if (widget.goal == "earnMoreSoloMatch") {
      match = context.read<FfaMatch>();
    }
    if (!kDebugMode || true) {
      _initAds();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        child: nextAd != null
            ? widget.child
            : _lastAdError
                ? widget.adErrorChild
                : widget.adNotReadyChild,
        onTap: playAd);
  }
}
