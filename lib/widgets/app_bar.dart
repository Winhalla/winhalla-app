import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/widgets/login/google_apple_login.dart';
import 'package:winhalla_app/utils/services/secure_storage_service.dart';
import 'package:winhalla_app/utils/user_class.dart';
import 'package:winhalla_app/widgets/account_edit_warning.dart';
import 'package:winhalla_app/widgets/popup_leave_match.dart';
import 'package:winhalla_app/widgets/popup_legal.dart';
import 'package:winhalla_app/widgets/popup_link.dart';

import 'inherited_text_style.dart';

class MyAppBar extends StatefulWidget {
  final bool isUserDataLoaded;
  final int currentPage;

  const MyAppBar(this.isUserDataLoaded, this.currentPage);

  @override
  State<MyAppBar> createState() => _MyAppBarState();
}

class _MyAppBarState extends State<MyAppBar> {
  int rebuilds = 0;
  void rebuildNavbar(){
    setState(() {
      rebuilds++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: context.read<User>().appBarKey,
      padding: EdgeInsets.fromLTRB(30, 3.5.h, 38, 3.5.h),
      color: kBackground,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <
          Widget> [
            if (widget.currentPage == 2)
              Consumer<User>(builder: (context, user, _) {
                user.setKeyFx(rebuildNavbar, "rebuildNavbar");
                if (user.inGame == null || user.inGame["joinDate"] + 3600 * 1000 < DateTime.now().millisecondsSinceEpoch || user.inGame["isShown"] == false) {
                  return const Text("");
                }

                if (user.gamesPlayedInMatch > 0) {
                  return Row(
                    children: [
                      GestureDetector(
                        onTap: (){
                          user.exitMatch(
                              isBackButton: user.gamesPlayedInMatch < 7,
                              isOnlyLayout: user.gamesPlayedInMatch > 6,
                              isFromMatchHistory: user.inGame["isFromMatchHistory"] == true
                          );
                        },
                        child: Row(children: [
                          const Icon(
                            Icons.exit_to_app_rounded,
                            size: 30,
                            color: kPrimary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Back',
                            style: InheritedTextStyle.of(context).kBodyText3,
                          ),
                        ]),
                      ),
                      if(user.gamesPlayedInMatch > 6) const SizedBox(width: 15,),
                      if(user.gamesPlayedInMatch > 6) GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          user.enterMatch();
                        },
                        child: Row(
                          children: [
                            const Icon(
                              Icons.open_in_new_rounded,
                              size: 30,
                              color: kGreen,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'New match',
                              style: InheritedTextStyle.of(context).kBodyText3,
                            ),
                          ],
                        ),
                      )
                    ],
                  );
                }
                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () async {
                    bool shouldQuit = true;
                    if (await getNonNullSSData ("hideLeaveMatchPopup") != "true") {
                      shouldQuit = await showDialog(
                          context: context,
                          builder: (_) => LeaveMatchPopup()) ?? true;
                    }
                    if (shouldQuit) user.exitMatch();
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.exit_to_app_rounded,
                        size: 30,
                        color: kPrimary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Leave',
                        style: InheritedTextStyle.of(context).kBodyText3,
                      ),
                    ],
                  ),
                );
              }),
            const Text(""),
            GestureDetector(
              onTap: () {
                var user = context.read<User>().value;
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
                                      await GoogleSignInApi.logout();
                                      Navigator.pushReplacementNamed(
                                          context, "/login");
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
                                            style: InheritedTextStyle.of(context).kBodyText2.apply(
                                                fontFamily: "Bebas Neue"),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
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
                                            style: InheritedTextStyle.of(context).kBodyText2.apply(
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
                                            style: InheritedTextStyle.of(context).kBodyText2.apply(
                                                fontFamily: "Bebas Neue"),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(30, 0, 0, 10),
                                    width: 75,
                                    height: 1,
                                    color: kText80,
                                  ),
                                  GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () async {
                                      showDialog(
                                          context: context,
                                          builder: (_) => LegalInfoPopup());
                                      overlayEntry.remove();
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          28, 10, 24, 22),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.menu_book,
                                            color: kText80,
                                            size: 24,
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            "Legal",
                                            style: InheritedTextStyle.of(context).kBodyText3.apply(
                                                fontFamily: "Bebas Neue",
                                                color: kText80),
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
              child: widget.isUserDataLoaded
                  ? Consumer<User>(builder: (context, user, _) {
                      if (user.value == null) {
                        return Image.asset(
                          "assets/images/logoMini.png",
                        );
                      } else {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ClipRRect(
                              borderRadius:BorderRadius.circular(8),
                              child: Image.network(
                                user.value["steam"]["picture"],
                              ),
                            ),
                            Icon(Icons.arrow_drop_down, color: kText, size: 9.w,)
                          ],
                        );
                      }
                    })
                  : Image.asset(
                      "assets/images/logoMini.png",
                    ),
            ),
        ]
      ),
    );
  }
}
