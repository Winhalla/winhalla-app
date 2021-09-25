import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/utils/userClass.dart';

class MyAppBar extends StatelessWidget {
  const MyAppBar();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(21, 20, 38, 5),
      color: kBackground,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
        IconButton(
          icon: const Icon(Icons.search),
          color: kText95,
          iconSize: 34,
          onPressed: () {},
        ),
        Row(children: <Widget>[
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined),
            color: kText95,
            iconSize: 35,
            onPressed: () {},
          ),
          const Padding(padding: EdgeInsets.only(right: 8)),
          Container(
            width: 55,
            height: 55,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Consumer<User>(builder: (context, user, _) {
                if (user.value==null) {
                  return Image.asset(
                    "assets/images/logo.png",
                  );
                } else {
                  return Image.network(
                    user.value["steam"]["picture"],
                  );
                }
              }),
            ),
          )
        ])
      ]),
    );
  }
}
