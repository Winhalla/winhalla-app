import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/utils/user_class.dart';
import 'package:winhalla_app/widgets/DailyChallenge/daily_challenge.dart';

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
        Row(children: [
          const Padding(
            padding: EdgeInsets.only(top: 4.0),
            child: Text("Balance:",style: kHeadline1,),
          ),
          const SizedBox(width: 25,),
          GestureDetector(
            onTap: () => widget.switchPage(3),
            child: Container(
                decoration: BoxDecoration(
                    color: kBackgroundVariant,
                    borderRadius: BorderRadius.circular(11)),
                padding: const EdgeInsets.fromLTRB(20, 9, 20, 6),
                child: Row(
                  children: [
                    Consumer<User>(
                      builder: (context, user, _) {
                        return Text(
                          user.value["user"]["coins"].toString(),
                          style: kBodyText1.apply(color: kPrimary),
                        );
                      }
                    ),

                    const SizedBox(width: 10,),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Image.asset("assets/images/coin.png",height: 30,width: 30,),
                    ),
                  ],
                )),
          ),
          /*GestureDetector(
            onTap: () {
              print("test");
              widget.switchPage(3);
            },
            child: Consumer<User>(
              builder: (context, user, _) {
                if(user.value["user"]?["goal"]?["name"] == null) {
                  return Container();
                }
                return Stack(
                  children: [
                    Container(
                        decoration: BoxDecoration(
                            color: kBackgroundVariant,
                            borderRadius: BorderRadius.circular(11)),
                        padding: const EdgeInsets.fromLTRB(19, 9, 19, 6),
                        child: Text(
                          user.value["user"]["goal"]["name"],
                          style: kBodyText1.apply(color: kOrange),
                        )),
                    Positioned(
                        left: 19,
                        bottom: 0,
                        right: 19,
                        child: LinearProgressIndicator(
                            value:(user.value["user"]["coins"]/user.value["user"]["goal"]["cost"])+0.02,
                            valueColor: const AlwaysStoppedAnimation(kOrange),
                            backgroundColor: kBackgroundVariant,
                          )
                    )
                  ],
                );
              }
            ),
          )*/
        ]),
        const SizedBox(
          height: 50,
        ),
        const DailyChallenge()
      ],
    );
  }
}
