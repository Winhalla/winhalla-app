import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:http/http.dart' as http;
import 'package:winhalla_app/utils/getUri.dart';
import 'package:winhalla_app/utils/steam.dart';
RegExp emailChecker = new RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
Widget PopupWidget(BuildContext context,String email) {
  final TextEditingController emailTextController = TextEditingController(text:email);
  bool isEmailValid = true;
  return StatefulBuilder(builder: (context, setState) {
    emailTextController.addListener(() {
      if(emailChecker.hasMatch(emailTextController.text) && isEmailValid == false){
        setState((){
          isEmailValid = true;
          print("emailValid");
        });
      } else if(!emailChecker.hasMatch(emailTextController.text) && isEmailValid == true){
        setState((){
          isEmailValid = false;
          print("emailInvalid");
        });
      }
    });
    return AlertDialog(
      elevation: 10,
      title: Padding(
        padding: const EdgeInsets.fromLTRB(4,0,4,0),
        child: Text(
          "Confirm Purchase",
          style: kBodyText1,
        ),
      ),
      contentPadding: EdgeInsets.fromLTRB(24,18,24,isEmailValid?7:1),
      content: Padding(
        padding: const EdgeInsets.fromLTRB(4,0,4,0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left:2 ),
              child: Text('Item will be sent to:',style: kBodyText3,),
            ),
            SizedBox(height: 10,),
            Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: kBackground),
              padding: EdgeInsets.fromLTRB(20, 7, isEmailValid?20:10, 7),
              child: TextField(
                keyboardType: TextInputType.emailAddress,
                controller: emailTextController,
                style: TextStyle(fontSize: 18, color: kText80, fontFamily: "Roboto Condensed"),
                decoration: InputDecoration(
                    suffixIconConstraints: BoxConstraints(maxHeight: 30, maxWidth: 30),
                    suffixIcon: !isEmailValid?Icon(Icons.clear_outlined,color: kRed,size: 30,):
                    null,
                    border: InputBorder.none,
                    hintText: 'Email',
                    hintStyle: TextStyle(fontSize: 17, color: kText80, fontFamily: "Roboto Condensed")),
              ),
            ),
            if(!isEmailValid) Padding(
              padding: const EdgeInsets.fromLTRB(16,6,0,0),
              child: Text("Invalid Email",style: TextStyle(color: kRed,fontFamily: "Roboto Condensed",fontSize: 14),),
            )
          ],
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            if(!isEmailValid) return;
            else print("buyItem");
          },
          behavior: HitTestBehavior.translucent,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0,0,10,6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Send",
                  style: kBodyText2.apply(color: isEmailValid?kGreen:kText80),
                ),
                const SizedBox(
                  width: 5,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: Icon(
                    Icons.check,
                    color: isEmailValid?kGreen:kText80,
                    size: 30,
                  ),
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
