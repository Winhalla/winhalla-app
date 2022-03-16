import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:steam_login/steam_login.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/utils/custom_http.dart';
// import 'package:http/http.dart' as http;
import 'package:winhalla_app/utils/get_uri.dart';
import 'package:winhalla_app/utils/launch_url.dart';
import 'package:winhalla_app/utils/steam.dart.old';

import 'inherited_text_style.dart';

Widget PopupWidget(BuildContext context, List<Map<String, String>> items,) {
  final bidTextController = TextEditingController();
  String _chosenValue = items[0]["platformId"] as String;
  String step = "platformSelection";
  bool _loading = false;
  String? _error;
  dynamic accountData = {"data":{"level":2}};


  return StatefulBuilder(builder: (context, setState) {
    void nextStep() async {

      if (_chosenValue == "steam" && step == "platformSelection") {
        setState((){
          step = "steamLogin";
        });
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        var openId = OpenId.raw(
            apiUrl, apiUrl+"/auth/steamCallback", {"name": "Winhalla"});
        launchURLBrowser(openId.authUrl().toString(),);

      } else if (step == "platformSelection") {
        setState(() {
          step = "enterBid";
        });
      }

      else if(step == "enterBid") {
        if (_loading == true) return;
        setState(() {
          _loading = true;
        });
        if (bidTextController.text.replaceAll(' ', '') == "") {
          setState(() {
            _loading = false;
            _error = "Please provide a Brawlhalla ID";
          });
          return;
        }
        accountData =
            (await http.get(getUri("/auth/isBIDValid/${bidTextController.text.replaceAll(' ', '')}"))).body;
        accountData = jsonDecode(accountData);
        if (accountData["isValid"] == false) {
          _loading = false;
          return setState(() {
            _error = accountData["reason"];
          });
        }
        _loading = false;
        setState(() {
          step = "confirmAccount";
        });
      }
    }

    void createAccount() async {
      Navigator.pop(context,
          {"BID": bidTextController.text, "name": accountData["data"]["name"], "platformId": _chosenValue});
    }



    return AlertDialog(

      titlePadding: const EdgeInsets.only(top: 26, left: 30),
      title: Text(
        step == "platformSelection" ? 'Select a platform' : "Brawlhalla Id",
        style: InheritedTextStyle.of(context).kBodyText1,
      ),

      contentPadding: const EdgeInsets.fromLTRB(28, 16, 28, 8),
      content: step == "platformSelection"
          ? Container(
              decoration: BoxDecoration(color: kBackground, borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.fromLTRB(0, 6, 6, 6),
              child: ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton(
                  iconSize: 38,
                  iconEnabledColor: kText80,
                  iconDisabledColor: kText80,
                  itemHeight: 50,

                  onChanged: (String? value) {
                    setState(() {
                      if (value != null) _chosenValue = value;
                    });
                  },
                  dropdownColor: const Color(0x00000000),
                  // Transparent
                  elevation: 0,
                  value: _chosenValue,


                  items: items.map<DropdownMenuItem<String>>((
                    Map<String, String> value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value["platformId"],
                      child: Container(
                        height: 52,
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                        decoration: BoxDecoration(
                            color: kBackground,

                            borderRadius: value["platformId"] == items[0]["platformId"]
                                ? const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15))
                                : value["platformId"] == items[items.length - 1]["platformId"]
                                    ? const BorderRadius.only(
                                        bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15))
                                    : BorderRadius.circular(0)),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 25,
                              height: 25,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/images/icons/${value["platformId"]}.png",
                                    width: 25,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 1),
                              child: Text(
                                value["name"] as String,
                                style: InheritedTextStyle.of(context).kBodyText4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  underline: Container(), // Empty widget to remove underline
              ),
          ))
          : step == "enterBid"? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: kBackground),
                  padding: const EdgeInsets.fromLTRB(20, 7, 20, 7),
                  child: TextField(
                    keyboardType: TextInputType.phone,
                    controller: bidTextController,
                    style: InheritedTextStyle.of(context).kBodyText3.apply(fontSizeFactor: 0.9,color: kText80),
                    decoration: InputDecoration(
                        suffixIconConstraints: const BoxConstraints(maxHeight: 37, maxWidth: 35),
                        suffixIcon: _loading
                            ? const Padding(
                                padding: EdgeInsets.fromLTRB(10, 6, 0, 6),
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                ),
                              )
                            : _error != null
                                ? const Padding(
                                    padding: EdgeInsets.only(left: 4.0),
                                    child: Icon(
                                      Icons.clear_outlined,
                                      color: kRed,
                                      size: 34,
                                    ),
                                  )
                                : null,
                        border: InputBorder.none,
                        hintText: 'Type your Brawlhalla ID here',
                        hintStyle: InheritedTextStyle.of(context).kBodyText3.apply(fontSizeFactor: 0.85,color: kText80)
                    ),
                  ),
                ),
                if (_error != null)
                  const SizedBox(
                    height: 7,
                  ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      _error as String,
                      style: InheritedTextStyle.of(context).kBodyText3.apply(fontSizeFactor: 0.8,color: kRed),
                    ),
                  ),
                SizedBox(
                  height: _error == null ? 34 : 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10, left: 0),
                  child: Text(
                    "Find your Brawlhalla ID in the top right corner of your inventory:",
                    style: InheritedTextStyle.of(context).kBodyText3.apply(fontSizeFactor: 0.75,color: kText80),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Flexible(
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        "assets/images/bidHelper.png",
                      )),
                ),
              ],
          ):  Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("We found this account:",style: InheritedTextStyle.of(context).kBodyText3.apply(color: kText80),),
                  SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Row(
                            children: [
                              Text("Name: ",style: InheritedTextStyle.of(context).kBodyText3,),
                              Text(accountData["data"]["name"].toString(), style: InheritedTextStyle.of(context).kBodyText3.apply(color: kPrimary))
                            ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Row(
                            children: [
                              Text("Level: ",style: InheritedTextStyle.of(context).kBodyText3,),
                              Text(accountData["data"]["level"].toString(), style: InheritedTextStyle.of(context).kBodyText3.apply(color: kPrimary))
                            ],
                    ),
                  ),
                  SizedBox(height: 10,),
                  Text("Is it yours?",style: InheritedTextStyle.of(context).kBodyText2.apply(color: kPrimary),),
                ],
              ),


      actionsPadding: const EdgeInsets.symmetric(horizontal: 13),
      actions: [Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (step == "platformSelection")
              TextButton(
                onPressed: () {
                  nextStep();
                },
                child: Text(
                  "Next",
                  style: InheritedTextStyle.of(context).kBodyText2.apply(color: kPrimary),
                ),
              ),
              if (step == "enterBid" || step == "confirmAccount")
                TextButton(
                  onPressed: () {
                    if(step == "enterBid") nextStep();
                    if(step == "confirmAccount") createAccount();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        step == "confirmAccount"?"Yes":"Next",
                        style: InheritedTextStyle.of(context).kBodyText2.apply(color: kGreen),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 5.0),
                        child: Icon(
                          Icons.check,
                          color: kGreen,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              if(step == "confirmAccount") TextButton(
                onPressed: () {
                  setState((){
                    bidTextController.text = "";
                    step = "enterBid";
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "No",
                      style: InheritedTextStyle.of(context).kBodyText2.apply(color: kRed),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 3.0),
                      child: Icon(
                        Icons.clear_outlined,
                        color: kRed,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ],
        ),
      ],

      backgroundColor: kBackgroundVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
    );
  });
}
