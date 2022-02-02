import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/screens/shop.dart';
import 'package:winhalla_app/widgets/inherited_text_style.dart';
import 'package:winhalla_app/widgets/tip_painter.dart';

class OrderProgressPainter extends CustomPainter {
  OrderProgressPainter(this.context);
  final BuildContext context;

  TextPainter renderText(i){
    final textSpan = TextSpan(
        text: kOrdersStatuses[i],
        style: InheritedTextStyle.of(context).kBodyText4.apply(fontSizeFactor: 0.9)
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter;
  }

  double degToRad(num deg) => (deg * (pi / 180.0)).toDouble();
  final num lineLength = 4.2;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kGray
      ..style = PaintingStyle.fill
      ..strokeWidth = 3;
    final paintPrimary = Paint()
      ..color = kPrimary
      ..style = PaintingStyle.fill
      ..strokeWidth = 3;
    /*final paint = Paint()
      ..color = kText80
    // ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;*/
    final textSpan = TextSpan(
        text: "You",
        style: InheritedTextStyle.of(context).kBodyText4.apply(fontSizeFactor: 0.8)
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    canvas.drawCircle(const Offset(0,0), 1.h, paint);
    TextPainter text = renderText(0);
    text.paint(canvas, Offset(10.w, -text.height/2.5));
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(Offset(0, (i * lineLength).h), Offset(0, ((i + 1) * lineLength).h), paint);
      canvas.drawCircle(Offset(0, ((i + 1) * lineLength).h), 1.h, paint);
      TextPainter text = renderText(i+1);
      text.paint(canvas, Offset(10.w, ((i + 1) * lineLength).h-text.height/2.5));
      if(i == 0){
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(
                    11.w+text.width,
                    ((i + 1) * lineLength).h-textPainter.height/2.8-0.25.h-1,
                    textPainter.width+6.w,
                    textPainter.height+0.5.h
                ),
                const Radius.circular(7)
            ),
            paintPrimary,
        );
        textPainter.paint(canvas, Offset(14.w+text.width, ((i + 1) * lineLength).h-textPainter.height/2.8));
      }
    }
  }

  //5
  @override
  bool shouldRepaint(OrderProgressPainter oldDelegate) {
    return false;
  }
}

