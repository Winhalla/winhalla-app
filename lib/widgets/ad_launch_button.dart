import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/src/provider.dart';
import 'package:winhalla_app/utils/ad_helper.dart';
import 'package:winhalla_app/utils/ffa_match_class.dart';
import 'package:winhalla_app/utils/user_class.dart';




class AdButton extends StatefulWidget {
  final Widget child;
  final Widget adNotReadyChild;
  final String goal;
  const AdButton({Key? key, required this.child,required this.goal, this.adNotReadyChild= const SizedBox(height: 0,width: 0,)}) : super(key: key);

  @override
  _AdButtonState createState() => _AdButtonState();
}

class _AdButtonState extends State<AdButton> {
  bool _lastAdError = false;
  bool hasAlreadyInitAdmob = false;
  bool isAdReady = false;
  late RewardedAd _rewardedAd;
  late User user;
  FfaMatch? match;

  Future<void> _initGoogleMobileAds() async {
    if(!hasAlreadyInitAdmob){
      await MobileAds.instance.initialize();
      hasAlreadyInitAdmob = true;
    }
    await RewardedAd.load(
      serverSideVerificationOptions: ServerSideVerificationOptions(
          userId: user.value["steam"]["id"],
          customData: widget.goal == "earnMoreSoloMatch" ? match?.value["_id"] : widget.goal
      ),
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          setState(() {
            isAdReady = true;
          });
          if(_lastAdError == true) {
            _lastAdError = false;
            ad.show(onUserEarnedReward: (_,__){});
          }
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              _initGoogleMobileAds();
              setState(() {
                isAdReady = false;
              });
              Future.delayed(const Duration(milliseconds: 500), () async {
                if(match != null) {
                  await match?.refresh(context, user);
                } else {
                  user.refresh();
                }
              });
            },
          );
        },
        onAdFailedToLoad: (err) {
          print('Failed to load a rewarded ad: ${err.message}');
          setState(() {
            _lastAdError = true;
          });
        },
      ),
    );
  }

  Future<void> playAd() async {
    if(_lastAdError) {
      _initGoogleMobileAds();
    } else if (isAdReady){
      _rewardedAd.show(onUserEarnedReward: (rewardedAd, rewardItem){
      });
    }
  }

  @override
  void initState() {
    user = context.read<User>();
    user.setKeyFx(playAd, "playAd");
    if(widget.goal == "earnMoreSoloMatch") {
      match = context.read<FfaMatch>();
      if(user.inGame["showActivity"] == false) user.toggleShowMatch(true);
    }
    _initGoogleMobileAds();
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: isAdReady?widget.child:widget.adNotReadyChild,
      onTap: playAd
    );
  }
}
