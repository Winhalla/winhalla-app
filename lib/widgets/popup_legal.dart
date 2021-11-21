import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/screens/login.dart';
import 'package:winhalla_app/utils/get_uri.dart';
import 'package:winhalla_app/utils/launch_url.dart';
import 'package:winhalla_app/utils/services/secure_storage_service.dart';
import 'package:winhalla_app/widgets/tip_painter.dart';
import 'package:share/share.dart';
import 'package:http/http.dart' as http;

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
            const Text(
              "Legal",
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

      // contentPadding: const EdgeInsets.fromLTRB(24, 5, 24, 30),
      content: Padding(
        padding: const EdgeInsets.fromLTRB(4,0,4,0),
        child: !confirmAccountDeletion?Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Privacy policy: ", style: kBodyText2,),
            GestureDetector(
              onTap: (){
                launchURLBrowser("https://winhalla.app/privacy");
              },
              child: Text("https://winhalla.app/privacy", style: kBodyText3.apply(color: Colors.blueAccent),),
            ),
            const SizedBox(height: 20,),
            const Text("Terms of use: ", style: kBodyText2,),
            GestureDetector(
              onTap: (){
                launchURLBrowser("https://winhalla.app/terms");
              },
              child: Text("https://winhalla.app/terms", style: kBodyText3.apply(color: Colors.blueAccent),),
            ),
            const SizedBox(height: 20,),
            const Text("Legal mentions: ", style: kBodyText2,),
            GestureDetector(
              onTap: (){
                launchURLBrowser("https://winhalla.app/legal");
              },
              child: Text("https://winhalla.app/legal", style: kBodyText3.apply(color: Colors.blueAccent),),
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
                child: Text("Delete account",style: kBodyText4.apply(color:kRed),),
              ),
            )
          ],
        ) : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Are you sure you want to delete your account?",style: kBodyText2,),
                const SizedBox(height: 7,),
                Text("This action is not reversible",style: kBodyText3.apply(color:kText80),),
                const SizedBox(height: 15,),
                GestureDetector(
                  onTap: () async {
                    var status = await http.delete(getUri("/auth/deleteAccount"), headers: {"authorization": await getNonNullSSData("authKey")});
                    if(status.statusCode >= 200 && status.statusCode <= 299){
                      await secureStorage.write(key: "authKey", value: null);
                      await GoogleSignInApi.logout();
                      Navigator.pushReplacementNamed(context, "/login");
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(15),color:kRed),
                    padding: const EdgeInsets.fromLTRB(22, 9, 22, 9),
                    child: Text("Delete account",style: kBodyText4,),
                  ),
                )
              ],
        )
      ),

      actions: [
        Padding(
          padding: const EdgeInsets.only(right:8.0),
          child: TextButton(
              onPressed: ()=>showLicensePage(context: context),
              child: Text("Show licences", style: kBodyText4.apply(color:kPrimary),),
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
