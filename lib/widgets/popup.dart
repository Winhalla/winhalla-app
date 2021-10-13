import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';

Widget PopupWidget(BuildContext context) {
  final bidTextController = TextEditingController();
  String _chosenValue = "steam.png";
  String step = "enterBid";
  List<Map<String, String>> items = [
    {'name': "Steam", "file": "steam.png"},
    {'name': "PS3/4/5", "file": "ps.png"},
    {'name': "Xbox One/Series", "file": "xbox.png"},
    {'name': "Nintendo Switch", "file": "switch.png"},
    {"name": "Mobile", "file": 'phone.png'},
  ];
  return StatefulBuilder(builder: (context, setState) {
    void nextStep() {
      setState(() {
        if (step == "platformSelection") {
          if (_chosenValue == "platformSelection")
            step = "steamLogin";
          else
            step = "enterBid";
        } else {
          Navigator.pop(context, _chosenValue);
        }
      });
    }

    void createAccount() async {
      Navigator.pop(context, bidTextController.text);
    }

    return AlertDialog(
      title: Text(
        step == "platformSelection" ? 'Select a platform' : "Brawlhalla Id",
        style: kBodyText1,
      ),
      content: step == "platformSelection"
          ? Container(
              decoration: BoxDecoration(color: kBackground, borderRadius: BorderRadius.circular(12)),
              // padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
              child: DropdownButton(
                itemHeight: 50,
                onChanged: (String? value) {
                  print(value);
                  setState(() {
                    if (value != null) _chosenValue = value;
                  });
                },
                dropdownColor: Color(0x00000000),
                // Transparent
                elevation: 0,
                value: _chosenValue,
                selectedItemBuilder: (BuildContext context) {
                  return items.map<Widget>((Map<String, String> value) {
                    return DropdownMenuItem<String>(
                      value: value["file"],
                      child: Container(
                        height: 51,
                        padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
                        decoration:
                            BoxDecoration(color: kBackground, borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          children: [
                            Image.asset(
                              "assets/images/${value["file"]}",
                              height: 25,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              value["name"] as String,
                              style: kBodyText4,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList();
                },
                items: items.map<DropdownMenuItem<String>>((Map<String, String> value) {
                  return DropdownMenuItem<String>(
                    value: value["file"],
                    child: Container(
                      height: 51,
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      decoration: BoxDecoration(
                          color: kBackground,
                          borderRadius: value["file"] == "steam.png"
                              ? BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15))
                              : value["file"] == "phone.png"
                                  ? BorderRadius.only(
                                      bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15))
                                  : BorderRadius.circular(0)),
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/images/${value["file"]}",
                            height: 25,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            value["name"] as String,
                            style: kBodyText4,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                underline: Container(), // Empty widget to remove underline
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: kBackground),
                  padding: const EdgeInsets.fromLTRB(20, 7, 20, 7),
                  child: TextField(
                    controller: bidTextController,
                    style: TextStyle(fontSize: 18, color: kText80, fontFamily: "Roboto Condensed"),
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Type in your brawlhalla ID',
                        hintStyle: TextStyle(fontSize: 18, color: kText80, fontFamily: "Roboto Condensed")),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10, left: 5),
                  child: Text(
                    "Find your Brawlhalla ID in the top left corner of your inventory:",
                    style: TextStyle(color: kText80, fontSize: 15, fontFamily: "Roboto Condensed"),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      "assets/images/bidHelper.png",
                    ))
              ],
            ),
      actions: [
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
              children: [
                Text(
                  "Finish",
                  style: kBodyText2.apply(color: kGreen),
                ),
                const SizedBox(
                  width: 5,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: const Icon(
                    Icons.check,
                    color: kGreen,
                    size: 30,
                  ),
                ),
              ],
            ),
          )
      ],
      backgroundColor: kBackgroundVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
    );
  });
}
