import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/utils/user_class.dart';

class Coin extends StatelessWidget {
  final String nb;
  final Color color;
  final Color bgColor;
  final double fontSize;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  const Coin({
    Key? key,
    required this.nb,
    this.color = kPrimary,
    this.bgColor = kBackgroundVariant,
    this.fontSize = 30,
    this.borderRadius = 11,
    this.padding = const EdgeInsets.fromLTRB(22, 9, 21.5, 6),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: bgColor, borderRadius: BorderRadius.circular(borderRadius)),
        padding: padding,
        child: Row(
          children: [
            Builder(builder: (context) {
              String text = "";
              try{
                text = double.parse(nb).floor().toString();
              }catch(e){
                text = "...";
              }
              return Text(
                text,
                style: TextStyle(color: color, fontSize: fontSize),
              );
            }),
            const SizedBox(
              width: 6.25,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Image.asset(
                "assets/images/coin.png",
                height: 30,
                width: 30,
                color: color
              ),
            ),
          ],
        ));
  }
}
