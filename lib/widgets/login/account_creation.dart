import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/utils/get_uri.dart';
import 'package:winhalla_app/utils/services/secure_storage_service.dart';
import '../inherited_text_style.dart';
import '../popup.dart';
import '../popup_link.dart';

class AccountCreation extends StatefulWidget {
  final accounts;
  const AccountCreation({Key? key, this.accounts}) : super(key: key);

  @override
  _AccountCreationState createState() => _AccountCreationState();
}

class _AccountCreationState extends State<AccountCreation> {
  List<dynamic> accounts = [];
  Map<String, dynamic>? gAccount;
  String? steamId;
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
  String fileToName(String file){
    switch (file){
      case "steam": return "Steam (PC)";
      case "ps": return "PS3/4/5";
      case "xbox": return "Xbox One/Series";
      case "switch": return "Nintendo Switch";
      case "phone": return "Mobile";
      default: return "Steam (PC)";
    }
  }
  @override
  Widget build(BuildContext context) {
    if(widget.accounts != null && alreadyCreatedAccount == false) {
      accounts = widget.accounts;
      for (int i = 0; i < accounts.length; i++) {
        for (int ii = 0; ii < items.length; ii++) {
          var element = items[ii];

          if(element["platformId"] == accounts[i]["platformId"]){
            items.removeAt(ii);
          }
        }
      }
      alreadyCreatedAccount = true;
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 70, 32, 0),
      child: Column(
        children: [
          Text(
            "Link a Brawlhalla account",
            style: InheritedTextStyle.of(context).kHeadline1.apply(fontSizeFactor: 1.25) // 50 of font size
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            "Link at least one Brawlhalla account",
            style: InheritedTextStyle.of(context).kBodyText1bis.apply(color: kText80, fontFamily: "Roboto Condensed"),
          ),
          const SizedBox(
            height: 50,
          ),
          AnimatedList(
            key: listKey,
            initialItemCount: accounts.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index, Animation<double> animation) {
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
                        style: InheritedTextStyle.of(context).kBodyText1.apply(color: kEpic),
                      ),
                    ),
                    GestureDetector(
                        child: const Icon(Icons.clear_outlined, size: 40, color: kEpic,),
                        onTap:(){
                          var name = accounts[index]["name"];
                          var fileName = accounts[index]["platformId"];
                          setState(() {
                            listKey.currentState?.removeItem(
                                index, (_, animation) => animatedFakeContainer(
                                context,
                                index,
                                animation,
                                name,
                                fileName
                            ),
                                duration: const Duration(milliseconds: 150));
                            items.add({"platformId":accounts[index]["platformId"], "name":fileToName(accounts[index]["platformId"])});
                            accounts.removeAt(index);
                          });
                        }
                    )
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
                        style: InheritedTextStyle.of(context).kBodyText1.apply(color: kPrimary),
                      ),
                    )
                  ],
                ),
              ),
              onTap: () async {
                var result =
                await showDialog(context: context, builder: (context) => PopupWidget(context, items));
                if (result != null) {
                  if(result["error"] == true){
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
                    if(result["steamId"] != null){
                      steamId = result["steamId"];
                    }
                    items.removeWhere((item) => item["platformId"] == result["platformId"]);
                  });
                }
              },
            ),
          const Expanded(
            child: Text(""),
          ),
          Row(
            mainAxisAlignment: alreadyCreatedAccount && accounts.isNotEmpty
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.end,
            children: [
              if(alreadyCreatedAccount) GestureDetector(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  margin: EdgeInsets.only(bottom: _err == null ? 50:10),
                  decoration: BoxDecoration(
                    color: kBackgroundVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10,8,6,8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 1.0),
                          child: Text(
                            "Cancel",
                            style: InheritedTextStyle.of(context).kBodyText2.apply(color: kRed),
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
              if (accounts.isNotEmpty) GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () async {
                  final authKey = await secureStorage.read(key: "authKey");
                  if (authKey == null) {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, "/login");
                    return;
                  }
                  var link = await getNonNullSSData("link");
                  CallApi callApi = CallApi(authKey: authKey , context: context);
                  var accountData = await callApi.post(
                      alreadyCreatedAccount?"/auth/editBrawlhallaAccounts" : '/auth/createAccount'+ (link == "no data" ? "" : '?linkId=$link'),
                      jsonEncode(
                        {
                          "accounts": accounts
                        },
                      ),
                      showError:false
                  );
                  if(accountData["successful"] == false) {
                    setState(() {
                      _err = accountData["data"];
                    });
                    return;
                  }
                  try{
                    if (accountData["data"]["accountExists"] == true) {
                      setState(() {
                        _err =
                        "You have already created an account using this google/apple account, please contact support at contact@winhalla.app if it was not you";
                      });
                      return;
                    }
                  } catch(e){}

                  await secureStorage.write(key:'link',value: null);
                  if (ModalRoute.of(context)?.settings.name == "/") {
                    Navigator.pop(context, "/");
                    Navigator.pushNamed(context, "/");
                  } else {
                    Navigator.pushReplacementNamed(context, "/");
                  }
                  try{
                    if(accountData["data"]["isLinkDetected"] == true){
                      showDialog(context: context, builder:(_)=>LinkActivatedWidget());
                    }
                  } catch(e){}
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  margin: EdgeInsets.only(bottom: _err == null ? 50:10),
                  decoration: BoxDecoration(
                    color: kBackgroundVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10,6,6,6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 1.0),
                          child: Text(
                            alreadyCreatedAccount ? "Save" : "Finish",
                            style: InheritedTextStyle.of(context).kBodyText2.apply(color: kGreen),
                          ),
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 4.75),
                          child: Icon(
                            Icons.check,
                            color: kGreen,
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
          if(_err != null) Container(
            margin: const EdgeInsets.only(bottom: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(child: Text("Error: " + (_err as String), style: InheritedTextStyle.of(context).kBodyText4.apply(color: kRed),))
              ],),
          )
        ],
      ),
    );
  }
}
Widget animatedFakeContainer(item, int index, Animation<double> animation, String name, String file) =>
    FadeTransition(
      opacity: Tween(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOut)),
      child: SizeTransition(
        sizeFactor: Tween(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut),
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
                child: Builder(
                  builder: (context) {
                    return Text(
                      name,
                      style: InheritedTextStyle.of(context).kBodyText1.apply(color: kEpic),
                    );
                  }
                ),
              ),
              const Icon(Icons.clear_outlined, size: 40, color: kEpic,),
            ],
          ),
        ),
      ),
    );