import 'package:flutter/material.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/utils/custom_http.dart';
import 'package:winhalla_app/utils/get_uri.dart';
import 'package:winhalla_app/utils/launch_url.dart';
import 'package:winhalla_app/utils/services/secure_storage_service.dart';
import 'package:winhalla_app/widgets/login/google_apple_login.dart';

import 'inherited_text_style.dart';
// import 'package:http/http.dart' as http;

Widget LegalInfoPopup(){
  bool confirmAccountDeletion = false;
  return StatefulBuilder(builder: (context, setState) {
    return AlertDialog(
      elevation: 10,
      title: Padding(
        padding: const EdgeInsets.fromLTRB(4,0,4,0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Legal",
              style: InheritedTextStyle.of(context).kHeadline2,
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

      // contentPadding: const EdgeInsets.fromLTRB(24, 5, 24, 30),
      content: !confirmAccountDeletion?SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Privacy policy: ", style: InheritedTextStyle.of(context).kBodyText2,),
            GestureDetector(
              onTap: (){
                launchURLBrowser("https://winhalla.app/privacy");
              },
              child: Text("https://winhalla.app/privacy", style: InheritedTextStyle.of(context).kBodyText3.apply(color: Colors.blueAccent),),
            ),
            const SizedBox(height: 20,),
            Text("Terms of use: ", style: InheritedTextStyle.of(context).kBodyText2,),
            GestureDetector(
              onTap: (){
                launchURLBrowser("https://winhalla.app/terms");
              },
              child: Text("https://winhalla.app/terms", style: InheritedTextStyle.of(context).kBodyText3.apply(color: Colors.blueAccent),),
            ),
            const SizedBox(height: 20,),
            Text("Legal mentions: ", style: InheritedTextStyle.of(context).kBodyText2,),
            GestureDetector(
              onTap: (){
                launchURLBrowser("https://winhalla.app/legal");
              },
              child: Text("https://winhalla.app/legal", style: InheritedTextStyle.of(context).kBodyText3.apply(color: Colors.blueAccent),),
            ),
            const SizedBox(height: 30,),
            GestureDetector(
              onTap: (){
                setState((){
                  confirmAccountDeletion = true;
                });
              },
              child: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(15),color:kBackground),
                padding: const EdgeInsets.fromLTRB(22, 9, 22, 9),
                child: Text("Delete account",style: InheritedTextStyle.of(context).kBodyText4.apply(color:kRed),),
              ),
            ),
            const SizedBox(height: 20,),
             Text(
              "Winhalla isn't endorsed by Blue Mammoth Games and doesn't reflect the views or opinions of Blue Mammoth Games or anyone officially involved in producing or managing Brawlhalla. Brawlhalla and Blue Mammoth Games are trademarks or registered trademarks of Blue Mammoth games. Brawlhalla © Blue Mammoth Games.",
              style: InheritedTextStyle.of(context).kBodyText4.apply(fontSizeFactor: 0.7,color: kText80),
            ),
          ],
        ),
      ) : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Are you sure you want to delete your account?",style: InheritedTextStyle.of(context).kBodyText2,),
              const SizedBox(height: 7,),
              Text("This action is not reversible",style: InheritedTextStyle.of(context).kBodyText3.apply(color:kText80),),
              const SizedBox(height: 15,),
              GestureDetector(
                onTap: () async {
                  var status = await http.delete(getUri("/auth/deleteAccount"), headers: {"authorization": await getNonNullSSData("authKey")});
                  if(status.statusCode >= 200 && status.statusCode <= 299){
                    await GoogleSignInApi.logout();
                    await secureStorage.write(key: "authKey", value: null);
                    Navigator.pushReplacementNamed(context, "/login");
                  }
                },
                child: Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(15),color:kRed),
                  padding: const EdgeInsets.fromLTRB(22, 9, 22, 9),
                  child: Text("Delete account",style: InheritedTextStyle.of(context).kBodyText4,),
                ),
              ),
            ],
      ),

      actions: [
        Padding(
          padding: const EdgeInsets.only(right:8.0),
          child: TextButton(
              onPressed: ()=>showLicensePage(context: context),
              child: Text("Show licences", style: InheritedTextStyle.of(context).kBodyText4.apply(color:kPrimary),),
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
