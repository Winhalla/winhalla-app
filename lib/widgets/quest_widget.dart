import 'dart:ffi';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';

import 'ad_launch_button.dart';
import 'inherited_text_style.dart';

class QuestWidget extends StatefulWidget {
  final String name;
  Color color;
  int progress;
  int goal;
  final int reward;
  final bool showAdButton;
  final oldProgress;
  final showClickToCollect;
  QuestWidget({
    Key? key,
    required this.name,
    required this.color,
    required this.progress,
    required this.goal,
    required this.reward,
    required this.oldProgress,
    this.showAdButton = false,
    this.showClickToCollect = true,
  }) : super(key: key);

  @override
  State<QuestWidget> createState() => _QuestWidgetState();
}

class _QuestWidgetState extends State<QuestWidget> with TickerProviderStateMixin {
  late final AnimationController _animationController;
  var curvedAnimation;
  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000),
    );

    double beginValue = 0;
    if (widget.oldProgress == widget.progress) beginValue = 1;

    curvedAnimation = Tween(
      begin: beginValue,
      end: 1,
    ).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutQuint));
  }

  @override
  void didUpdateWidget(QuestWidget oldWidget) {
    _animationController.reset();
    _animationController.forward();

    double beginValue = 0;
    if (widget.oldProgress == widget.progress) beginValue = 1;

    curvedAnimation = Tween(
      begin: beginValue,
      end: 1,
    ).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutQuint));
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance?.addPostFrameCallback((_){
      _animationController.forward();
    });
    return Container(
      decoration: BoxDecoration(
          color: kBackgroundVariant, borderRadius: BorderRadius.circular(16)),
      padding: EdgeInsets.fromLTRB(30, 18, 20, 18),
      child: AnimatedBuilder(
          animation: curvedAnimation,
          builder: (BuildContext context, Widget? child) {
            bool isQuestFinished =
                (widget.goal * curvedAnimation.value).round() == widget.goal &&
                    widget.progress >= widget.goal;
            if (isQuestFinished) widget.color = kGreen;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 41.w,
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: isQuestFinished
                            ? TextStyle(
                              color: kGray,
                              fontSize: 20.sp > 24 ? 24 : 20.sp,
                              fontFamily: "Roboto Condensed",
                              decoration: TextDecoration.lineThrough,
                              decorationThickness: 2,
                            )
                            : InheritedTextStyle.of(context).kBodyText2,
                        child: Text(
                          widget.name,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        AnimatedCrossFade(
                          firstChild: Text(
                              "${(widget.oldProgress + ((widget.progress - widget.oldProgress) * curvedAnimation.value).round())}/${widget.goal}",
                              style: InheritedTextStyle.of(context).kBodyText4.apply(color: widget.color)),
                          secondChild: Text("Click to collect",
                              style: InheritedTextStyle.of(context).kBodyText4.apply(color: widget.color)),
                          crossFadeState: !isQuestFinished ? CrossFadeState.showFirst : widget.showClickToCollect == false ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                          alignment: Alignment.centerLeft,
                          duration: const Duration(milliseconds: 200),
                        ),
                        if (widget.showAdButton)
                          const SizedBox(
                            width: 10,
                          ),
                        if (widget.showAdButton && widget.color != kGreen)
                          AdButton(
                            goal: 'dailyChallenge',
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(13),
                                  color: kOrange),
                              padding: const EdgeInsets.fromLTRB(19, 7, 19, 7),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 1.5),
                                    child: Image.asset(
                                      "assets/images/video_ad.png",
                                      width: 20,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 7,
                                  ),
                                  Text(
                                    "Watch",
                                    style: InheritedTextStyle.of(context).kBodyText4.apply(color: kBlack),
                                  ),
                                ],
                              ),
                            ),

                            adErrorChild: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: kText80),
                              padding:
                              const EdgeInsets.fromLTRB(15, 10, 15, 10),
                              child: Text(
                                "Ad Error.",
                                style: InheritedTextStyle.of(context).kBodyText4.apply(color: kBlack),
                              ),
                            ),
                            adNotReadyChild: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: kText80),
                              padding:
                                  const EdgeInsets.fromLTRB(15, 10, 15, 10),
                              child: Text(
                                "Loading...",
                                style: InheritedTextStyle.of(context).kBodyText4.apply(color: kBlack),
                              ),
                            ),
                          )
                      ],
                    )
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16), color: kBlack),
                  padding: const EdgeInsets.fromLTRB(15, 15, 15, 10),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          SizedBox(
                            width: 70,
                            height: 70,
                            child: CustomPaint(
                              foregroundPainter: ProgressPainter(
                                  progressColor: widget.color,
                                  percentage: curvedAnimation.value < 0.1
                                      ? 0.6
                                      : (widget.oldProgress / widget.goal +
                                                  ((widget.progress -
                                                          widget.oldProgress) /
                                                      widget.goal *
                                                      curvedAnimation.value)) *
                                              100 -
                                          0.6,
                                  width: 9),
                            ),
                          ),
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top:
                                        2), //add padding to center the font that has default bottom spacing
                                child: Builder(
                                  builder: (context) {
                                    var text = ((widget.oldProgress / widget.goal + ((widget.progress - widget.oldProgress) / widget.goal * curvedAnimation.value)) * 100).ceil();
                                    if(text > 100) text = 100;
                                    return Text(
                                        "$text%",
                                        style:
                                            InheritedTextStyle.of(context).kBodyText4.apply(color: widget.color));
                                  }
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 11.5,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 1),
                              child: Text(
                                widget.reward.toString(),
                                style: InheritedTextStyle.of(context).kBodyText4.apply(color: widget.color),
                              ),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 1),
                              child: Image.asset(
                                "assets/images/coin.png",
                                height: 20,
                                width: 20,
                                color: widget.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            );
          }),
    );
  }
}

class ProgressPainter extends CustomPainter {
  Color progressColor;
  double percentage;
  double width;

  ProgressPainter(
      {required this.progressColor,
      required this.percentage,
      required this.width});

  @override
  void paint(Canvas canvas, Size size) {
    /*Paint line = Paint()
      ..color = kBackgroundVariant
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
*/
    Paint progress = Paint()
      ..color = progressColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width - 1.9;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2.35, size.height / 2.35);

    //canvas.drawCircle(center, radius, line);

    double arcAngle = 2 * pi * (percentage / 100);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2,
        arcAngle, false, progress);
  }

  @override
  bool shouldRepaint(covariant ProgressPainter oldDelegate) {
    return oldDelegate.percentage != percentage;
  }
}
