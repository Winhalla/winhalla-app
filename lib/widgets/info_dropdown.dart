import 'dart:async';

import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/utils/launch_url.dart';

import 'inherited_text_style.dart';

OverlayEntry? _previousEntry;
Timer? timer;
void showTopSnackBar(
    BuildContext context,
    Widget Function(OverlayEntry) child, {
      Duration showOutAnimationDuration = const Duration(milliseconds: 1200),
      Duration hideOutAnimationDuration = const Duration(milliseconds: 550),
      Duration displayDuration = const Duration(milliseconds: 3000),
      double additionalTopPadding = 16.0,
      VoidCallback? onTap,
      OverlayState? overlayState,
    }) async {
  overlayState ??= Overlay.of(context);
  late OverlayEntry overlayEntry;
  overlayEntry = OverlayEntry(
    builder: (context) {
      return child(overlayEntry);
    },
  );

  // Show the popup
  overlayState?.insert(overlayEntry);
  // Remove older popup
  if(_previousEntry != null) {
    _previousEntry?.remove();
    _previousEntry = null;
    timer?.cancel();
  }

  _previousEntry = overlayEntry;
  timer = Timer(displayDuration, () {
    // Remove the popup after given time (after animation is finished)
    if(_previousEntry != null) {
      if(_previousEntry?.mounted == true) _previousEntry?.remove();
      _previousEntry = null;
    }
  });
}

void showInfoDropdown(
    BuildContext context,
    Color color,
    String head,
    {Widget? body, int timeShown =5000, double fontSize =32, bool column =false, bool isError = false}
    ) {
  if(isError) timeShown = 12000;
  showTopSnackBar(
      context,
      (overlay) =>
        InfoDropdown(color: color, head: head, body: body, displayDuration: timeShown, fontSize: fontSize,column:column, isError: isError, overlayEntry: overlay),
      displayDuration:Duration(milliseconds: timeShown),
      additionalTopPadding: 32
  );
}
class InfoDropdown extends StatefulWidget {
  final Color color;
  final String head;
  final Widget? body;
  final int displayDuration;
  final double fontSize;
  final bool column;
  final bool isError;
  final OverlayEntry overlayEntry;
  const InfoDropdown({
    Key? key,
    required this.fontSize,
    required this.color,
    required this.head,
    required this.column,
    required this.isError,
    required this.overlayEntry,this.body =const Text(""),
    this.displayDuration =3000
  }) : super(key: key);

  @override
  _InfoDropdownState createState() => _InfoDropdownState();
}

class _InfoDropdownState extends State<InfoDropdown> with SingleTickerProviderStateMixin {
  double? topPosition;
  double? topBgPosition;

  @override
  void initState() {
    _setupAndStartAnimation();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _setupAndStartAnimation() async {
    topPosition = -200;
    topBgPosition = -230;

    await Future.delayed(const Duration(milliseconds: 1));
    setState(() {
      topPosition = 80;
      topBgPosition = 0;
    });

    await Future.delayed(Duration(milliseconds:widget.displayDuration-352));
    if(mounted) {
      setState(() {
        topPosition = -200;
        topBgPosition = -230;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
        children: [
          AnimatedPositioned(
            child: Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0,0.7,1],
                      colors: [
                        Color(0xff000000),
                        Color(0xaa000000),
                        Color(0x00000000)
                      ]
                  )
              ),
              child: const SizedBox(height: 230,),
            ),
            duration: const Duration(milliseconds: 350),
            curve: Curves.linearToEaseOut,
            top: topBgPosition,
            left: 0,
            right: 0,
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 450),
            curve: Curves.linearToEaseOut,
            top: topPosition,
            left: 25,
            right: 25,
            child: Container(
              decoration: BoxDecoration(
                  color: kBackgroundVariant,
                  border: Border.all(color: widget.color),
                  borderRadius: BorderRadius.circular(20)
              ),
              // height: widget.column?null:95,
              child: widget.column
                  ? Column(children: [

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // This icon is used to center the text right
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 20, 0 ,8),
                            child: Icon(Icons.clear_outlined,
                              size: InheritedTextStyle.of(context).kHeadline2.apply(fontSizeFactor: 0.9).fontSize,
                              color: kBackgroundVariant,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8,16,8,0),
                            child: Text(
                              widget.head,
                              style: Theme.of(context).textTheme.bodyText2?.merge(
                                    InheritedTextStyle.of(context).kBodyText4.apply(fontSizeFactor: widget.fontSize/20,color:widget.color)
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          // This one is the real cross
                          GestureDetector(
                            onTap: (){
                              widget.overlayEntry.remove();
                            },
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 20, 0 ,8),
                              child: Icon(Icons.clear_outlined,
                                size: InheritedTextStyle.of(context).kHeadline2.apply(fontSizeFactor: 0.8).fontSize,
                                color: widget.color,
                              ),
                            ),
                          )
                        ],
                      ),
                      if(widget.body != null) const SizedBox(height: 10,),
                      if(widget.body!=null) Padding(
                        padding: const EdgeInsets.fromLTRB(24,0,24,10),
                        child: widget.body as Widget,
                      ),
                      SizedBox(height:1.h ,),

                      if(widget.isError)Text(
                        "If this error persists,",
                        style: Theme.of(context).textTheme.bodyText2?.merge(
                          InheritedTextStyle.of(context).kBodyText3.apply(fontSizeFactor: .7, color: kText),
                        )
                      ),
                      if(widget.isError)Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "please ",
                            style:Theme.of(context).textTheme.bodyText2?.merge(
                              InheritedTextStyle.of(context).kBodyText3.apply(fontSizeFactor: .7, color: kText),
                            ),
                          ),
                          GestureDetector(
                            onTap: (){
                              launchMailto("contact@winhalla.app");
                            },
                            child: Text(
                              "contact support",
                              style: Theme.of(context).textTheme.bodyText2?.merge(
                                InheritedTextStyle.of(context).kBodyText4.apply(fontSizeFactor: 1.1, color: kPrimary, decoration: TextDecoration.underline),
                              )
                            ),
                          )
                        ],
                      ),
                      SizedBox(height:2.h ,)

                    ],)
                  : Column(
                    children: [
                      SizedBox(height: 3.h + 4 /* 4px for the font's padding*/ ,),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.head,
                              style: Theme.of(context).textTheme.bodyText2?.merge(
                                  InheritedTextStyle.of(context).kBodyText4.apply(fontSizeFactor: 1.6,color:widget.color)
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if(widget.body != null)const SizedBox(width: 20,),
                            if(widget.body!=null) Padding(
                              padding: const EdgeInsets.only(top:1.0),
                              child: widget.body as Widget,
                            )
                        ],
                      ),
                      SizedBox(height:2.h ,),
                      if(widget.isError)Text(
                          "If this error persists,",
                          style: Theme.of(context).textTheme.bodyText2?.merge(
                            InheritedTextStyle.of(context).kBodyText3.apply(fontSizeFactor: .7, color: kText),
                          )
                      ),
                      if(widget.isError)Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "please ",
                            style:Theme.of(context).textTheme.bodyText2?.merge(
                              InheritedTextStyle.of(context).kBodyText3.apply(fontSizeFactor: .7, color: kText),
                            ),
                          ),
                          GestureDetector(
                            onTap: (){
                              launchMailto("contact@winhalla.app");
                            },
                            child: Text(
                                "contact support",
                                style: Theme.of(context).textTheme.bodyText2?.merge(
                                  InheritedTextStyle.of(context).kBodyText4.apply(fontSizeFactor: .85, color: kPrimary, decoration: TextDecoration.underline),
                                )
                            ),
                          )
                        ],
                      ),
                      SizedBox(height:1.h ,),
                    ],
                  ),
            ),
          ),
        ]
    );
  }
}
