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

  overlayState?.insert(overlayEntry);
  _previousEntry = overlayEntry;
  Future.delayed(displayDuration, () {
    _previousEntry?.remove();
  });
}

void showInfoDropdown(BuildContext context,Color color,String head, {Widget? body}){
  showTopSnackBar(
      context,
      InfoDropdown(color:color,head:head,body:body,displayDuration: 5000,),
      displayDuration:Duration(milliseconds: 5000),
      additionalTopPadding: 32
  );
}
class InfoDropdown extends StatefulWidget {
  final Color color;
  final String head;
  final Widget? body;
  final int displayDuration;
  const InfoDropdown({Key? key,required this.color,required this.head,this.body:const Text(""),this.displayDuration:3000}) : super(key: key);

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
    topPosition = -95;
    topBgPosition = -230;

    await Future.delayed(Duration(milliseconds: 1));
    setState(() {
      topPosition = 80;
      topBgPosition = 0;
    });

    await Future.delayed(Duration(milliseconds:widget.displayDuration-201));
    setState(() {
      topPosition = -95;
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
            duration: Duration(milliseconds: 200),
            curve: Curves.linearToEaseOut,
            top: topBgPosition,
            left: 0,
            right: 0,
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
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
              height: 95,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.head,
                    style: Theme.of(context).textTheme.bodyText2?.merge(TextStyle(color: widget.color, fontSize: 32)),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
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
