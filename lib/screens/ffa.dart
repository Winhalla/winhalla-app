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
      body: Center(
          child: FutureBuilder(
            future:http.get(getUri("/getMatch/613e57a522d5937857affe65")),
            builder:(dynamic context, AsyncSnapshot<http.Response> res){
              return ChangeNotifierProvider<FfaMatch>(
                create: (_) => new FfaMatch(res.hasData?jsonDecode(res.data!.body):null),
                child: Column(children:[
                  Row(children:[
                    Text('Solo Match',style:kHeadline1),
                    Container(
                      child:Text("28:36"),
                      decoration:BoxDecoration(
                        color: kBackgroundVariant,
                        borderRadius: BorderRadius.circular(11)
                    ),
                    )
                  ]),

                ])
              );
            }
      )),
    );
  }
}
