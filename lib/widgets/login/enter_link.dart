import 'dart:async';
import 'dart:math';
// import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/screens/login.dart';
import 'package:winhalla_app/utils/custom_http.dart';
import 'package:winhalla_app/utils/get_uri.dart';
import 'package:winhalla_app/utils/services/secure_storage_service.dart';
import 'package:winhalla_app/widgets/login/google_apple_login.dart';

import '../inherited_text_style.dart';

class EnterLink extends StatefulWidget {
  const EnterLink({Key? key}) : super(key: key);

  @override
  _EnterLinkState createState() => _EnterLinkState();
}

class _EnterLinkState extends State<EnterLink> {
  TextEditingController link = TextEditingController();
  Timer t = Timer(const Duration(milliseconds: 400), () {});
  bool? linkValid;
  bool loading = false;
  bool isMounted = false;
  @override
  void dispose() {
    link.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(42.5, 40, 42.5, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: GestureDetector(
              onTap: () {
                GoogleSignInApi.logout();
                context.read<LoginPageManager>().next(goBack: true);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.rotate(
                      angle: 180 * pi / 180,
                      child:
                      Icon(Icons.arrow_forward, color:kRed.withOpacity(0.8))
                  ),
                  const SizedBox(width: 7,),
                  Text("Back", style: InheritedTextStyle.of(context).kBodyText2.apply(color:kRed.withOpacity(0.8)),)
                ],
              ),
            ),
          ),
          SizedBox(height: 2.h,),
          Text(
            "Referral link",
            style: InheritedTextStyle.of(context).kHeadline0
          ),
          const SizedBox(height: 20,),
          Text(
            "If a friend shared the app with you, enter his link here. \nIf not, skip this step.",
            style: InheritedTextStyle.of(context).kBodyText2.apply(color:kText80),
          ),
          const SizedBox(height: 50,),
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: kBackgroundVariant),
            padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
            child: TextField(
              controller: link,
              onChanged: (String text){
                if(text.isNotEmpty){
                  setState(() {
                    loading = true;
                  });
                  t.cancel();
                  t = Timer(const Duration(milliseconds: 500), () async {
                    String linkId = "";
                    try{
                      linkId = Uri.parse(text).pathSegments[1];
                    } catch(e){
                      setState(() {
                        linkValid = false;
                        loading = false;
                      });
                      return;
                    }
                    var isLinkValid = await http.get(getUri("/auth/checkLink/$linkId"));
                    setState(() {
                      linkValid = isLinkValid.body == "true";
                      loading = false;
                    });
                  });
                } else {
                  t.cancel();
                  setState(() {
                    loading = false;
                    linkValid = null;
                  });
                }
              },
              style: InheritedTextStyle.of(context).kBodyText3.apply(fontSizeFactor: 0.9,color: kText),
              decoration: InputDecoration(
                  suffixIconConstraints: const BoxConstraints(maxHeight: 37, maxWidth: 35),
                  suffixIcon: loading == true
                      ? const Padding(
                    padding: EdgeInsets.fromLTRB(10, 6, 0, 6),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                    ),
                  )
                      : linkValid == false
                      ? const Padding(
                    padding: EdgeInsets.only(left: 4.0),
                    child: Icon(
                      Icons.clear_outlined,
                      color: kRed,
                      size: 34,
                    ),
                  )
                      : linkValid == true
                      ?const Padding(
                    padding: EdgeInsets.only(left: 4.0),
                    child: Icon(
                      Icons.check,
                      color: kGreen,
                      size: 34,
                    ),
                  ):null,
                  border: InputBorder.none,
                  hintText: 'Paste your referral link here',
                  hintStyle: InheritedTextStyle.of(context).kBodyText3.apply(fontSizeFactor: 0.9,color: kText80)),
            ),
          ),

          if(linkValid == false) Padding(
            padding: const EdgeInsets.only(left: 8.0, top:8),
            child: Text("This link doesn't exist", style: InheritedTextStyle.of(context).kBodyText3.apply(fontSizeFactor: 0.85,color: kRed),),
          )
          else if(linkValid == true) Padding(
            padding: const EdgeInsets.only(left: 8.0, top:8),
            child: Text("Link valid and boost applied!", style: InheritedTextStyle.of(context).kBodyText3.apply(fontSizeFactor: 0.85,color: kGreen),),
          ),

          const Expanded(child:Text("")),
          Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: () async {
                  if(linkValid != true){
                    context.read<LoginPageManager>().next();
                    return;
                  }
                  try{
                    var linkId = Uri.parse(link.text).pathSegments[1];
                    await secureStorage.write(key: "link", value: linkId);
                    context.read<LoginPageManager>().next();
                  } catch(e){
                    context.read<LoginPageManager>().next();
                    return;
                  }

                },
                child: Container(
                    decoration: BoxDecoration(
                      color:kBackgroundVariant,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding:const EdgeInsets.fromLTRB(25, 15, 25, 15),
                    child:Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(linkValid == true ? "Next" : "Skip", style: InheritedTextStyle.of(context).kBodyText2.apply(color:kPrimary),),
                        const SizedBox(width: 7,),
                        const Icon(Icons.arrow_forward, color:kPrimary)
                      ],
                    )
                ),
              )
          ),
          const SizedBox(height: 40,)
        ],),
    );
  }
}