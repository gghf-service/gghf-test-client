import 'package:firebase_messaging/firebase_messaging.dart';

Future<String> instanceId() async {
  final firebaseMessaging = new FirebaseMessaging();
  final token = await firebaseMessaging.getToken();
  return token;
}