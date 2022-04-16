import 'dart:math';

import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../config/themes/dark_theme.dart';
import '../utils/user_class.dart';
import 'inherited_text_style.dart';

class PaypalWarning extends StatefulWidget {
  final User user;

  const PaypalWarning({Key? key, required this.user}) : super(key: key);

  @override
  State<PaypalWarning> createState() => _PaypalWarningState();
}

class _PaypalWarningState extends State<PaypalWarning> {
  bool isOpened = false;
  bool visible = false;

  @override
  void initState() {
    super.initState();
    if (widget.user.value["user"]["brawlhallaAccounts"][0]["platformId"] != "steam" ||
        widget.user.value["user"]["brawlhallaAccounts"].length != 1) {
      visible = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (visible) {
      return MaterialButton(
        padding: EdgeInsets.fromLTRB(6.w, 2.h, 6.w, isOpened ? 3.h : 2.h+4),
        color: kBackgroundVariant,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        onPressed: () {
          setState(() {
            isOpened = !isOpened;
          });
        },
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.warning_rounded, color: kOrange, size: InheritedTextStyle.of(context).kHeadline2.fontSize),
                /*SizedBox(
                  width: 2.w,
                ),*/
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    "CONSOLE/MOBILE PLAYER",
                    style: InheritedTextStyle.of(context).kBodyText3.apply(fontSizeFactor: 0.9),
                  ),
                ),
                /*SizedBox(
                  width: 3.w,
                ),*/
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Transform.rotate(
                      angle: isOpened ? 180 * pi / 180 : 0,
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: kText90,
                        size: InheritedTextStyle.of(context).kBodyText1.fontSize,
                      )),
                )
              ],
            ),
            if (isOpened)
              SizedBox(
                height: 2.h,
              ),
            if (isOpened)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 1.w),
                child: RichText(
                  text: TextSpan(
                      style: InheritedTextStyle.of(context).kBodyText3.apply(color: kGray, fontSizeFactor: 0.8),
                      children: const [
                        TextSpan(
                          text:
                              "As we are still not able to provide reward codes for console and mobile players, we recommend you to redeem for Paypal Credit, which you can use to ",
                        ),
                        TextSpan(
                          text: "redeem",
                          style: TextStyle(decoration: TextDecoration.underline),
                        ),
                        TextSpan(
                          text: " any reward ",
                        ),
                        TextSpan(
                          text: "directly",
                          style: TextStyle(decoration: TextDecoration.underline),
                        ),
                        TextSpan(text: " on "),
                        TextSpan(
                          text: "your platform",
                          style: TextStyle(decoration: TextDecoration.underline),
                        ),
                      ]),
                ),
                /*Text(
              "As we are still not able to provide reward codes for console and mobile players, we recommend you to redeem for Paypal Credit, which you can use to redeem any reward directly on your platform.",
              style: InheritedTextStyle.of(context).kBodyText3.apply(color: kGray, fontSizeFactor: 0.8),
            ),*/
              ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }
}
