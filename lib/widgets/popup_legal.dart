import 'package:flutter/material.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';

Widget LegalInfoWidget(){
  return StatefulBuilder(builder: (context, setState) {
    return AlertDialog(
      elevation: 10,
      title: const Padding(
        padding: EdgeInsets.fromLTRB(4,0,4,0),
        child: Text(
          "Legal",
          style: kBodyText1,
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.fromLTRB(4,0,4,0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [

          ],
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () async {
            Navigator.pop(context);
          },
          behavior: HitTestBehavior.translucent,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0,0,10,6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Close",
                  style: kBodyText3.apply(color: kText80),
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
  });
}