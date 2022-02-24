// ignore_for_file: non_constant_identifier_names

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_applovin_max/flutter_applovin_max.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/utils/ad_helper.dart';
import 'package:winhalla_app/utils/ffa_match_class.dart';
import 'package:winhalla_app/utils/user_class.dart';
import 'package:winhalla_app/widgets/coin.dart';

import '../inherited_text_style.dart';

void adCallback(FfaMatch match, BuildContext context, User user) async {
  await user.callApi.get("/admob/getReward?user_id=${user.value["steam"]["id"]}&custom_data=${match.value["_id"]}");
  Future.delayed(const Duration(milliseconds: 500), () async {
    await match.refresh(context, user);
  });
}
// Must be called in a place where an FfaMatch ChangeNotifierProvider is present
Future<void> showAdPopupWidget(BuildContext context, FfaMatch match, ) async {

  await RewardedAd.load(
    serverSideVerificationOptions: ServerSideVerificationOptions(
        userId: match.value["userPlayer"]["steamId"],
        customData: "earnMoreSoloMatch",
    ),
    adUnitId: AdHelper.rewardedAdUnitId,
    request: const AdRequest(),
    rewardedAdLoadCallback: RewardedAdLoadCallback(
      onAdLoaded: (RewardedAd ad) {
        showDialog(
            context: context,
            builder: (_) =>
            AdPopupWidget(
                match.value["estimatedReward"]["reward"],
                match.value["estimatedReward"]["rewardNextAd"],
                true,
                match,
                context,
                admobAd: ad
            )
        );
      },
      onAdFailedToLoad: (err) async {
        print('Failed to load a rewarded ad: ${err.code} : ${err.message}');
        loadApplovinRewarded((Timer? timer){
          try{
            showDialog(
                context: context,
                builder: (_) =>
                    AdPopupWidget(
                        match.value["estimatedReward"]["reward"],
                        match.value["estimatedReward"]["rewardNextAd"],
                        false,
                        match,
                        context
                    )
            );
          } catch(e){
            timer?.cancel();
          }
        });

      },
    ),
  );

}

Widget AdPopupWidget(num reward, num nextReward, bool isAdmobAd, FfaMatch match, BuildContext context, {RewardedAd? admobAd}){
  User user = context.read<User>();
  return Builder(
      builder: (context) {
        return AlertDialog(
          elevation: 10,
          backgroundColor: kBackgroundVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          titlePadding: EdgeInsets.fromLTRB(7.w, 3.5.h, 7.w, 0 ),
          title: Text(
            "Double your reward",
            style: InheritedTextStyle.of(context).kHeadline2,
          ),
          contentPadding: EdgeInsets.fromLTRB(7.w, 2.75.h, 7.w, 2.5.h),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Estimated reward:", style: InheritedTextStyle.of(context).kBodyText2.apply(fontSizeFactor: 0.95, color: kText90)),
                  SizedBox(width: 2.w,),
                  Coin(
                    nb: reward.toString(),
                    color: kText,
                    bgColor: kBlack,
                    padding: const EdgeInsets.fromLTRB(15, 8.25, 15, 5.25),
                    fontSize: 25,
                  )
                ],
              ),
              SizedBox(height: 0.5.h,),
              Text(
                  "Based on performance, can vary until the end of the match.",
                  style: InheritedTextStyle.of(context).kBodyText3.apply(fontSizeFactor: 0.75, color: kText70, fontStyle: FontStyle.italic)
              ),
              SizedBox(height: 2.5.h,),
              RichText(
                text: TextSpan(style: InheritedTextStyle.of(context).kBodyText3, children: const [
                  TextSpan(text: "To ", style: TextStyle(height: 1.3)),
                  TextSpan(text: "DOUBLE ", style: TextStyle(color: kPrimary,height: 1.3)),
                  TextSpan(text: "your reward, tap the red button below!", style: TextStyle(height: 1.3))
                ]),
              ),
            ],
          ),
          actionsPadding: EdgeInsets.only(bottom: 2.5.h),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                    onTap: (){
                      Navigator.pop(context);
                      if(isAdmobAd && admobAd == null) return;
                      match.setAdPopupDate();

                      if(isAdmobAd && admobAd != null) {
                        admobAd.show(onUserEarnedReward: (RewardedAd ad, RewardItem reward) => adCallback(match, context, user));
                      } else {
                        FlutterApplovinMax.showRewardVideo((event) {
                          if (event == AppLovinAdListener.onUserRewarded) {
                            adCallback(match, context, user);
                          }
                        },);
                      }
                    },
                    child: Coin(
                      nb: nextReward.toString(),
                      color: kText,
                      bgColor: kRed,
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 5),
                      fontSize: 28,
                    )
                ),
                GestureDetector(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child: Coin(
                      nb: reward.toString(),
                      color: kText,
                      bgColor: kBlack,
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 5),
                      fontSize: 28,
                    )
                ),
              ],
            ),
          ],
        );
      }
  );
}