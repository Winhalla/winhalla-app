import 'package:flutter/material.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';

class DailyChallengeItem extends StatelessWidget {
  final String name;
  final bool completed;
  const DailyChallengeItem({
    Key? key,
    required this.name,
    required this.completed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 24),
      color: kBackground,
      child: Container(

          /*constraints: const BoxConstraints(
              maxWidth: 205),*/ //MAX WIDTH - X PADDING = maxWidth - 53
          padding: EdgeInsets.fromLTRB(26, 14, completed ? 23 : 27, 14),
          decoration: BoxDecoration(
              color: kBackgroundVariant,
              borderRadius: BorderRadius.circular(12)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 130),
                child: Text(
                  name,
                  style:
                      completed ? kBodyText3.apply(color: kText80) : kBodyText3,
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
          )),
    );
  }
}
