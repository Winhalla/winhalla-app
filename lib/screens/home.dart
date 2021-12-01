import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/utils/user_class.dart';
import 'package:winhalla_app/widgets/DailyChallenge/daily_challenge.dart';
import 'package:winhalla_app/widgets/coin.dart';

class MyHomePage extends StatefulWidget {
  final switchPage;
  const MyHomePage({Key? key, required this.switchPage}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 4.0),
              child: Text(
                "Balance:",
                style: kHeadline1,
              ),
            ),
            const SizedBox(
              width: 25,
            ),
            GestureDetector(
                onTap: () => widget.switchPage(3),
                child: Consumer<User>(builder: (context, user, _) {
                  return Coin(
                    nb: ((user.value["user"]["coins"]*10).round()/10).toString(),
                  );
                },
              ),
            ),
          ]
        ),
        const SizedBox(
          height: 50,
        ),
        const DailyChallenge()
      ],
    );
  }
}
