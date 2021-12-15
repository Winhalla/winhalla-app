import 'dart:async';

import 'package:flutter/material.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'coin.dart';

OverlayEntry? _previousEntry;

void showTopSnackBar(
  BuildContext context,
  Widget child, {
  Duration showOutAnimationDuration = const Duration(milliseconds: 1200),
  Duration hideOutAnimationDuration = const Duration(milliseconds: 550),
  Duration displayDuration = const Duration(milliseconds: 3000),
  double additionalTopPadding = 16.0,
}) async {
  OverlayState overlayState;
  overlayState = Overlay.of(context) as OverlayState;

  late OverlayEntry overlayEntry;
  overlayEntry = OverlayEntry(
    builder: (context) {
      return child;
    },
  );

  // Show the popup
  overlayState.insert(overlayEntry);
  // Remove older popup
  if (_previousEntry != null) {
    _previousEntry?.remove();
    _previousEntry = null;
  }

  _previousEntry = overlayEntry;
  Future.delayed(displayDuration, () {
    // Remove the popup after given time (after animation is finished)
    if (_previousEntry != null) {
      _previousEntry?.remove();
      _previousEntry = null;
    }
  });
}

void showCoinDropdown(BuildContext context, num currentCoins, num coinsNb) {
  showTopSnackBar(
    context,
    InfoDropdown(showDuration: 5000, currentCoins: currentCoins, coinsNb: coinsNb),
    displayDuration: const Duration(milliseconds: 5000),
    additionalTopPadding: 32
  );
}

class InfoDropdown extends StatefulWidget {
  final num coinsNb;
  final num currentCoins;
  final int showDuration;
  const InfoDropdown({
    Key? key,
    required this.showDuration,
    required this.currentCoins,
    required this.coinsNb,
  })
      : super(key: key);

  @override
  _InfoDropdownState createState() => _InfoDropdownState();
}

class _InfoDropdownState extends State<InfoDropdown> with SingleTickerProviderStateMixin {
  double? topPosition;
  double? topBgPosition;
  num coinsNb = 0;
  num currentCoins = 0;
  num removedCoinsByTick = 0;

  @override
  void initState() {
    coinsNb = widget.coinsNb;
    currentCoins = widget.currentCoins;
    removedCoinsByTick = widget.coinsNb/3;
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


    Future.delayed(Duration(milliseconds: widget.showDuration-352),(){
      if (mounted) {
        setState(() {
          topPosition = -200;
          topBgPosition = -230;
        });
      }
    });

    for(int i = 0; i<3; i++){
      await Future.delayed(const Duration(milliseconds: 750), () {
        if(!mounted) return;
        setState(() {
          if(i == 2){
            // coinsNb = 0;
            currentCoins = widget.coinsNb + widget.currentCoins;
            return;
          }
          currentCoins += removedCoinsByTick;
          // coinsNb -= removedCoinsByTick;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(fontFamily: "bebas neue"),
      child: Stack(alignment: Alignment.center, children: [
        AnimatedPositioned(
          child: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0,0.5,1],
                    colors: [
                      Color(0xff000000),
                      Color(0xaa000000),
                      Color(0x00000000)
                    ])),
            child: const SizedBox(
              height: 230,
            ),
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
          child: Container(
            padding: const EdgeInsets.fromLTRB(0, 5, 25, 5),
            decoration: BoxDecoration(
                color: kBackgroundVariant,
                borderRadius: BorderRadius.circular(14)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Coin(nb: currentCoins.toStringAsFixed(0),),
                Container(
                  padding: const EdgeInsets.fromLTRB(15, 7, 15, 7),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(14)
                  ),
                  child: Text("+${coinsNb.toStringAsFixed(0)}",style: kBodyText2.apply(color:kEpic, fontFamily: "Roboto condensed"),)
                ),
              ],
            ),
          )
        ),
      ]),
    );
  }
}
