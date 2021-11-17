import 'package:flutter/material.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';

class LegalPage extends StatelessWidget {
  const LegalPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: GestureDetector(
            onTap: (){
              Navigator.pop(context);
            },
            child: Container(
              color: kBackgroundVariant,
              padding: const EdgeInsets.only(left: 25.0, top: 20),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Icon(Icons.arrow_back,color: kText,size: 30,),
              ),
            ),
          ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24,8,24,8),
        child: Column(children: [
          GestureDetector(
              onTap: ()=>showLicensePage(context: context),
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 12, 25, 12),
                decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(14)),
                child: const Text("Show licences",style: kBodyText4,),
              ),
          ),
        ],),
      ),
    );
  }
}
