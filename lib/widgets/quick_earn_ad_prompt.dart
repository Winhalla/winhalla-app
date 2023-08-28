import 'dart:math';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/utils/user_class.dart';
import 'package:winhalla_app/widgets/ad_launch_button.dart';
import 'package:winhalla_app/widgets/inherited_text_style.dart';

class QuickEarnAdPrompt extends StatefulWidget {
  const QuickEarnAdPrompt({Key? key}) : super(key: key);

  @override
  State<QuickEarnAdPrompt> createState() => _QuickEarnAdPromptState();
}

class _QuickEarnAdPromptState extends State<QuickEarnAdPrompt> {
  bool show = false;
  int amount = 50;

  @override
  void initState() {
    super.initState();
    initLuck();
  }
  void initLuck(){
    int luck = FirebaseRemoteConfig.instance.getInt("AdButtonLuck");
    int nb = Random().nextInt(100);
    User user = context.read<User>();
    int now = DateTime.now().millisecondsSinceEpoch;
    print(user.value["user"]["tutorialStep"]);
    if (nb < luck &&
        user.lastAdPrompt + 600 * 1000 < now &&
        user.value["user"]["tutorialStep"]["hasFinishedTutorial"]) {
      nb = Random().nextInt(100);
      FirebaseAnalytics.instance.logEvent(name: "ShownQuickEarn");
      show = true;
      if (nb > 80) amount = 75;
      if (nb > 95) amount = 100;
    }
  }

  @override
  Widget build(BuildContext context) {
    print(show);
    if (!show) return Container();
    return AdButton(
      goal: "earnQuick$amount",
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                color: kBackgroundVariant,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                    color: amount == 100
                        ? kRed
                        : amount == 75
                            ? kEpic
                            : kPrimary)),
            padding: const EdgeInsets.fromLTRB(30, 21, 11, 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      "Get ",
                      style: InheritedTextStyle.of(context).kBodyText2bis,
                    ),
                    Text(
                      '$amount',
                      style: InheritedTextStyle.of(context).kBodyText1.apply(
                          color: amount == 100
                              ? kRed
                              : amount == 75
                                  ? kEpic
                                  : kPrimary),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3.0),
                      child: Image.asset("assets/images/coin.png",
                          height: 32,
                          color: amount == 100
                              ? kRed
                              : amount == 75
                                  ? kEpic
                                  : kPrimary),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(13),
                          color: amount == 100
                              ? kRed
                              : amount == 75
                                  ? kEpic
                                  : kPrimary),
                      padding: const EdgeInsets.fromLTRB(19, 9, 19, 9),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 1.5),
                            child: Image.asset(
                              "assets/images/video_ad.png",
                              width: 20,
                              color: kText80,
                            ),
                          ),
                          const SizedBox(
                            width: 7,
                          ),
                          Text(
                            "Watch",
                            style: InheritedTextStyle.of(context).kBodyText4.apply(color: kText80),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        setState(() {
                          show = false;
                          context.read<User>().setLastAdPrompt(DateTime.now().millisecondsSinceEpoch);
                        });
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Icon(
                          Icons.clear_outlined,
                          color: kText60,
                          size: 26,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 40,
          ),
        ],
      ),
    );
  }
}
