import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class FirebaseMessagingDemo extends StatefulWidget {
  FirebaseMessagingDemo() : super();

  @override
  _FirebaseMessagingDemoState createState() => _FirebaseMessagingDemoState();
}

class _FirebaseMessagingDemoState extends State<FirebaseMessagingDemo> {
  final FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

  getToken() {
    firebaseMessaging.getToken().then((deviceToken) => print("$deviceToken"));
  }

  configureFirebaseLitseners() {
    firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
      print("onMessage: $message");
    }, onLaunch: (Map<String, dynamic> message) async {
      print("onMessage: $message");
    }, onResume: (Map<String, dynamic> message) async {
      print("onMessage: $message");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
