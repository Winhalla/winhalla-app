import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/utils/user_class.dart';
import 'package:winhalla_app/widgets/coin_dropdown.dart';

import '../coin.dart';
import '../inherited_text_style.dart';
import 'daily_challenge_item.dart';
import 'tree_painter.dart';

class DailyChallenge extends StatefulWidget {
  const DailyChallenge({Key? key}) : super(key: key);

  @override
  State<DailyChallenge> createState() => _DailyChallengeState();
}

class _DailyChallengeState extends State<DailyChallenge>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late Animation<num> curvedAnimation;
  //bool cancelAnim = false;
  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    Future.delayed(const Duration(milliseconds: 1650), () {
      if(mounted /*&& !cancelAnim*/) _animationController.forward();
    });

    double beginValue = 0.15;

    curvedAnimation = Tween(
      begin: beginValue,
      end: 1,
    ).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: context.read<User>().keys[14],
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Daily challenge",
              style: InheritedTextStyle.of(context).kHeadline1,
            ),
            Consumer<User>(builder: (context, user, _) {
              return Coin(
                nb: user.value["user"]["dailyChallenge"]["challenges"]
                    .fold(0, (sum, item) => sum + item["reward"])
                    .toString(),
                color: kOrange,
                padding: const EdgeInsets.fromLTRB(16, 9, 16, 6),
              );
            }),
          ],
        ),
        Padding(
            padding: const EdgeInsets.only(top: 20.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*Positioned(
                      top: 0,
                      child: SizedBox(
                        width: 328,
                        height: 200,
                        child: CustomPaint(
                          painter: TreePainter(),
                          child: Container(),
                        ),
                      )),*/
                Consumer<User>(builder: (context, user, _) {
                  final List newDailyChallengeQuestsData =
                      user.value["user"]["dailyChallenge"]["challenges"];

                  final oldDailyChallengeData = (user.oldDailyChallengeData == null) || (user.oldDailyChallengeData[0]["name"] != newDailyChallengeQuestsData[0]["name"])  ? newDailyChallengeQuestsData : user.oldDailyChallengeData;

                  bool arraysAreTheSame() {
                    for (int i = 0; i < newDailyChallengeQuestsData.length; i++) {
                      if (newDailyChallengeQuestsData[i]?["_id"] != oldDailyChallengeData[i]?["_id"]) {
                        return false;
                      }
                    }
                    return true;
                  }

                  bool areTheSame = arraysAreTheSame();
                  //if(areTheSame) cancelAnim = true;


                  void computeLines(dailyChallengeData) {
                    for (var quest in dailyChallengeData) {
                      final textPainter = TextPainter(
                        text: TextSpan(
                            text: quest["name"] as String, style: InheritedTextStyle.of(context).kBodyText3),
                        textDirection: TextDirection.ltr,
                      );
                      textPainter.layout(
                          maxWidth:
                              138); //maxWidth needs to be set to: DailyChallengeItem maxWidth - DailyChallengeItem X padding
                      List lines = textPainter.computeLineMetrics();
                      quest["lineNumber"] = lines.length;
                    }
                  }

                  computeLines(oldDailyChallengeData);
                  computeLines(newDailyChallengeQuestsData);
                  if(areTheSame){
                    for (int i = 0; i < newDailyChallengeQuestsData.length; i++){
                      if(newDailyChallengeQuestsData[i]["completed"] == true && oldDailyChallengeData[i]["completed"] == false){
                        if(i == 0){
                          FirebaseAnalytics.instance.logEvent(name: "AdChallengeDisplayed");
                        }
                        if(i == 1){
                          FirebaseAnalytics.instance.logEvent(name: "AdChallengeFinished");
                        }
                        Future.delayed(const Duration(milliseconds: 3000),() {
                          showCoinDropdown(
                              context,
                              user.value["user"]["coins"] - newDailyChallengeQuestsData[i]["reward"],
                              newDailyChallengeQuestsData[i]["reward"]
                          );
                        });
                        break;
                      }
                    }
                  }
                  user.refreshOldDailyChallengeData();
                  return AnimatedBuilder(
                      animation: curvedAnimation,
                      builder: (BuildContext context, Widget? child) {
                        var currentDailyChallengeQuestsData =
                            oldDailyChallengeData;
                        var hasChangedTree = false;
                        if (curvedAnimation.value >= 0.25) {
                          currentDailyChallengeQuestsData =
                              newDailyChallengeQuestsData;
                          hasChangedTree = true;
                        }

                        return CustomPaint(
                          painter: TreePainter(
                            context: context,
                            dailyChallengeQuests:
                                currentDailyChallengeQuestsData,
                            animationProgress: areTheSame == true
                                ? 1 //Keep opacity to 1 if the arrays are the same
                                : hasChangedTree ==
                                        false //check if we are at the second part of the animation
                                    ? curvedAnimation.value > 0.15
                                        ? 1 -
                                            (curvedAnimation.value *
                                                2.5) //only for opacity
                                        : 1
                                    : curvedAnimation.value,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (int i = 0;
                                  i < newDailyChallengeQuestsData.length;
                                  i++)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 11.5),
                                  child: Container(
                                      key: i == 0
                                          ? user.keys[15]
                                          : i == 1
                                              ? user.keys[16]
                                              : null,
                                      child: DailyChallengeItem(
                                        name: newDailyChallengeQuestsData[i]
                                            ["name"],
                                        completed:
                                            newDailyChallengeQuestsData[i]
                                                ["completed"],
                                        isActive: newDailyChallengeQuestsData[i]
                                            ["active"],
                                        wasActive: oldDailyChallengeData[i]
                                            ["active"],
                                        reward: newDailyChallengeQuestsData[i]
                                            ["reward"],
                                        progress: newDailyChallengeQuestsData[i]
                                            ["progress"],
                                        goal: newDailyChallengeQuestsData[i]
                                            ["goalNb"],
                                        showAdButton:
                                            newDailyChallengeQuestsData[i]
                                                    ["goal"] ==
                                                "ad",
                                        oldProgress: oldDailyChallengeData
                                                    .where(
                                                      (q) =>
                                                          q["name"] ==
                                                          newDailyChallengeQuestsData[
                                                              i]["name"],
                                                    )
                                                    .toList()
                                                    .length >
                                                0 //Handle if quests are new ones
                                            ? oldDailyChallengeData[i]
                                                ["progress"]
                                            : 0,
                                      )),
                                )
                            ],
                          ),
                        );
                      });
                })
              ],
            )),
      ],
    );
  }
}
