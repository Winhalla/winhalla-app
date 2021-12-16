import 'package:flutter/material.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';

import '../quest_widget.dart';

class DailyChallengeItem extends StatefulWidget {
  final String name;
  bool completed;
  bool isActive;

  final int reward;
  final int goal;
  final int progress;
  final bool showAdButton;
  final int oldProgress;
  final bool wasActive;
  DailyChallengeItem(
      {Key? key,
      required this.name,
      required this.completed,
      required this.isActive,
      this.reward = 10,
      this.goal = 1,
      this.progress = 0,
      this.showAdButton = false,
      this.oldProgress = 0,
      required this.wasActive})
      : super(key: key);

  @override
  State<DailyChallengeItem> createState() => _DailyChallengeItemState();
}

class _DailyChallengeItemState extends State<DailyChallengeItem> {
  final Color color = kOrange;

  late bool isActive;
  @override
  void initState() {
    isActive = widget.wasActive;

    Future.delayed(const Duration(milliseconds: 1700), () {
      setState(() {
        isActive = widget.isActive;
      });
    });
    super.initState();
  }

  @override
  void didUpdateWidget(DailyChallengeItem oldWidget) {

    super.didUpdateWidget(oldWidget);
  }

  
  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
        crossFadeState: isActive == true
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond,
        duration: Duration(milliseconds: 400),
        firstCurve: Curves.easeInOut,
        secondCurve: Curves.easeInOutCirc,
        firstChild: QuestWidget(
          name: widget.name,
          color: color,
          reward: widget.reward,
          goal: widget.goal,
          progress: widget.progress ,
          showAdButton: widget.showAdButton,
          oldProgress: widget.oldProgress,
          showClickToCollect: false
        ),
        secondChild: widget.completed == false && isActive == false
            ? Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClosedDailyChallengeItem(
                      name: widget.name, completed: widget.completed),
                  Padding(
                    padding: const EdgeInsets.only(top: 21),
                    child: Row(
                      children: [
                        Text(
                          widget.reward.toString(),
                          style: kBodyText3,
                        ),
                        const SizedBox(width: 3.40),
                        Image.asset(
                          "assets/images/CoinText90.png",
                          height: 25,
                          width: 25,
                        )
                      ],
                    ),
                  ),
                ],
              )
            : ClosedDailyChallengeItem(
                name: widget.name, completed: widget.completed)
        /*layoutBuilder: (topChild, topKey, bottomChild, bottomKey) {
          return Stack(
            alignment: Alignment.topLeft,
            children: [
              Positioned(
                key: bottomKey,
                top: 0,
                child: bottomChild,
              ),
              Positioned(
                key: topKey,
                child: topChild,
              ),
            ],
          );
        }*/
        );
  }
}

class ClosedDailyChallengeItem extends StatelessWidget {
  final String name;
  final bool completed;
  const ClosedDailyChallengeItem(
      {Key? key, required this.name, required this.completed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(right: 24),
        color: kBackground,//.withOpacity(0.5),
        child: Container(
            
            /*constraints: const BoxConstraints(
              maxWidth: 205),*/ //MAX WIDTH - X PADDING = maxWidth - 53
            padding: EdgeInsets.fromLTRB(26, 14, completed ? 23 : 27, 14),
            decoration: BoxDecoration(
                color: kBackgroundVariant,//.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 130),
                  child: Text(
                    name,
                    style: completed
                        ? kBodyText3.apply(color: kText80)
                        : kBodyText3,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                if (completed)
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    color: kText80,
                  )
              ],
            )));
  }
}
