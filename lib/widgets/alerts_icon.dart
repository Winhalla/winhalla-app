import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';

import 'inherited_text_style.dart';

class AlertsIcon extends StatelessWidget {
  final int severity;
  final List infosList;
  const AlertsIcon({Key? key, required this.severity, required this.infosList}) : super(key: key);

  Color severityToColor(severity){
    if(severity < 1 || severity == null) return kPrimary;
    else if(severity == 1) return kOrange;
    else {
      return kRed;
    }
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (){
        late OverlayEntry overlayEntry;
        overlayEntry = OverlayEntry(
          builder: (context) {
            ScrollController _scrollController = ScrollController();
            return DefaultTextStyle(
              style: const TextStyle(fontFamily: "Bebas neue"),
              child: Stack(
                children: [
                  Positioned.fill(
                      child: GestureDetector(
                        onTapDown: (_) {
                          overlayEntry.remove();
                        },
                        child: Container(
                          color: Colors.transparent,
                        ),
                      )),
                  Positioned(
                    top: 17.h,
                    left: 20,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(3.25.h, 6.5.w, 3.25.h, 6.5.w),
                      constraints: BoxConstraints(maxWidth: 70.w, maxHeight: 50.h),
                      decoration: BoxDecoration(
                        color: kBackgroundVariant,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black, //color of shadow
                            offset: Offset(4,4),
                            spreadRadius: 0, //spread radius
                            blurRadius: 14, // blur radius
                          ),
                        ],
                      ),
                      child: RawScrollbar(
                        controller: _scrollController,
                        isAlwaysShown: true,
                        radius: const Radius.circular(10),
                        thumbColor: kBackground,
                        thickness: 7,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children:  [
                              for (var info in infosList)
                                Padding(
                                  padding: EdgeInsets.only(bottom: info["index"] + 1 == infosList.length ? 0 : 4.h),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(info["name"], style: InheritedTextStyle.of(context).kBodyText1.apply(fontSizeFactor: 0.9)),
                                    SizedBox(height: .8.h),
                                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Container(
                                        margin: EdgeInsets.only(top: 1.h),
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: severityToColor(info["severity"])
                                        ),
                                      ),
                                      SizedBox(width: 5.w,),
                                      Expanded(
                                        child: Text(
                                          info["description"],
                                          style: InheritedTextStyle.of(context).kBodyText3.apply(color: kText80,)
                                        )
                                      )
                                    ],)
                                  ],),
                                )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
        Overlay.of(context)?.insert(overlayEntry);
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 0),
        child: Icon(
          Icons.warning_rounded,
          size: InheritedTextStyle.of(context).kHeadline0.fontSize !* 0.85,
          color: severityToColor(severity),
        ),
      ),
    );
  }
}
