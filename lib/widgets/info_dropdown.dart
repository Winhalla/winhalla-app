import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';

OverlayEntry? _previousEntry;
void showTopSnackBar(
    BuildContext context,
    Widget child, {
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
      return child;
    },
  );

  // Show the popup
  overlayState?.insert(overlayEntry);
  // Remove older popup
  if(_previousEntry != null) {
    _previousEntry?.remove();
    _previousEntry = null;
  }

  _previousEntry = overlayEntry;
  Future.delayed(displayDuration, () {
    // Remove the popup after given time (after animation is finished)
    if(_previousEntry != null) {
      _previousEntry?.remove();
      _previousEntry = null;
    }
  });
}

void showInfoDropdown(
    BuildContext context,
    Color color,
    String head,
    {Widget? body, int timeShown:5000, double fontSize:32, bool column:false}
    ) {
  showTopSnackBar(
      context,
      InfoDropdown(color: color, head: head, body: body, displayDuration: timeShown, fontSize: fontSize,column:column),
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
  const InfoDropdown({
    Key? key,
    required this.fontSize,
    required this.color,
    required this.head,
    required this.column,
    this.body:const Text(""),
    this.displayDuration:3000
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

    await Future.delayed(Duration(milliseconds: 1));
    setState(() {
      topPosition = 80;
      topBgPosition = 0;
    });

    await Future.delayed(Duration(milliseconds:widget.displayDuration-352));
    setState(() {
      topPosition = -200;
      topBgPosition = -230;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
        children: [
          AnimatedPositioned(
            child: Container(
              decoration: BoxDecoration(
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
              child: SizedBox(height: 230,),
            ),
            duration: Duration(milliseconds: 350),
            curve: Curves.linearToEaseOut,
            top: topBgPosition,
            left: 0,
            right: 0,
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 450),
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
              height: widget.column?null:95,
              child: widget.column
                  ? Column(children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8,16,8,0),
                      child: Text(
                        widget.head,
                        style: Theme.of(context).textTheme.bodyText2?.merge(TextStyle(color: widget.color, fontSize:widget.fontSize)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if(widget.body != null) const SizedBox(height: 10,),
                    if(widget.body!=null) Padding(
                      padding: const EdgeInsets.fromLTRB(24,0,24,10),
                      child: widget.body as Widget,
                    )

                    ],)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.head,
                          style: Theme.of(context).textTheme.bodyText2?.merge(TextStyle(color: widget.color, fontSize: 32)),
                          textAlign: TextAlign.center,
                        ),
                        if(widget.body != null)const SizedBox(width: 20,),
                        if(widget.body!=null) Padding(
                          padding: const EdgeInsets.only(top:1.0),
                          child: widget.body as Widget,
                        )
                ],
              ),
            ),
          ),
        ]
    );
  }
}
