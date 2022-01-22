import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/utils/launch_url.dart';
import 'package:winhalla_app/widgets/inherited_text_style.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  @override
  Widget build(BuildContext context) {
    final List supportWays = [
      {
        "quote": RichText(
          text: TextSpan(style: InheritedTextStyle.of(context).kBodyText2, children: [
            const TextSpan(
              text: "Contact our support on ",
            ),
            TextSpan(
              text: "Discord",
              style:InheritedTextStyle.of(context).kBodyText2.apply(color: kPrimary, decoration: TextDecoration.underline),
              recognizer: TapGestureRecognizer()..onTap = () => launchURLBrowser("https://discord.gg/Yb3vNASfXf"),
            ),
            const TextSpan(text: ", or send us an ", ),
            TextSpan(
              text: "email",
              style:InheritedTextStyle.of(context).kBodyText2.apply(color: kPrimary, decoration: TextDecoration.underline) ,
              recognizer: TapGestureRecognizer()..onTap = () => launchMailto("contact@winhalla.app"),
            ),
            const TextSpan(text: " describing your issue.")
          ]),
        ),
        "author": "Support/issue/help"
      },
      {
        "quote": RichText(
          text: TextSpan(style: InheritedTextStyle.of(context).kBodyText2, children: [
            const TextSpan(
              text: "If you have a question or a suggestion, contact us on ",
            ),
            TextSpan(
              text: "Discord",
              style:InheritedTextStyle.of(context).kBodyText2.apply(color: kPrimary, decoration: TextDecoration.underline),
              recognizer: TapGestureRecognizer()..onTap = () => launchURLBrowser("https://discord.gg/Yb3vNASfXf"),
            ),
            const TextSpan(text: " or ", ),
            TextSpan(
              text: "Instagram",
              style: InheritedTextStyle.of(context).kBodyText2.apply(color: kPrimary, decoration: TextDecoration.underline),
              recognizer: TapGestureRecognizer()..onTap = () => launchURLBrowser("https://www.instagram.com/winhalla/"),
            ),
            const TextSpan(text: "!")
          ]),
        ),
        "author": "Question/suggestion"
      },
      {
        "quote": RichText(
          text: TextSpan(style: InheritedTextStyle.of(context).kBodyText2, children: [
            const TextSpan(
              text: "You are a content creator interested in promoting Winhalla, or you want to discuss with our commercial team? Send us an ",
            ),
            TextSpan(
              text: "email",
              style:InheritedTextStyle.of(context).kBodyText2.apply(color: kPrimary,decoration: TextDecoration.underline),
              recognizer: TapGestureRecognizer()..onTap = () => launchMailto("contact@winhalla.app"),
            ),
            const TextSpan(text: ".", ),
          ]),
        ),
        "author": "Business/partnerships"
      },
    ];
    return Scaffold(
      backgroundColor: kBackground,
      appBar: PreferredSize(
          child: Padding(
            padding: EdgeInsets.fromLTRB(30, 2.h, 38, 3.5.h),
            child: Row(children: [
              GestureDetector(
                behavior:HitTestBehavior.translucent,
                onTap: ()=>Navigator.pop(context),
                child: Icon(Icons.arrow_back, color: kText, size: InheritedTextStyle.of(context).kHeadline2.fontSize,)
              ),
              SizedBox(width: 5.w,),
              Padding(
                padding: const EdgeInsets.only(top: 3.5),
                child: Text("Contact", style: InheritedTextStyle.of(context).kBodyText1,),
              )
            ],),
          ),
          preferredSize: Size.fromHeight(12.h),
      ),
      body: Padding(
          padding: EdgeInsets.fromLTRB(32, 1.25.h, 32, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.only(bottom: 3.h,),
                itemCount: supportWays.length,
                itemBuilder: (BuildContext context, int index) {
                  return IconTheme(
                    data: IconThemeData(size: InheritedTextStyle.of(context).kHeadline1.apply(color:kText80).fontSize), // Edit this to change the dropdown icon size
                    child: ExpansionTile(
                      initiallyExpanded: index == 0,
                      iconColor: kText,
                      collapsedIconColor: kText,
                      title: Text(
                        supportWays[index]['author'],
                        style: InheritedTextStyle.of(context).kBodyText1.apply(color:kText80),
                      ),
                      children: <Widget>[
                        ListTile(
                          title: supportWays[index]['quote'],
                        )
                      ],
                    ),
                  );
                },
              ),
              Container(
                margin: EdgeInsets.only(bottom: 7.5.h),
                decoration: BoxDecoration(
                    color: kBackgroundVariant,
                    borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.fromLTRB(20, 23, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(style: InheritedTextStyle.of(context).kBodyText2.apply(fontSizeFactor: 1.05), children: const [
                        TextSpan(
                          text: "Winhalla's ",
                        ),
                        TextSpan(
                          text: "official ",
                          style: TextStyle(color: kEpic),
                        ),
                        TextSpan(text: "accounts:", ),
                      ]),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 15),
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                      decoration: BoxDecoration(
                        color: kBackground,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          for (int i = 0; i < socialIconsAssets.length; i++)
                          GestureDetector(
                            onTap: () => launchURLBrowser(socialIconsAssets[i]["link"] as String),
                            child: Image.asset(
                              socialIconsAssets[i]["path"] as String,
                              color: kText,
                              width: 32,
                            ),
                          ),
                      ],),
                    ),
                  ],
                ),
              )
            ],
          )
      ),
    );
  }
}
List<Map<String,String>> socialIconsAssets = [
  {
    "path":"assets/images/icons/socialIcons/discord.png",
    "link":"https://discord.gg/Yb3vNASfXf"
  },{
    "path":"assets/images/icons/socialIcons/instagram.png",
    "link":"https://www.instagram.com/winhalla/"
  },{
    "path":"assets/images/icons/socialIcons/tiktok.png",
    "link":"https://www.tiktok.com/@winhalla"
  },{
    "path":"assets/images/icons/socialIcons/youtube.png",
    "link":"https://www.youtube.com/channel/UCrIHDenuTEVdbqn4SJpNn4Q"
  },
];