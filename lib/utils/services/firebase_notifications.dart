import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> firebaseNotifications(RemoteMessage message) async {
  print('Got a message whilst in the foreground!');
  print('Message data: ${message.data}');

  if (message.notification != null) {
    print('Message also contained a notification: ${message.notification?.body}');
  }
}

const List<Map<String, String>> notificationChannelsMaps = [{
  "id": "match_end",
  "name": "Match Ends",
  "description": "Sent when a match ends",
},{
  "id": "quest_completed",
  "name": "Quest Completions",
  "description": "Sent when a quest is completed in background",
},{
  "id": "daily_challenge_reset",
  "name": "Daily challenge reset",
  "description": "Sent when your daily challenges is available again",
},{
  "id": "other",
  "name": "Other",
  "description": "Other notifications",
}];