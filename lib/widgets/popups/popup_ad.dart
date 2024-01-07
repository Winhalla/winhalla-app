// ignore_for_file: non_constant_identifier_names

import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/utils/ad_helper.dart';
import 'package:winhalla_app/utils/ffa_match_class.dart';
import 'package:winhalla_app/utils/user_class.dart';
import 'package:winhalla_app/widgets/coin.dart';

import '../../main.dart';
import '../inherited_text_style.dart';


// Must be called in a place where an FfaMatch ChangeNotifierProvider is present
Future showAdPopupWidget(
  BuildContext context1,
    String questId,
    RewardedAd ad,
    Function(AdWithoutView, RewardItem) callback
)  {

  return showDialog(context: context1, builder: (_) => AdPopupWidget(context1, questId, ad, callback));
}

Widget AdPopupWidget(BuildContext context1, String questId,RewardedAd ad, Function(AdWithoutView, RewardItem) callback) {
  return Builder(builder: (context) {
    return AlertDialog(
      elevation: 10,
      backgroundColor: kBackgroundVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      titlePadding: EdgeInsets.fromLTRB(7.w, 3.5.h, 7.w, 0),
      title: Text(
        "Reroll this quest",
        style: InheritedTextStyle.of(context).kHeadline2,
      ),
      contentPadding: EdgeInsets.fromLTRB(7.w, 2.75.h, 7.w, 2.5.h),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(style: InheritedTextStyle.of(context).kBodyText3, children: const [
              TextSpan(text: "To ", style: TextStyle(height: 1.3)),
              TextSpan(text: "REROLL ", style: TextStyle(color: kPrimary, height: 1.3)),
              TextSpan(text: "your quest, tap the red button below! (will launch an ad)", style: TextStyle(height: 1.3))
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
                onTap: ()async  {
                  FirebaseAnalytics.instance.logEvent(
                    name: "AdPopupAccepted",
                  );
                  Navigator.pop(context);
                  ad.show(onUserEarnedReward: callback);
                  context.read<User>().setNextAdQuests(null);

                },
                child: Container(
                    decoration: BoxDecoration(
                      color: kPrimary,
                        borderRadius: BorderRadius.circular(15)),
                    padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 1.h),
                    child: Text("Reroll", style: InheritedTextStyle.of(context).kBodyText1bis))),
            GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                    decoration: BoxDecoration(border: Border.all(color: kPrimary), borderRadius: BorderRadius.circular(15)),
                    padding: EdgeInsets.fromLTRB(3.w, .75.h, 3.w, .75.h),
                    child: Text("Keep", style: InheritedTextStyle.of(context).kBodyText2bis))),
          ],
        ),
      ],
    );
  });
}
