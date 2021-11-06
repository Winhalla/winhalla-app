import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:http/http.dart' as http;
import 'package:winhalla_app/utils/get_uri.dart';
import 'package:winhalla_app/utils/steam.dart';

Widget PopupWidget(BuildContext context, List<Map<String, String>> items,) {
  final bidTextController = TextEditingController();
  String _chosenValue = items[0]["file"] as String;
  String step = "platformSelection";
  bool _loading = false;
  String? _error;


  return StatefulBuilder(builder: (context, setState) {
    void nextStep() {
      setState(() {
        if (_chosenValue == "steam") {
          step = "steamLogin";
        } else {
          step = "enterBid";
        }
      });
    }

    void createAccount() async {
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
      var accountData =
          (await http.get(getUri("/auth/isBIDValid/${bidTextController.text.replaceAll(' ', '')}"))).body;
      var decodedData = jsonDecode(accountData);
      if (decodedData["isValid"] == false) {
        _loading = false;
        return setState(() {
          _error = decodedData["reason"];
        });
      }

      Navigator.pop(context,
          {"bid": bidTextController.text, "name": decodedData["data"]["name"], "file": _chosenValue});
      _loading = false;
    }

    if (step == "steamLogin") return SteamLoginWebView();



    return AlertDialog(

      titlePadding: const EdgeInsets.only(top: 26, left: 30),
      title: Text(
        step == "platformSelection" ? 'Select a platform' : "Brawlhalla Id",
        style: kBodyText1,
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
                      value: value["file"],
                      child: Container(
                        height: 52,
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                        decoration: BoxDecoration(
                            color: kBackground,

                            borderRadius: value["file"] == items[0]["file"]
                                ? const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15))
                                : value["file"] == items[items.length - 1]["file"]
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
                                    "assets/images/icons/${value["file"]}.png",
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
                                style: kBodyText4,
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
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: kBackground),
                  padding: const EdgeInsets.fromLTRB(20, 7, 20, 7),
                  child: TextField(
                    keyboardType: TextInputType.phone,
                    controller: bidTextController,
                    style: const TextStyle(fontSize: 18, color: kText80, fontFamily: "Roboto Condensed"),
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
                        hintStyle: const TextStyle(fontSize: 17, color: kText80, fontFamily: "Roboto Condensed")),
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
                      style: const TextStyle(color: kRed, fontSize: 16, fontFamily: "Roboto Condensed"),
                    ),
                  ),
                SizedBox(
                  height: _error == null ? 34 : 20,
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 10, left: 0),
                  child: Text(
                    "Find your Brawlhalla ID in the top right corner of your inventory:",
                    style: TextStyle(color: kText80, fontSize: 15, fontFamily: "Roboto Condensed"),
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
          ),


      actionsPadding: const EdgeInsets.symmetric(horizontal: 13),
      actions: [
        /*Row(
          children: [],
          mainAxisSize: MainAxisSize.max,
        ),*/Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (step == "platformSelection")
              TextButton(
                onPressed: () {
                  nextStep();
                },
                child: Text(
                  "Next",
                  style: kBodyText2.apply(color: kPrimary),
                ),
              ),
              if (step == "enterBid")
                TextButton(
                  onPressed: () {
                    createAccount();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Finish",
                        style: kBodyText2.apply(color: kGreen),
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
            ],
          )
        
        
      ],

      backgroundColor: kBackgroundVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
    );
  });
}
