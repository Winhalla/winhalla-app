import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:provider/provider.dart';
import 'package:winhalla_app/utils/ffaMatchClass.dart';
import 'package:http/http.dart' as http;
import 'package:winhalla_app/utils/getUri.dart';
import 'package:winhalla_app/utils/userClass.dart';

class SoloMatch extends StatelessWidget {
  const SoloMatch({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(40, 50, 40, 0),
            child: Center(

                child: FutureBuilder(
                    future: http.get(Uri.parse("https://jsonplaceholder.typicode.com/todos/1")),
                    builder: (dynamic context, AsyncSnapshot<http.Response> res) {

                      return ChangeNotifierProvider<FfaMatch>(
                          create: (_) => FfaMatch(res.hasData ? jsonDecode(res.data!.body) : null),
                          child: Column(children: [
                            Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 5),
                                  child: Text('Solo Match', style: kHeadline1),
                                ),
                                Container(
                                    decoration: BoxDecoration(color: kBackgroundVariant, borderRadius: BorderRadius.circular(14)),
                                    padding: const EdgeInsets.fromLTRB(25, 9, 25, 6),
                                    child: const Text(
                                      "28:36",
                                      style: TextStyle(color: kPrimary, fontSize: 35),
                                    )),
                              ],
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            ),

                            const SizedBox(
                              height: 35,
                            ),
                            
                            Container(
                              padding: EdgeInsets.fromLTRB(30, 20, 30, 20),
                              child: Row(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: const [
                                      Text("x4", style: TextStyle(color: kGreen, fontSize: 34)),
                                      SizedBox(
                                        width: 9,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 3.12),
                                        child: Text(
                                          "Reward",
                                          style: TextStyle(color: kText, fontSize: 25),
                                        ),
                                      )
                                    ],
                                  ),
                                  Container(
                                      padding: EdgeInsets.fromLTRB(19, 11.5, 19, 8.5),
                                      child: Text(
                                        "Boost it",
                                        style: kBodyText4.apply(color: kBackground),
                                      ),
                                      decoration: BoxDecoration(color: kGreen, borderRadius: BorderRadius.circular(12)))
                                ],
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              ),
                              decoration: BoxDecoration(color: kBackgroundVariant, borderRadius: BorderRadius.circular(20)),
                            ),


                            const SizedBox(
                              height: 60,
                            ),

                            PlayerWidget(true), //PLAYER

                            const SizedBox(
                              height: 56,
                            ),

                            Column(
                              children: [
                                ListView.builder(
                                  itemBuilder: (context, int index) {
                                    if(index.isOdd) return const SizedBox(height: 39); //Spacing between each player card
                                    return PlayerWidget(false);
                                  },
                                  itemCount: 7*2,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                )
                              ],
                            )
                          ]));
                    })),
          ),
        ),
      ),
    );
  }
}

class PlayerWidget extends StatelessWidget {
  PlayerWidget(this.isUser);

  final bool isUser;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(35,  isUser ? 25 : 18, 35,  isUser ? 25 : 18),
          child: Row(
            children: [

              SizedBox(
                width: isUser ? 72 : 60,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Image.network(
                    "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/da/da77bb66176e79e92a34eae1b2a492b0b6f37e07_full.jpg",
                  ),
                ),
              ),
              Column(
                children: [
                  Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 1.5),
                        child: Text(
                          "Games played:",
                          style: TextStyle(color: kText, fontSize: 22),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        "3/7",
                        style: TextStyle(color: isUser ? kEpic : kPrimary, fontSize: 26),
                      )
                    ],
                    crossAxisAlignment: CrossAxisAlignment.end,
                  ),

                  const SizedBox(
                    height: 2.5,
                  ),

                  if (isUser == true) Row(
                    children: const [
                        Padding(
                          padding: EdgeInsets.only(bottom: 1.5),
                          child: Text("Games won:", style: TextStyle(color: kText, fontSize: 22)),
                        ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "2/7",
                        style: TextStyle(color: kEpic, fontSize: 26),
                      )
                    ],
                    crossAxisAlignment: CrossAxisAlignment.end,
                  )
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          ),
          decoration: BoxDecoration(
            color: kBackgroundVariant,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        Positioned(
          left: 35,
          bottom: isUser? 110 : 83.5,
          child: const Text("Philtrom", style: TextStyle(color: kGray, fontSize: 19)),
        ),
      ],
      clipBehavior: Clip.none,
    );
  }
}
