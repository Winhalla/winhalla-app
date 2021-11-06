import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/utils/user_class.dart';
import 'package:winhalla_app/widgets/popup_legal.dart';
import 'package:winhalla_app/widgets/popup_link.dart';

class MyAppBar extends StatelessWidget {
  final bool isUserDataLoaded;
  const MyAppBar(this.isUserDataLoaded);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(21, 30, 38, 24),
      color: kBackground,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
        GestureDetector(
          child: Image.asset("assets/images/icons/3_dots.png",color: kText95,height: 35,),
          onTap: (){
            showDialog(
              context: context,
              builder: (BuildContext context)=>LegalInfoWidget()
            );
          },
        ),
        SizedBox(
              width: 55,
              height: 55,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: GestureDetector(
                  onTap: () {
                    var linkId = context.read<User>().value["user"]["linkId"];
                    showDialog(context: context, builder: (BuildContext context)=>LinkInfoWidget(linkId));
                  },
                  child: isUserDataLoaded
                      ? Consumer<User>(builder: (context, user, _) {
                          if (user.value == null) {
                            return Image.asset(
                              "assets/images/logoMini.png",
                            );
                          } else {
                            return Image.network(
                              user.value["steam"]["picture"],
                            );
                          }
                        })
                      : Image.asset(
                          "assets/images/logoMini.png",
                        ),
                ),
              ),
            )
          ]),
    );
  }
}
