import 'package:flutter/material.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/utils/services/secure_storage_service.dart';

import 'inherited_text_style.dart';

Widget NoRefreshPopup(String type){
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    "Sometimes...",
                    style: InheritedTextStyle.of(context).kHeadline2,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                  },
                  behavior: HitTestBehavior.translucent,
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(0, 3, 0, 22),
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
          contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          content: Padding(
            padding: const EdgeInsets.fromLTRB(6,0,4,0),
            child: RichText(
              text: TextSpan(style: InheritedTextStyle.of(context).kBodyText3, children: [
                const TextSpan(text: "...data ", style: TextStyle(height: 1.3)),
                const TextSpan(text: "doesn't refresh ", style: TextStyle(color: kPrimary,height: 1.3)),
                const TextSpan(text: "instantly. This is due to the ", style: TextStyle(height: 1.3)),
                const TextSpan(text: "Brawlhalla API ", style: TextStyle(color: kPrimary,height: 1.3)),
                TextSpan(text: type == "quests" ? "latency. It can take up to 3 hours." : "latency. It usually takes a few minutes, but it can take up to 30.", style: const TextStyle(height: 1.3)),
              ]),
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () async {
                    await secureStorage.write(key: type == "quests" ? "hideNoRefreshQuests":"hideNoRefreshMatch", value: "true");
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(19,0,0,14),
                    child: Text("Don't show again", style: InheritedTextStyle.of(context).kBodyText3.apply(fontSizeFactor: 0.80,color: kText70),),
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0,0,19,14),
                    child: Row(
                      children: [
                        Text("Ok", style: InheritedTextStyle.of(context).kBodyText2.apply(color:kGreen),),
                        const SizedBox(width: 7,),
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