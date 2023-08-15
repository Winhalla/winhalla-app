import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/utils/user_class.dart';
import 'package:winhalla_app/widgets/ad_launch_button.dart';
import 'package:winhalla_app/widgets/inherited_text_style.dart';

class QuickEarnAdPrompt extends StatefulWidget {
  const QuickEarnAdPrompt({Key? key}) : super(key: key);

  @override
  State<QuickEarnAdPrompt> createState() => _QuickEarnAdPromptState();
}

class _QuickEarnAdPromptState extends State<QuickEarnAdPrompt> {
  static const double luck = 25;
  bool show = false;
  int amount = 30;

  @override
  void initState() {
    super.initState();
    int nb = Random().nextInt(100);
    User user = context.read<User>();
    int now = DateTime.now().millisecondsSinceEpoch;
    if (nb < luck && user.lastAdPrompt + 600 * 1000 < now) {
      nb = Random().nextInt(100);
      show = true;
      if (nb > 66) amount = 60;
      if (nb > 90) amount = 100;
    }
  }

  @override
  Widget build(BuildContext context) {
    print(show);
    if (!show) return Container();
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
              color: kBackgroundVariant,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                  color: amount == 100
                      ? kRed
                      : amount == 60
                          ? kEpic
                          : kPrimary)),
          padding: const EdgeInsets.fromLTRB(30, 21, 11, 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "Get ",
                    style: InheritedTextStyle.of(context).kBodyText2bis,
                  ),
                  Text(
                    '$amount',
                    style: InheritedTextStyle.of(context).kBodyText1.apply(
                        color: amount == 100
                            ? kRed
                            : amount == 60
                                ? kEpic
                                : kPrimary),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3.0),
                    child: Image.asset("assets/images/coin.png",
                        height: 32,
                        color: amount == 100
                            ? kRed
                            : amount == 60
                                ? kEpic
                                : kPrimary),
                  ),
                ],
              ),
              Row(
                children: [
                  AdButton(
                      hideItself: () {
                        setState(() {
                          show = false;
                        });
                        context.read<User>().setLastAdPrompt(DateTime.now().millisecondsSinceEpoch);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(13),
                            color: amount == 100
                                ? kRed
                                : amount == 60
                                    ? kEpic
                                    : kPrimary),
                        padding: const EdgeInsets.fromLTRB(19, 9, 19, 9),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 1.5),
                              child: Image.asset(
                                "assets/images/video_ad.png",
                                width: 20,
                                color: kText80,
                              ),
                            ),
                            const SizedBox(
                              width: 7,
                            ),
                            Text(
                              "Watch",
                              style: InheritedTextStyle.of(context).kBodyText4.apply(color: kText80),
                            ),
                          ],
                        ),
                      ),adNotReadyChild: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(13),
                        color: kGray),
                    padding: const EdgeInsets.fromLTRB(19, 9, 19, 9),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 1.5),
                          child: Image.asset(
                            "assets/images/video_ad.png",
                            width: 20,
                            color: kText80,
                          ),
                        ),
                        const SizedBox(
                          width: 7,
                        ),
                        Text(
                          "Loading...",
                          style: InheritedTextStyle.of(context).kBodyText4.apply(color: kText80),
                        ),
                      ],
                    ),
                  ),
                      adErrorChild: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(13),
                            color: kGray),
                        padding: const EdgeInsets.fromLTRB(19, 9, 19, 9),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 1.5),
                              child: Image.asset(
                                "assets/images/video_ad.png",
                                width: 20,
                                color: kText80,
                              ),
                            ),
                            const SizedBox(
                              width: 7,
                            ),
                            Text(
                              "Watch",
                              style: InheritedTextStyle.of(context).kBodyText4.apply(color: kText80),
                            ),
                          ],
                        ),
                      ),

                      goal: "earnQuick$amount"),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      setState(() {
                        show = false;
                        context.read<User>().setLastAdPrompt(DateTime.now().millisecondsSinceEpoch);
                      });
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(
                        Icons.clear_outlined,
                        color: kText60,
                        size: 26,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 40,
        ),
      ],
    );
  }
}
