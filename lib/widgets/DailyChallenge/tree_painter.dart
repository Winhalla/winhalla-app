import 'dart:math';
import 'package:flutter/material.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';

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
