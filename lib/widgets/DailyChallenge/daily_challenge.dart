import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/src/provider.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/utils/user_class.dart';
import 'package:winhalla_app/widgets/quest_widget.dart';
import 'daily_challenge_item.dart';
import 'tree_painter.dart';

class DailyChallenge extends StatefulWidget {
  const DailyChallenge({Key? key}) : super(key: key);

  @override
  State<DailyChallenge> createState() => _DailyChallengeState();
}

class _DailyChallengeState extends State<DailyChallenge> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Daily challenge",
              style: kHeadline1,
            ),
            GestureDetector(
                // ignore: avoid_returning_null_for_void
                onTap: () => null,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(15, 9, 15, 6),
                  decoration:
                      BoxDecoration(color: kBackgroundVariant, borderRadius: BorderRadius.circular(11)),
                  child: Row(
                    children: [
                      Consumer<User>(
                        builder: (context, user, _) {
                          return Text(
                            user.value["user"]["dailyChallenge"]["challenges"].fold(0, (sum, item) => sum + item["reward"]).toString(),
                            style: kBodyText1.apply(color: kOrange),
                          );
                        }
                      ),
                      const SizedBox(width: 10,),

                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Image.asset("assets/images/CoinOrange.png",height: 30,width: 30,),
                      ),
                    ],
                  ),
                ))
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
                Consumer<User>(
                  builder: (context, user, _) {
                    final List dailyChallengeQuests = user.value["user"]["dailyChallenge"]["challenges"];
                    return CustomPaint(
                      painter: TreePainter(
                        dailyChallengeQuests: dailyChallengeQuests,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var quest in dailyChallengeQuests)
                            quest["completed"]
                                ?
                                Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 11.5),
                                        child: DailyChallengeItem(
                                          name: quest["name"],
                                          completed: quest["completed"],
                                        ),
                                      )
                                : quest["active"]
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 11.5),
                                        child: QuestWidget(
                                            reward: quest["reward"],
                                            name: quest["name"] ,
                                            color: kOrange,
                                            progress: quest["progress"],
                                            goal: quest["goalNb"],
                                            showAdButton: quest["goal"] == "ad"
                                        ),
                            )
                                    : Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 11.5),
                                        child: DailyChallengeItem(
                                          name: quest["name"] as String,
                                          completed: quest["completed"] as bool,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 21),
                                        child: Row(
                                          children: [
                                            Text(
                                              quest["reward"].toString(),
                                              style: kBodyText3,
                                            ),
                                            const SizedBox(width: 3.40),
                                            Image.asset(
                                              "assets/images/CoinText90.png",
                                              height: 25,
                                              width: 25,
                                            )
                                          ],
                                        ),
                                      ),
                                  ],)
                        ],
                      ),
                    );
                  }
                )
              ],
            )),
      ],
    );
  }
}
