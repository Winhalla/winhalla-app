import 'package:flutter/material.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => setState(() {}),
              child: Container(
                  decoration: BoxDecoration(
                      color: kBackgroundVariant,
                      borderRadius: BorderRadius.circular(11)
                  ),

                  padding: const EdgeInsets.fromLTRB(19, 9, 19, 6),

                  child: Text(
                    "5896",
                    style: AppTheme.textTheme.bodyText1?.apply(color: kPrimary),
                  )

              ),
            ),
            GestureDetector(
              onTap: () => setState(() {}),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: kBackgroundVariant,
                        borderRadius: BorderRadius.circular(11)),
                    padding: const EdgeInsets.fromLTRB(19, 9, 19, 6),
                    child: Text(
                      "Battle Pass",
                      style: AppTheme.textTheme.bodyText1?.apply(color: kEpic),
                    )
                  ),
                  Positioned(
                    left: 19,
                    bottom: 0,
                    child: Container(height: 2, width: 20, color: kEpic,)
                  )
                ],
              ),
            )
          ]
        ),
        Padding(padding: EdgeInsets.only(top: 65)),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Daily challenge:", style: AppTheme.textTheme.headline1,),
            Container(

              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              decoration: BoxDecoration(color: kBackgroundVariant, borderRadius: BorderRadius.circular(12)),
              child: Text("?", style: TextStyle(fontFamily: "Roboto Condensed", color: kPrimary, fontSize: 32),),
            )
          ],
        )
      ],
    );
  }
}
