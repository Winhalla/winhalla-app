import 'package:flutter/material.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/utils/services/secure_storage_service.dart';

import 'inherited_text_style.dart';

Widget LeaveMatchPopup(){
  return Builder(
      builder: (context) {
        return AlertDialog(
          elevation: 10,
          backgroundColor: kBackgroundVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Padding(
            padding: const EdgeInsets.fromLTRB(4,0,4,0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Are you sure?",
                    style: InheritedTextStyle.of(context).kHeadline2,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    Navigator.pop(context, false);
                  },
                  behavior: HitTestBehavior.translucent,
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 35),
                    child: Icon(
                      Icons.close,
                      color: kGray,
                      size: 32,
                    ),

                  ),

                ),
              ],
            ),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          content: Padding(
            padding: const EdgeInsets.fromLTRB(6,0,4,0),
            child: RichText(
              text: TextSpan(style: InheritedTextStyle.of(context).kBodyText3, children: const [
                TextSpan(text: "By clicking the ", style: TextStyle(height: 1.3)),
                TextSpan(text: "leave ", style: TextStyle(color: kPrimary,height: 1.3)),
                TextSpan(text: "button you will be ", style: TextStyle(height: 1.3)),
                TextSpan(text: "removed ", style: TextStyle(color: kPrimary,height: 1.3)),
                TextSpan(text: "from this match: you ", style: TextStyle(height: 1.3)),
                TextSpan(text: "won't ", style: TextStyle(color: kPrimary,height: 1.3)),
                TextSpan(text: "earn rewards from it. If you ", style: TextStyle(height: 1.3)),
                TextSpan(text: "played ", style: TextStyle(color: kPrimary,height: 1.3)),
                TextSpan(text: "one or more ", style: TextStyle(height: 1.3)),
                TextSpan(text: "Brawlhalla games", style: TextStyle(color: kPrimary,height: 1.3)),
                TextSpan(text: ", ", style: TextStyle(height: 1.3)),
                TextSpan(text: "wait", style: TextStyle(height: 1.3, decoration: TextDecoration.underline,)),
                TextSpan(text: " for them to show up on your player card before leaving the match.", style: TextStyle(height: 1.3)),
              ]),
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () async {
                      await secureStorage.write(key: "hideLeaveMatchPopup", value: "true");
                      Navigator.pop(context, true);
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(19,0,0,14),
                      child: Text("Don't show again and leave", style: InheritedTextStyle.of(context).kBodyText3.apply(fontSizeFactor: 0.80,color: kText70),),
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: ()=> Navigator.pop(context, false),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10,0,10,14),
                    child: Row(
                      children: [
                        Text("No", style: InheritedTextStyle.of(context).kBodyText2.apply(color:kRed)),
                        const SizedBox(width: 3,),
                        const Icon(Icons.close,color: kRed,),
                      ],),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: ()=> Navigator.pop(context, true),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0,0,19,14),
                    child: Row(
                      children: [
                        Text("Yes", style: InheritedTextStyle.of(context).kBodyText2.apply(color:kGreen)),
                        const SizedBox(width: 4,),
                        const Icon(Icons.check,color: kGreen,),
                      ],),
                  ),
                ),
              ],
            )
          ],
        );
      }
  );
}