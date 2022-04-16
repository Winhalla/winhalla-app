import 'dart:async';

import 'package:flutter/material.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/widgets/inherited_text_style.dart';

class TimerWidget extends StatefulWidget {
  final int numberOfSeconds;
  final String showHours;
  final double fontSize;

  const TimerWidget({Key? key, required this.numberOfSeconds, required this.showHours, this.fontSize: 32}) : super(key: key);

  @override
  _TimerWidgetState createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  String timer = "";
  bool alreadyBuilt = false;
  Color color = kPrimary;
  Timer? _timer;

  @override
  void dispose() {
    if (_timer != null) _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    var numberOfSeconds = widget.numberOfSeconds -10;
    if(numberOfSeconds < 0){
      Future.delayed(const Duration(milliseconds: 1), () {
        setState(() {
          timer = "00:00";
          color = kRed;
        });
      });
      return;
    }
    const oneSec = Duration(seconds: 1);
    int days = (widget.numberOfSeconds / 86400).floor();
    int hours = (widget.numberOfSeconds / 3600).floor() - days * 24;
    int minutes = (widget.numberOfSeconds / 60).floor() - hours * 60 - days * 1440;
    int seconds = widget.numberOfSeconds % 60;

    void timerFx(Timer? cancel) {
      if (numberOfSeconds != widget.numberOfSeconds - 10) {
        numberOfSeconds = widget.numberOfSeconds - 10;
        days = (numberOfSeconds / 86400).floor();
        hours = (numberOfSeconds / 3600).floor() - days * 24;
        minutes = (numberOfSeconds / 60).floor() - hours * 60 - days * 1440;
        seconds = numberOfSeconds % 60;
      }
      if (seconds == 0 && minutes == 0 && hours == 0 && days == 0) {
        setState(() {
          timer = "00:00";
          color = kRed;
        });
        if (cancel != null) cancel.cancel();
        return;
      } else if (seconds == 0 && minutes == 0 && hours == 0) {
        seconds = 59;
        minutes = 59;
        hours = 23;
        days -= 1;
      } else if (seconds == 0 && minutes == 0) {
        seconds = 59;
        minutes = 59;
        hours -= 1;
      } else if (seconds == 0) {
        seconds = 59;
        minutes -= 1;
      } else {
        seconds -= 1;
      }

      // Jss c'est moche
      timer = "";
      if (days < 10 && widget.showHours == "days") timer += "$days:";

      if (hours < 10 && (widget.showHours == "hours" || widget.showHours == "days")) {
        timer += "0$hours:";
      } else if (widget.showHours == "hours" || widget.showHours == "days") {
        timer += "$hours:";
      }

      if (minutes < 10) {
        timer += "0$minutes:";
      } else {
        timer += "$minutes:";
      }

      if (seconds < 10) {
        timer += "0$seconds";
      } else {
        timer += "$seconds";
      }

      // Do not set state for the initial call of the function (to avoid setState() or markNeedsBuild() called during build.)
      if (cancel != null) {
        setState(() {
          timer = timer;
        });
      }
    }

    timerFx(null);
    _timer = Timer.periodic(oneSec, timerFx);
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (BuildContext context) {
      if (alreadyBuilt == false) {
        alreadyBuilt = true;
        startTimer();
      }
      return Text(
        timer == "" ? "Loading..." : timer,
        style: InheritedTextStyle.of(context).kBodyText4.apply(fontSizeFactor: widget.fontSize/20,color:color),
      );
    });
  }
}
