import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/utils/user_class.dart';
import 'package:winhalla_app/widgets/DailyChallenge/daily_challenge.dart';
import 'package:winhalla_app/widgets/ad_launch_button.dart';
import 'package:winhalla_app/widgets/coin.dart';
import 'package:winhalla_app/widgets/inherited_text_style.dart';
import 'package:winhalla_app/widgets/quick_earn_ad_prompt.dart';

class MyHomePage extends StatefulWidget {
  final switchPage;

  const MyHomePage({Key? key, required this.switchPage}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isDailyChallengeShown = true;

  void rebuildHomePage() {
    setState(() {
      isDailyChallengeShown = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    context.read<User>().setKeyFx(rebuildHomePage, "rebuildHomePage");
    if (isDailyChallengeShown == false) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        setState(() {
          isDailyChallengeShown = true;
        });
      });
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(children: [
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              "Balance:",
              style: InheritedTextStyle.of(context).kHeadline1,
            ),
          ),
          const SizedBox(
            width: 25,
          ),
          GestureDetector(
            onTap: () => widget.switchPage(3),
            child: Consumer<User>(
              builder: (context, user, _) {
                return Coin(
                  nb: ((user.value["user"]["coins"] * 10).round() / 10).toString(),
                );
              },
            ),
          ),
        ]),
        const SizedBox(
          height: 40,
        ),
        const QuickEarnAdPrompt(),
        if (isDailyChallengeShown) const DailyChallenge()
      ],
    );
  }
}
