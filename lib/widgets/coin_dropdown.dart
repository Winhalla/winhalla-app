import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/utils/user_class.dart';
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
      InfoDropdown(showDuration: 6000, currentCoins: currentCoins, coinsNb: coinsNb),
      displayDuration: const Duration(milliseconds: 6000),
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
  GlobalKey coinIconKey = GlobalKey();
  List<bool> coinsShown = [false,false,false];
  List<List<double?>> coinPosition = [[null,null],[],[]];
  int? waitingForBuild;
  Offset? offset;
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
    RenderBox box = coinIconKey.currentContext?.findRenderObject() as RenderBox;
    offset = box.localToGlobal(Offset.zero);


    Future.delayed(Duration(milliseconds: widget.showDuration-352),(){
      if (mounted) {
        setState(() {
          topPosition = -200;
          topBgPosition = -230;
        });
      }
    });

    for(int i = 0; i<4; i++){
      await Future.delayed(const Duration(milliseconds: 200), () {
        if(!mounted) return;
        if(i != 3){
          setState((){
            coinPosition[i] = [null,null];
            coinsShown[i] = true;
            waitingForBuild = i;
          });
        }

      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if(waitingForBuild != null) {
      WidgetsBinding.instance!.addPostFrameCallback((_){
        setState(() {
          coinPosition[waitingForBuild as int] = [(offset as Offset).dy+280, (offset as Offset).dx];
          coinsShown[waitingForBuild as int] = true;
          int i = (waitingForBuild as int) +1;
          waitingForBuild = null;
          Future.delayed(const Duration(milliseconds: 500),(){
            if(i > 0){

              setState(() {
                print(coinsShown);
                coinsShown[i-1] = false;
                print(coinsShown);
                if(i == 3){
                  // coinsNb = 0;
                  currentCoins = widget.coinsNb + widget.currentCoins;
                  return;
                }
                currentCoins += removedCoinsByTick;
                // coinsNb -= removedCoinsByTick;
              });
            }
          });
        });
      });
    }
    double screenH = MediaQuery.of(context).size.height;
    double screenW = MediaQuery.of(context).size.width;
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
            curve: Curves.linear,
            top: topPosition,
            child: Container(
              padding: const EdgeInsets.fromLTRB(0, 5, 15, 5),
              decoration: BoxDecoration(
                  color: kBackgroundVariant,
                  borderRadius: BorderRadius.circular(14)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Coin(nb: currentCoins.toStringAsFixed(1),key1: coinIconKey,),
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
        for (int i = 0; i < 3; i++)
          if (coinsShown[i])
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInToLinear,
              top: coinPosition[i][0] ?? screenH / 4,
              left: coinPosition[i][1] ?? screenW / 2,
              child: Image.asset("assets/images/coin.png", height: 30, width: 30, color:kPrimary/*i==0?kGreen:i==1?kOrange:kRed*/),
            )
          else Container(),
      ]),
    );
  }
}
