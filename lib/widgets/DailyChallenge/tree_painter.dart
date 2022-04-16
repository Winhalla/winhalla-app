import 'dart:math';

import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';

import '../inherited_text_style.dart';

class TreePainter extends CustomPainter {
  final List dailyChallengeQuests;
  final animationProgress;
  final BuildContext context;
  TreePainter({
    required this.dailyChallengeQuests,
    required this.animationProgress,
    required this.context,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final List dailyChallengeQuestsCopy = List.from(dailyChallengeQuests);

    Paint line = Paint()
      ..color = kText90.withOpacity(animationProgress.toDouble())
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    double degToRad(num deg) => deg * (pi / 180.0);

    double currentHeight = 3.h + 3.h + 2.h + 1.5.h + 20.w + 54.5;
    double currentWidth = size.width - 65;

    Path path = Path();

    void drawBottomTree() {
      //path.moveTo(currentWidth, currentHeight);

      dailyChallengeQuestsCopy.removeAt(0);

      currentHeight = currentHeight + 3;

      for (var quest in dailyChallengeQuestsCopy) {
        final TextSpan textSpan = TextSpan(
            text: quest["name"],
            style: InheritedTextStyle.of(context).kBodyText3,
        );
        final TextPainter textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        double rectSize = 11.5 + 14 +  textPainter.height/2;
        path.arcTo(
            Rect.fromLTWH(
                currentWidth - rectSize - 0.15,
                currentHeight,
                rectSize, // -0.15 just for pixel perfect
                rectSize),
            degToRad(0),
            degToRad(90),
            false);

        path.lineTo(20 + (currentWidth - currentWidth * animationProgress),
            currentHeight + rectSize);
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
        final TextSpan textSpan = TextSpan(
          text: quest["name"],
          style: InheritedTextStyle.of(context).kBodyText3,
        );
        final TextPainter textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(maxWidth: 130);
        double rectSize = 11.5 + 14 +  textPainter.height/2;
        if (!quest["active"]) {
          path.moveTo(20 + (currentWidth - currentWidth * animationProgress),
              currentHeight);
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
          currentHeight += 3.h + 3.h + 2.h + 1.5.h + 20.w + 15;
          path.lineTo(currentWidth, currentHeight - 2);
          return drawBottomTree();
        }
      }
    }

    //Decide which part of the tree to paint
    if (dailyChallengeQuests[0]["active"]) {
      drawBottomTree();
    } else {
      final TextSpan textSpan = TextSpan(
        text: dailyChallengeQuests[0]["name"],
        style: InheritedTextStyle.of(context).kBodyText3,
      );
      final TextPainter textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(maxWidth: 130);
      currentHeight = 11.5 + 14 +  textPainter.height/2;
      drawTopTree();
    }

    //Draw the tree
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant TreePainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress;
  }
}
