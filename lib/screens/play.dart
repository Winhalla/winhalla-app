import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/screens/ffa.dart';
import 'package:winhalla_app/utils/ffaMatchClass.dart';
import 'package:winhalla_app/utils/getUri.dart';
import 'package:winhalla_app/utils/userClass.dart';
import 'package:http/http.dart' as http;

class PlayPage extends StatefulWidget {
  const PlayPage({Key? key}) : super(key: key);

  @override
  _PlayPageState createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  String? matchInProgressId;

  @override
  Widget build(BuildContext context) {
    return matchInProgressId == null
        ? Column(
            children: [
              Container(
                decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(20)),
                child: GestureDetector(
                  child: Text(
                    "Play",
                    style: kHeadline1,
                  ),
                  onTap: () async {
                    var matchId = await context.read<User>().enterMatch();
                    setState(() {
                      matchInProgressId = matchId;
                    });
                  },
                ),
              ),
            ],
          )
        :
        // Can't be null bc we check above. Null safety still there.
        SoloMatch(matchId: matchInProgressId as String);
  }
}

class SoloMatchCreator extends StatelessWidget {
  const SoloMatchCreator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
