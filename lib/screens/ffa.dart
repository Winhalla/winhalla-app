import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:provider/provider.dart';
import 'package:winhalla_app/utils/ffaMatchClass.dart';
import 'package:http/http.dart' as http;
import 'package:winhalla_app/utils/getUri.dart';

class SoloMatch extends StatelessWidget {
  const SoloMatch({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40, 50, 40, 0),
          child: Center(
              child: FutureBuilder(
                  future: http.get(Uri.parse("https://jsonplaceholder.typicode.com/todos/1")),
                  builder: (dynamic context, AsyncSnapshot<http.Response> res) {
                    return ChangeNotifierProvider<FfaMatch>(
                        create: (_) => new FfaMatch(res.hasData ? jsonDecode(res.data!.body) : null),
                        child: Column(children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text('Solo Match', style: kHeadline1),
                              ),
                              Container(
                                  decoration: BoxDecoration(color: kBackgroundVariant, borderRadius: BorderRadius.circular(11)),
                                  padding: const EdgeInsets.fromLTRB(25, 9, 25, 6),
                                  child: Text(
                                    "28:36",
                                    style: TextStyle(color: kPrimary, fontSize: 35),
                                  )),
                            ],
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          ),
                          SizedBox(height: 35,),
                          Container(
                            padding: EdgeInsets.fromLTRB(25, 20, 19, 20),
                              child: Row(
                                children: [
                                  Row(
                                    children: [
                                      Text("x4", style: TextStyle(color: kGreen, fontSize: 35)),
                                      SizedBox(width: 6,),
                                      Text(
                                        "Reward",
                                        style: TextStyle(color: kText, fontSize: 25),
                                      )
                                    ],
                                  ),
                                  Container(
                                      padding:EdgeInsets.fromLTRB(19, 9, 19, 6),
                                      child: Text("Boost it",style: kBodyText4.apply(color: kBackground),),
                                      decoration: BoxDecoration(color: kGreen, borderRadius: BorderRadius.circular(12)))
                                ],
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              ),
                              decoration: BoxDecoration(color: kBackgroundVariant, borderRadius: BorderRadius.circular(20))),
                        ]));
                  })),
        ),
      ),
    );
  }
}
