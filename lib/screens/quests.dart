import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/utils/userClass.dart';
import 'package:winhalla_app/widgets/quest_widget.dart';

class Quests extends StatelessWidget {
  const Quests({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text('Daily Quests', style: kHeadline1),
          ),
          SizedBox(
            height: 30,
          ),
          ListView.builder(
            itemBuilder: (context, int index) {
              return Container(
                margin: EdgeInsets.only(bottom: index != 2 - 1 ? 30.0 : 0),
                child: QuestWidget(name: "Lorem Ipsum", color:  index==0?kEpic:kPrimary, progress: index + 1, goal: 4),
              );
            },
            itemCount: 2,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
          ),
          SizedBox(
            height: 70,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text('Weekly Quests', style: kHeadline1),
          ),
          SizedBox(
            height: 30,
          ),
          ListView.builder(
            itemBuilder: (context, int index) {
              return Container(
                margin: EdgeInsets.only(bottom: index != 2 - 1 ? 30.0 : 0),
                child: QuestWidget(name: "Lorem Ipsum", color: index==0?kRed:kPrimary, progress: index + 1, goal: 4),
              );
            },
            itemCount: 2,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }
}
