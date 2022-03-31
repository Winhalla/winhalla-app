import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:steam_login/steam_login.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/utils/custom_http.dart';
import 'package:winhalla_app/utils/get_uri.dart';
import 'package:winhalla_app/utils/services/secure_storage_service.dart';
import '../../screens/login.dart';
import '../info_dropdown.dart';
import '../inherited_text_style.dart';
import '../popup.dart';
import '../popup_link.dart';
import 'google_apple_login.dart';

class AccountCreation extends StatefulWidget {
  final accounts;
  final bool stepOverriden;
  final Uri? steamLoginUri;
  const AccountCreation({Key? key, this.accounts, this.stepOverriden = false, this.steamLoginUri}) : super(key: key);

  @override
  _AccountCreationState createState() => _AccountCreationState();
}

class _AccountCreationState extends State<AccountCreation> {
  List<dynamic> accounts = [];
  Map<String, dynamic>? gAccount;
  String? steamId;
  bool hasAddedSteamAccount = false;
  bool alreadyCreatedAccount = false;
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  List<Map<String, String>> items = [
    {'name': "Steam (PC)", "platformId": "steam"},
    {'name': "PS3/4/5", "platformId": "ps"},
    {'name': "Xbox One/Series", "platformId": "xbox"},
    {'name': "Nintendo Switch", "platformId": "switch"},
    {"name": "Mobile", "platformId": 'phone'},
  ];
  String? _err;
  String fileToName(String file) {
    switch (file) {
      case "steam":
        return "Steam (PC)";
      case "ps":
        return "PS3/4/5";
      case "xbox":
        return "Xbox One/Series";
      case "switch":
        return "Nintendo Switch";
      case "phone":
        return "Mobile";
      default:
        return "Steam (PC)";
    }
  }

  @override
  void initState(){
    super.initState();

    // Pop all routes under bc steam login creates another page
    if(widget.steamLoginUri != null) {
      Future.delayed(const Duration(milliseconds: 0),(){
        Navigator.of(context).removeRouteBelow(ModalRoute.of(context) as Route);
      });
    }

    if(widget.steamLoginUri != null) {
      Future.delayed(const Duration(milliseconds: 0),() async {
        try {
          String oldAccounts = await getNonNullSSData("accountsSave");
          String isEditingAccount = await getNonNullSSData("isEditingAccount");
          await secureStorage.delete(key: "accountsSave");
          await secureStorage.delete(key: "isEditingAccount");
          if (isEditingAccount == "true") {
            setState(() {
              alreadyCreatedAccount = true;
            });
          }
          if (oldAccounts != "no data") {
            accounts = jsonDecode(oldAccounts);
            for (int i = 0; i < accounts.length; i++) {
              listKey.currentState?.insertItem(
                i,
              );
            }
          }
          loadItemsList(true);
          var openId = OpenId.fromUri(widget.steamLoginUri as Uri);
          if (openId.mode != 'id_res') throw Exception("OpenID mode is not id_res");
          if (openId.data["openid.claimed_id"] == null) {
            throw Exception("No claimed_id query param in URI");
          }
          String? steamId = Uri
              .tryParse(openId.data["openid.claimed_id"] as String)
              ?.pathSegments
              .last;
          if (steamId == null) {
            throw Exception("No steamID found in query param 'claimed_id'");
          }
          var apiResponse = await http.get(getUri("/auth/getBIDFromSteamId/$steamId"));
          if (apiResponse.statusCode < 200 || apiResponse.statusCode > 299) {
            throw Exception("Api responded with error");
          }
          var accountData = jsonDecode(apiResponse.body);
          var result = {
            "BID": accountData["brawlhalla_id"].toString(),
            "name": accountData["name"],
            "platformId": "steam",
            "steamId": steamId
          };
          listKey.currentState?.insertItem(
            accounts.length,
          );
          setState(() {
            accounts.add(result);
            if (result["steamId"] != null) {
              steamId = result["steamId"];
            }
            items.removeWhere(
                    (item) => item["platformId"] == result["platformId"]);
            _err = null;
          });
        } catch(e,s){
          showInfoDropdown(
            context,
            kRed,
            "Error:",
            body: Text(
              "Error retrieving steam account details, please try again later.  \nIf the error persists, please contact support at contact@winhalla.app",
              style: Theme.of(context)
                  .textTheme
                  .bodyText2
                  ?.merge(InheritedTextStyle.of(context).kBodyText4),
            ),
            fontSize: 25,
            column: true,
            timeShown: 11000
          );
          print(e);
          print(s);
        }
    }).then((value) => print("finished"));
    }
  }

  void loadItemsList(bool isFromSteamLogin){
    if (!isFromSteamLogin) accounts = List.from(widget.accounts);
    print(accounts);
    for (int i = 0; i < accounts.length; i++) {
      for (int ii = 0; ii < items.length; ii++) {
        var element = items[ii];

        if (element["platformId"] == accounts[i]["platformId"]) {
          items.removeAt(ii);
        }
      }
    }
    if (!isFromSteamLogin) alreadyCreatedAccount = true;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.accounts != null && alreadyCreatedAccount == false) {
      loadItemsList(false);
    }
    return Padding(
          padding: const EdgeInsets.fromLTRB(42.5, 40, 42.5, 0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: () {
                      context.read<LoginPageManager>().next(goBack: true);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.rotate(
                            angle: 180 * pi / 180,
                            child:
                            Icon(Icons.arrow_forward, color:kRed.withOpacity(0.8))
                        ),
                        const SizedBox(width: 7,),
                        Text("Back", style: InheritedTextStyle.of(context).kBodyText2.apply(color:kRed.withOpacity(0.8)),)
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 2.h,),
                Text("Link a Brawlhalla account",
                    style: InheritedTextStyle.of(context)
                        .kHeadline1
                        .apply(fontSizeFactor: 1.15) // 50 of font size
                    ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "Link at least one Brawlhalla account",
                  style: InheritedTextStyle.of(context)
                      .kBodyText1bis
                      .apply(color: kText80, fontFamily: "Roboto Condensed"),
                ),
                const SizedBox(
                  height: 50,
                ),
                AnimatedList(
                  key: listKey,
                  initialItemCount: accounts.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index,
                      Animation<double> animation) {
                    return Container(
                      padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
                      margin: EdgeInsets.only(top: index == 0 ? 0 : 20),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: kEpic,
                          width: 1,
                        ),
                        color: kBackgroundVariant,
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 3.0),
                            child: Image.asset(
                              "assets/images/icons/pink/${accounts[index]["platformId"]}Pink.png",
                              height: 30,
                            ),
                          ),
                          const SizedBox(
                            width: 18,
                          ),
                          Expanded(
                            child: Text(
                              accounts[index]["name"],
                              style: InheritedTextStyle.of(context)
                                  .kBodyText1
                                  .apply(color: kEpic),
                            ),
                          ),
                          GestureDetector(
                              child: const Icon(
                                Icons.clear_outlined,
                                size: 40,
                                color: kEpic,
                              ),
                              onTap: () {
                                var name = accounts[index]["name"];
                                var fileName = accounts[index]["platformId"];
                                setState(() {
                                  listKey.currentState?.removeItem(
                                      index,
                                      (_, animation) => animatedFakeContainer(
                                          context,
                                          index,
                                          animation,
                                          name,
                                          fileName),
                                      duration: const Duration(milliseconds: 150));
                                  items.add({
                                    "platformId": accounts[index]["platformId"],
                                    "name":
                                        fileToName(accounts[index]["platformId"])
                                  });
                                  accounts.removeAt(index);
                                });
                              })
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 50),
                if (accounts.length < 3)
                  GestureDetector(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
                      decoration: BoxDecoration(
                        color: kBackgroundVariant,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add_circle_outline,
                            color: kPrimary,
                            size: 34,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(
                              "Add an account",
                              style: InheritedTextStyle.of(context)
                                  .kBodyText1
                                  .apply(color: kPrimary),
                            ),
                          )
                        ],
                      ),
                    ),
                    onTap: () async {
                      secureStorage.write(key: "accountsSave", value: jsonEncode(accounts));
                      secureStorage.write(key: "isEditingAccount", value: alreadyCreatedAccount.toString());
                      var result = await showDialog(
                          context: context,
                          builder: (context) => PopupWidget(context, items));
                      if (result != null) {
                        if (result["error"] == true) {
                          setState(() {
                            _err = result["errorDetails"];
                          });
                          return;
                        }
                        setState(() {
                          _err = null;
                          listKey.currentState?.insertItem(
                            accounts.length,
                          );
                          accounts.add(result);
                          if (result["steamId"] != null) {
                            steamId = result["steamId"];
                          }
                          items.removeWhere(
                              (item) => item["platformId"] == result["platformId"]);
                        });
                      }
                    },
                  ),
                const SizedBox(
                  height: 20,
                ),
                if (_err != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                            child: Text(
                          "Error: " + (_err as String),
                          style: InheritedTextStyle.of(context)
                              .kBodyText3
                              .apply(color: kRed),
                        ))
                      ],
                    ),
                  ),
                Row(
                  mainAxisAlignment: alreadyCreatedAccount
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.end,
                  children: [
                    if (alreadyCreatedAccount)
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          margin: EdgeInsets.only(bottom: _err == null ? 50 : 10),
                          decoration: BoxDecoration(
                            color: kBackgroundVariant,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 1.0),
                                  child: Text(
                                    "Cancel",
                                    style: InheritedTextStyle.of(context)
                                        .kBodyText2
                                        .apply(color: kRed),
                                  ),
                                ),
                                const SizedBox(
                                  width: 6,
                                ),
                                const Icon(
                                  Icons.clear_outlined,
                                  color: kRed,
                                  size: 30,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () async {
                        if (accounts.isEmpty) return;
                        final authKey = await secureStorage.read(key: "authKey");
                        if (authKey == null) {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, "/login");
                          return;
                        }
                        var link = await getNonNullSSData("link");
                        CallApi callApi =
                            CallApi(authKey: authKey, context: context);
                        var accountData = await callApi.post(
                            alreadyCreatedAccount
                                ? "/auth/editBrawlhallaAccounts"
                                : '/auth/createAccount' +
                                    (link == "no data" ? "" : '?linkId=$link'),
                            jsonEncode(
                              {"accounts": accounts},
                            ),
                            showError: false);
                        if (accountData["successful"] == false) {
                          setState(() {
                            _err = accountData["data"];
                          });
                          return;
                        }
                        try {
                          if (accountData["data"]["accountExists"] == true) {
                            setState(() {
                              _err =
                                  "You have already created an account using this google/apple account, please contact support at contact@winhalla.app if it was not you";
                            });
                            return;
                          }
                        } catch (e) {}

                        await secureStorage.write(key: 'link', value: null);
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/',
                              (Route<dynamic> route) => false,
                        );

                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        margin: EdgeInsets.only(bottom: _err == null ? 50 : 10),
                        decoration: BoxDecoration(
                          color: kBackgroundVariant,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 6, 6, 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 1.0),
                                child: Text(
                                  alreadyCreatedAccount ? "Save" : "Finish",
                                  style: InheritedTextStyle.of(context)
                                      .kBodyText2
                                      .apply(color: accounts.isEmpty ? kGray : kGreen),
                                ),
                              ),
                              const SizedBox(
                                width: 6,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4.75),
                                child: Icon(
                                  Icons.check,
                                  color: accounts.isEmpty ? kGray : kGreen,
                                  size: 30,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }
}
Widget animatedFakeContainer(item, int index, Animation<double> animation,
        String name, String file) =>
    FadeTransition(
      opacity: Tween(begin: 0.0, end: 1.0)
          .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
      child: SizeTransition(
        sizeFactor: Tween(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOut),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
          margin: EdgeInsets.only(top: index == 0 ? 0 : 20),
          decoration: BoxDecoration(
            border: Border.all(
              color: kEpic,
              width: 1,
            ),
            color: kBackgroundVariant,
            borderRadius: BorderRadius.circular(17),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 3.0),
                child: Image.asset(
                  "assets/images/icons/pink/${file}Pink.png",
                  height: 30,
                ),
              ),
              const SizedBox(
                width: 18,
              ),
              Expanded(
                child: Builder(builder: (context) {
                  return Text(
                    name,
                    style: InheritedTextStyle.of(context)
                        .kBodyText1
                        .apply(color: kEpic),
                  );
                }),
              ),
              const Icon(
                Icons.clear_outlined,
                size: 40,
                color: kEpic,
              ),
            ],
          ),
        ),
      ),
    );
