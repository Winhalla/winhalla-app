import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';

class QuestWidget extends StatelessWidget {
  final String name;
  Color color;
  final int progress;
  final int goal;
  final int reward;

  QuestWidget({
    Key? key,
    required this.name,
    required this.color,
    required this.progress,
    required this.goal,
    required this.reward
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isQuestFinished = progress >= goal;
    if (isQuestFinished) color = kGreen;

    double percentage = progress / goal * 100;

    return Container(
      decoration: BoxDecoration(color: kBackgroundVariant, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.fromLTRB(30, 18, 20, 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 175,
                child: Text(
                  name,
                  style: isQuestFinished
                      ? const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          decorationThickness: 2,
                          color: kGray,
                          fontSize: 24,
                          fontFamily: "Roboto Condensed")
                      : kBodyText2,
                ),
              ),
              const Padding(padding: EdgeInsets.only(top: 10)),
                Text(
                  !isQuestFinished ? "$progress/$goal" : "Click to collect",
                  style: kBodyText4.apply(color: color),
                )
            ],
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color:kBlack
            ),
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 10),
            child: Column(
              children: [
                Stack(
                  children: [
                    SizedBox(
                        width: 70,
                        height: 70,
                        child: CustomPaint(
                          foregroundPainter: ProgressPainter(progressColor: color, percentage: percentage + 0.6, width: 9),
                        ),
                    ),
                    Positioned.fill(
                        child: Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 2), //add padding to center the font that has default bottom spacing
                              child: Text("${isQuestFinished? 100: percentage.ceil()}%", style: kBodyText4.apply(color: color)),
                            ))),
                  ],
                ),
                const SizedBox(height: 11.5,),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(reward.toString() ,style: kBodyText4.apply(color:color),),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 1),
                        child: Image.asset(
                          "assets/images/coin.png",
                          height: 20,
                          width: 20,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ProgressPainter extends CustomPainter {
  Color progressColor;
  double percentage;
  double width;

  ProgressPainter({required this.progressColor, required this.percentage, required this.width});

  @override
  void paint(Canvas canvas, Size size) {
    /*Paint line = Paint()
      ..color = kBackgroundVariant
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
*/
    Paint progress = Paint()
      ..color = progressColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width - 1.9;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2.35, size.height / 2.35);

    //canvas.drawCircle(center, radius, line);

    double arcAngle = 2 * pi * (percentage / 100);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2, arcAngle, false, progress);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
