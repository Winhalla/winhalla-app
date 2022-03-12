import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/utils/user_class.dart';

import 'inherited_text_style.dart';

class Coin extends StatelessWidget {
  final String nb;
  final Color color;
  final Color bgColor;
  final double fontSize;
  final double borderRadius;
  final double spacing;
  final EdgeInsetsGeometry padding;
  final GlobalKey? key1;
  const Coin({
    Key? key,
    required this.nb,
    this.color = kPrimary,
    this.bgColor = kBackgroundVariant,
    this.fontSize = 30,
    this.spacing = 6.25,
    this.borderRadius = 11,
    this.padding = const EdgeInsets.fromLTRB(21, 10.25, 21, 7.25),
    this.key1
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: bgColor, borderRadius: BorderRadius.circular(borderRadius)),
        padding: padding,
        child: Row(
          children: [
            Text(
                nb,
                style: InheritedTextStyle.of(context).kBodyText4.apply(fontSizeFactor: fontSize/20,color:color)
              ),
            SizedBox(
              width: spacing,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Image.asset(
                "assets/images/coin.png",
                key: key1,
                height: fontSize + 1.5,
                width: fontSize > 32 ? fontSize + 2 : fontSize,
                color: color
              ),
            ),
          ],
        ));
  }
}

String formatToLocalDateyMd(DateTime date){
  return DateFormat.yMd(Platform.localeName).format(date);
}