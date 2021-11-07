import 'dart:math';

import 'package:flutter/material.dart';

import 'package:winhalla_app/config/themes/dark_theme.dart';
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
    final dailyChallengeQuests = [
      {
        "name": "Lorem",
        "goal": 3,
        "progress": 1,
        "completed": true,
        "active": false,
        "reward": 20
      },
      {
        "name": "Watch 1 ad or maybe not",
        "goal": 1,
        "progress": 0,
        "completed": true,
        "active": false,
        "reward": 30
      },
      {
        "name": "test",
        "goal": 1,
        "progress": 0,
        "completed": false,
        "active": true,
        "reward": 4
      },
      {
        "name": "test",
        "goal": 1,
        "progress": 0,
        "completed": false,
        "active": false,
        "reward": 4
      },
      {
        "name": "test mmmh",
        "goal": 1,
        "progress": 0,
        "completed": false,
        "active": false,
        "reward": 4
      },
    ];

    for (var quest in dailyChallengeQuests) {
      final textPainter = TextPainter(
        text: TextSpan(text: quest["name"] as String, style: kBodyText3),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
          maxWidth:
              138); //maxWidth needs to be set to: DailyChallengeItem maxWidth - DailyChallengeItem X padding
      List lines = textPainter.computeLineMetrics();
      quest["lineNumber"] = lines.length;
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Daily challenge:",
              style: kHeadline1,
            ),
            GestureDetector(
                // ignore: avoid_returning_null_for_void
                onTap: () => null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  decoration:
                      BoxDecoration(color: kBackgroundVariant, borderRadius: BorderRadius.circular(12)),
                  child: const Text(
                    "?",
                    style: TextStyle(fontFamily: "Roboto Condensed", color: kPrimary, fontSize: 32),
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
                CustomPaint(
                  painter: TreePainter(
                    dailyChallengeQuests: dailyChallengeQuests,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var quest in dailyChallengeQuests)
                        quest["completed"] as bool
                            ? 
                            Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 11.5),
                                    child: DailyChallengeItem(
                                      name: quest["name"] as String,
                                      completed: quest["completed"] as bool,
                                    ),
                                  )
                            : quest["active"] as bool
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 11.5),
                                    child: QuestWidget(
                                        name: quest["name"] as String,
                                        color: kOrange,
                                        progress: quest["progress"] as int,
                                        goal: quest["goal"] as int))
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
                                        SizedBox(width: 3.40),
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
                )
              ],
            )),
      ],
    );
  }
}
