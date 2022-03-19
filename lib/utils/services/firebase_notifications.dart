import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> firebaseNotifications(RemoteMessage message) async {
  print('Got a message whilst in the foreground!');
  print('Message data: ${message.data}');

  if (message.notification != null) {
    print('Message also contained a notification: ${message.notification?.body}');
  }
}
