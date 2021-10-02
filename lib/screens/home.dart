import 'package:flutter/material.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/widgets/daily_challenge.dart';
import 'package:winhalla_app/widgets/quest_widget.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            GestureDetector(
              onTap: () => setState(() {}),
              child: Container(
                  decoration: BoxDecoration(
                      color: kBackgroundVariant,
                      borderRadius: BorderRadius.circular(11)),
                  padding: const EdgeInsets.fromLTRB(19, 9, 19, 6),
                  child: Text(
                    "5896",
                    style: kBodyText1.apply(color: kPrimary),
                  )),
            ),
            GestureDetector(
              onTap: () => setState(() {}),
              child: Stack(
                children: [
                  Container(
                      decoration: BoxDecoration(
                          color: kBackgroundVariant,
                          borderRadius: BorderRadius.circular(11)),
                      padding: const EdgeInsets.fromLTRB(19, 9, 19, 6),
                      child: Text(
                        "Battle Pass",
                        style: kBodyText1.apply(color: kEpic),
                      )),
                  Positioned(
                      left: 19,
                      bottom: 0,
                      child: Container(
                        height: 2,
                        width: 20,
                        color: kEpic,
                      ))
                ],
              ),
            )
          ]),
          const SizedBox(
            height: 65,
          ),
          const DailyChallenge()
        ],
      ),
    );
  }
}
