import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/widgets/tip_painter.dart';
import 'package:share/share.dart';

Widget LinkActivatedWidget(){
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
              const Expanded(
                child: Text(
                  "Referral boost activated",
                  style: kHeadline2,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  Navigator.pop(context);
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
            text: const TextSpan(style: kBodyText3, children: [
              TextSpan(text: "We detected a friend shared the app to you: you have a ", style: TextStyle(height: 1.3)),
              TextSpan(text: "20% coin boost", style: TextStyle(color: kPrimary,height: 1.3)),
              TextSpan(text: " for 2 weeks!", style: TextStyle(height: 1.3))
            ]),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: (){
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0,0,19,14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("Got it", style: kBodyText2.apply(color:kGreen),),
                  const SizedBox(width: 7,),
                  const Icon(Icons.check,color: kGreen,),
              ],),
            ),
          )
        ],
      );
    }
  );
}

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
              style: kHeadline2,
            ),
            GestureDetector(
              onTap: () async {
                Navigator.pop(context);
              },
              behavior: HitTestBehavior.translucent,
              child: const Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 2),
                child: Icon(
                      Icons.close,
                      color: kGray,
                      size: 28,
                    ),
                       
                ),
              
            ),
          ],
        ),
      ),

      contentPadding: const EdgeInsets.fromLTRB(24, 5, 24, 30),
      content: Padding(
        padding: const EdgeInsets.fromLTRB(4,0,4,0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                  child: CustomPaint(
                    size: const Size(35, 105),
                    painter: TipPainter(color: kText,height:0), //3
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 11.0),
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
                    SizedBox(width: 6,),
                    Padding(
                      padding: EdgeInsets.only(top: 2.5),
                      child: Text("Share", style: kBodyText1,),
                    )
                ],)
              )
            )
          ],
        ),
      ),
      backgroundColor: kBackgroundVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
    );
  });
}