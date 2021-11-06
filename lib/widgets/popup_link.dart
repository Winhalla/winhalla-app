import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/widgets/tip_painter.dart';
import 'package:share/share.dart';


Widget LinkInfoWidget(String linkId){
  return StatefulBuilder(builder: (context, setState) {
    return AlertDialog(
      elevation: 10,
      title: Padding(
        padding: const EdgeInsets.fromLTRB(4,0,4,0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Share the app",
              style: kBodyText1,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Padding(
                    padding: EdgeInsets.only(top: 3.0),
                    child: Text(
                      "TIP",
                      style: TextStyle(
                        color: kGreen,
                        fontSize: 23,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Icon(
                    Icons.lightbulb_outline_sharp,
                    color: kGreen,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.fromLTRB(4,0,4,0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 7, 0, 0),
                  child: CustomPaint(
                    size: const Size(40, 105),
                    painter: TipPainter(color: kText,height:0), //3
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 18.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 180,
                        child: RichText(
                          text: const TextSpan(style: kBodyText3, children: [
                            TextSpan(text: "Get "),
                            TextSpan(text: "20% ", style: TextStyle(color: kPrimary)),
                            TextSpan(text: "of your friend's rewards")
                          ]),
                        ),
                      ),
                      const SizedBox(
                        height: 19,
                      ),
                      SizedBox(
                        width: 180,
                        child: RichText(
                          softWrap: true,
                          text: const TextSpan(style: kBodyText3, children: [
                            TextSpan(text: "Each of your friends gets a  "),
                            TextSpan(text: "20% boost ",style: TextStyle(color: kPrimary)),
                          ]),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 30,),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: (){
                Share.share('https://winhalla.app/link/$linkId');
              },
              child: Container(
                decoration: BoxDecoration(color: kPrimary,borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.share,color: kText,size: 30,),
                    SizedBox(width: 10,),
                    Padding(
                      padding: EdgeInsets.only(top: 2.5),
                      child: Text("Share",style: kBodyText1,),
                    )
                ],)
              )
            )
          ],
        ),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 10, 24, 5),
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