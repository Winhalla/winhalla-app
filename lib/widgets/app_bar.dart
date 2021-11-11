import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/screens/login.dart';
import 'package:winhalla_app/utils/services/secure_storage_service.dart';
import 'package:winhalla_app/utils/user_class.dart';
import 'package:winhalla_app/widgets/account_edit_warning.dart';
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
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <
          Widget>[
        GestureDetector(
          child: Image.asset(
            "assets/images/icons/3_dots.png",
            color: kText95,
            height: 35,
          ),
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext context) => LegalInfoWidget());
          },
        ),
        SizedBox(
          width: 55,
          height: 55,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: GestureDetector(
              onTap: () {
                var user = context.read<User>().value;
                print(user["user"]);
                var linkId = user["user"]["linkId"];
                var accounts = user["user"]["brawlhallaAccounts"];
                late OverlayEntry overlayEntry;
                overlayEntry = OverlayEntry(
                  builder: (context) {
                    return DefaultTextStyle(
                      style: const TextStyle(fontFamily: "Bebas neue"),
                      child: Stack(
                        children: [
                          Positioned.fill(
                              child: GestureDetector(
                            onTapDown: (_) {
                              overlayEntry.remove();
                            },
                            child: Container(
                              color: Colors.transparent,
                            ),
                          )),
                          Positioned(
                            top: 125,
                            right: 20,
                            child: Container(
                              decoration: BoxDecoration(
                                color: kBackgroundVariant,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(0.8), //color of shadow
                                    spreadRadius: 5, //spread radius
                                    blurRadius: 8, // blur radius
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () async {
                                      await secureStorage.write(
                                          key: "authKey", value: null);
                                      Navigator.pop(context);
                                      await Future.delayed(
                                          const Duration(milliseconds: 150));
                                      Navigator.pushNamed(context, "/login");
                                      overlayEntry.remove();
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          24, 19, 24, 0),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.logout,
                                            color: kRed,
                                            size: 30,
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            "Logout",
                                            style: kBodyText2.apply(
                                                fontFamily: "Bebas Neue"),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      print(accounts);
                                      showDialog(
                                          builder: (_) =>
                                              AccountEditWarning(accounts),
                                          context: context);
                                      overlayEntry.remove();
                                    },
                                    behavior: HitTestBehavior.translucent,
                                    child: Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          24, 15, 24, 15),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.add_circle_outline,
                                            color: kPrimary,
                                            size: 30,
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            "Add Account",
                                            style: kBodyText2.apply(
                                                fontFamily: "Bebas Neue"),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () async {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              LinkInfoWidget(linkId));
                                      await Future.delayed(
                                          const Duration(milliseconds: 100));
                                      overlayEntry.remove();
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          24, 0, 24, 19),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.share,
                                            color: kOrange,
                                            size: 30,
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            "Referral link",
                                            style: kBodyText2.apply(
                                                fontFamily: "Bebas Neue"),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
                Overlay.of(context)?.insert(overlayEntry);
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
