import 'package:flutter/material.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/screens/login.dart';

import 'inherited_text_style.dart';

Widget AccountEditWarning(accounts){
    return Builder(
      builder: (context) {
        return AlertDialog(
          elevation: 10,

          titlePadding: const EdgeInsets.only(top: 26, left: 30),
          title: Padding(
            padding: const EdgeInsets.fromLTRB(4,0,4,0),
            child: Text(
              "Warning",
              style: InheritedTextStyle.of(context).kBodyText1.apply(color: kRed),
            ),
          ),

          contentPadding: const EdgeInsets.fromLTRB(28, 16, 28, 16),
          content: Padding(
            padding: const EdgeInsets.fromLTRB(4,0,4,0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Changing linked accounts will reset the progression of your quests, and change their goals.", style: InheritedTextStyle.of(context).kBodyText3,),
                const SizedBox(height: 15,),
                Text(
                  "You cannot change linked accounts if you are in a match",
                  style: InheritedTextStyle.of(context).kBodyText4.apply(fontSizeFactor: 0.8,color: kText80, fontFamily: "Roboto Condensed"),
                ),
              ],
            ),
          ),

          actionsPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 3.25),
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              behavior: HitTestBehavior.translucent,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0,0,15,6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Cancel",
                      style: InheritedTextStyle.of(context).kBodyText3.apply(color: kGray),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 5,),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_)=>  LoginPage(accounts: accounts,)),
                );
              },
              behavior: HitTestBehavior.translucent,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0,0,15,6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Next",
                      style: InheritedTextStyle.of(context).kBodyText3.apply(color: kGreen),
                    ),
                  ],
                ),
              ),
            ),
          ],
          backgroundColor: kBackgroundVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        );
      }
    );
}