import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';

class QuestWidget extends StatelessWidget {
  String name;
  Color color;
  int progress;
  int goal;

  QuestWidget(
      {Key? key,
      required this.name,
      required this.color,
      required this.progress,
      required this.goal})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    double percentage = progress / goal * 100;

    return Container(
      decoration: BoxDecoration(
          color: kBackgroundVariant, borderRadius: BorderRadius.circular(16)),
      padding: EdgeInsets.fromLTRB(30, 27, 30, 27),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: kBodyText2,
              ),
              const Padding(padding: EdgeInsets.only(top: 10)),
              Text(
                "$progress/$goal",
                style: kBodyText4.apply(color: color),
              )
            ],
          ),
          Stack(
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: 
                  CustomPaint(
                  foregroundPainter: ProgressPainter(
                    progressColor: color, 
                    percentage: percentage, 
                    width: 9
                  ),
                )
              ),
              Positioned.fill(
                  child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top:
                                2), //add padding to center the font that has default bottom spacing
                        child: Text("${percentage.round()}%",
                            style: kBodyText4.apply(color: color)),
                      ))),
              
            ],
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

  ProgressPainter(
      {required this.progressColor,
      required this.percentage,
      required this.width});

  @override
  void paint(Canvas canvas, Size size) {

    Paint line = Paint()
      ..color = kBackground
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;

    Paint progress = Paint()
      ..color = progressColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2);

    canvas.drawCircle(center, radius, line);

    double arcAngle = 2 * pi * (percentage / 100);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2,
        arcAngle, false, progress);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
