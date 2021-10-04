import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/widgets/quest_widget.dart';

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
        "active": false
      },
      {
        "name": "Watch 1 ad or maybe not",
        "goal": 1,
        "progress": 0,
        "completed": true,
        "active": false
      },
      {
        "name": "test",
        "goal": 1,
        "progress": 0,
        "completed": false,
        "active": true
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  decoration: BoxDecoration(
                      color: kBackgroundVariant,
                      borderRadius: BorderRadius.circular(12)),
                  child: const Text(
                    "?",
                    style: TextStyle(
                        fontFamily: "Roboto Condensed",
                        color: kPrimary,
                        fontSize: 32),
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
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 11.5),
                                child: DailyChallengeItem(
                                  name: quest["name"] as String,
                                  completed: quest["completed"] as bool,
                                ),
                              )
                            : quest["active"] as bool
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 11.5),
                                    child: QuestWidget(
                                        name: quest["name"] as String,
                                        color: kOrange,
                                        progress: quest["progress"] as int,
                                        goal: quest["goal"] as int))
                                : Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 11.5),
                                    child: DailyChallengeItem(
                                      name: quest["name"] as String,
                                      completed: quest["completed"] as bool,
                                    ),
                                  ),
                    ],
                  ),
                )
              ],
            )),
      ],
    );
  }
}

class DailyChallengeItem extends StatelessWidget {
  final String name;
  final bool completed;
  const DailyChallengeItem({
    Key? key,
    required this.name,
    required this.completed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 24),
      color: kBackground,
      child: Container(

          /*constraints: const BoxConstraints(
              maxWidth: 205),*/ //MAX WIDTH - X PADDING = maxWidth - 53
          padding: EdgeInsets.fromLTRB(26, 14, completed ? 23 : 27, 14),
          decoration: BoxDecoration(
              color: kBackgroundVariant,
              borderRadius: BorderRadius.circular(12)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 130),
                child: Text(
                  name,
                  style:
                      completed ? kBodyText3.apply(color: kText80) : kBodyText3,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              if (completed)
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: kText80,
                )
            ],
          )),
    );
  }
}

class TreePainter extends CustomPainter {
  final List dailyChallengeQuests;

  TreePainter({
    required this.dailyChallengeQuests,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final List dailyChallengeQuestsCopy = List.from(dailyChallengeQuests);

    Paint line = Paint()
      ..color = kText90
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    double degToRad(num deg) => deg * (pi / 180.0);

    double rectSize = 45;
    double currentHeight = 138;
    double currentWidth = size.width - 65;

    Path path = Path();


    void drawBottomTree() {
      path.moveTo(currentWidth, currentHeight);
      dailyChallengeQuestsCopy.removeAt(0);

      currentHeight = currentHeight + 3;

      for (var quest in dailyChallengeQuestsCopy) {
        path.arcTo(
            Rect.fromLTWH(
                currentWidth - rectSize - 0.15,
                currentHeight,
                rectSize, // -0.15 just for pixel perfect
                rectSize),
            degToRad(0),
            degToRad(90),
            false);

        path.lineTo(20, currentHeight + rectSize);
        path.moveTo(currentWidth, currentHeight);

        //Go to next position
        currentHeight += quest["lineNumber"] == 1
            ? 73
            : quest["lineNumber"] == 2
                ? 73 + 24
                : 73 + 46;
      }
    }

    void drawTopTree() {
      for (var quest in List.from(dailyChallengeQuestsCopy)) {

        if (!quest["active"]) { 
          path.moveTo(20, currentHeight);
          path.lineTo(currentWidth - rectSize, currentHeight);

          path.arcTo(
              Rect.fromLTWH(
                  currentWidth - rectSize - 0.15,
                  currentHeight,
                  rectSize, // -0.15 just for pixel perfect
                  rectSize),
              degToRad(-90),
              degToRad(90),
              false);

          //Go to next position
          currentHeight += quest["lineNumber"] == 1
              ? 73
              : quest["lineNumber"] == 2
                  ? 73 + 24
                  : 73 + 46;

          path.lineTo(currentWidth - 0.15, currentHeight + rectSize);


          dailyChallengeQuestsCopy.remove(quest);

        } else {
          currentHeight += 100;
          return drawBottomTree();
        }
      }
    }

    //Decide which part of the tree to paint
    if (dailyChallengeQuests[0]["active"]) {
      drawBottomTree();
    } else {
      currentHeight = 38;
      drawTopTree();
    }

    //Draw the tree
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant TreePainter oldDelegate) {
    return false;
  }
}
