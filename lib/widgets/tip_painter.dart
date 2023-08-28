import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';

class TipPainter extends CustomPainter {
  TipPainter({required this.color, this.height = 0});

  final Color color;
  final int height;

  double degToRad(num deg) => (deg * (pi / 180.0)).toDouble();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kText80
    // ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    double rectSize = 30;

    Path path = Path();
    path.moveTo(0, 0);

    path.arcTo(
        Rect.fromLTWH(
            0,
            -7,
            rectSize,
            rectSize),
        degToRad(180),
        degToRad(-90),
        false);
    path.lineTo(23, 23);
    // path.lineTo(20, currentHeight + rectSize);
    path.moveTo(0, 10);

    path.arcTo(
        Rect.fromLTWH(
            0,
            85.0+height,
            rectSize, // -0.15 just for pixel perfect
            rectSize),
        degToRad(180),
        degToRad(-90),
        false);
    path.lineTo(23, 115.0+height);
    canvas.drawPath(path, paint);
  }

  //5
  @override
  bool shouldRepaint(TipPainter oldDelegate) {
    return color != oldDelegate.color;
  }
}