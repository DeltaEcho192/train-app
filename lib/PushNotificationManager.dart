import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'navKey.dart';
import 'package:flutter/material.dart';
import 'screenSwap/dialogMain.dart';
import 'bauData.dart';
import 'dart:convert';

class PushNotificationsManager {
  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance =
      PushNotificationsManager._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool _initialized = false;

  Future<String> init() async {
    if (!_initialized) {
      // For iOS request permission first.
      final navigatorKey = SfcKeys.navKey;
      _firebaseMessaging.requestNotificationPermissions();

      _firebaseMessaging.configure(
          onBackgroundMessage: _firebaseMessagingBackgroundHandler,
          onMessage: (message) async {},
          onResume: (message) async {
            print("onResume notification handler");
            BauData baudataL = BauData();
            Map notiData = await _handleNotification(message);
            print(notiData);
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('baustellePref', notiData["bauName"]);
            prefs.setString('bauID', notiData["bauID"]);

            var startDate = int.parse(notiData["date"]);
            var working = DateTime.fromMillisecondsSinceEpoch(startDate * 1000);
            var startW = working.toLocal();

            var startFinal =
                DateTime(startW.year, startW.month, startW.day, 0, 0, 0, 0);
            var endFinal =
                DateTime(startW.year, startW.month, startW.day + 1, 0, 0, 0, 0);

            baudataL.bauID = notiData["bauID"];
            baudataL.bauName = notiData["bauName"];
            baudataL.check = true;
            baudataL.beginDate = startFinal;
            baudataL.endDate = endFinal;

            navigatorKey.currentState.push(MaterialPageRoute(
                builder: (context) => (CheckboxWidget(
                      baudata: baudataL,
                    ))));
          },
          onLaunch: (message) async {
            print("onLaunch notification handler");
            BauData baudata = BauData();
            Map notiData = await _handleNotification(message);
            print(notiData);
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('baustellePref', notiData["bauName"]);
            prefs.setString('bauID', notiData["bauID"]);
            var startDate = notiData["date"];
            var working = DateTime.fromMillisecondsSinceEpoch(startDate);
            var startW = working.toLocal();

            var startFinal =
                DateTime(startW.year, startW.month, startW.day, 0, 0, 0, 0);
            var endFinal =
                DateTime(startW.year, startW.month, startW.day + 1, 0, 0, 0, 0);

            baudata.bauID = notiData["bauID"];
            baudata.bauName = notiData["bauName"];
            baudata.check = true;
            baudata.beginDate = startFinal;
            baudata.endDate = endFinal;

            navigatorKey.currentState.push(MaterialPageRoute(
                builder: (context) => (CheckboxWidget(
                      baudata: baudata,
                    ))));
          });
      // For testing purposes print the Firebase Messaging token
      String token = await _firebaseMessaging.getToken();
      print("FirebaseMessaging token: $token");
      _initialized = true;
      return token;
    }
  }
}

Future<Map> _handleNotification(Map<dynamic, dynamic> message) async {
  var notiData = {};
  var data = message['data'] ?? message;
  print(data["bauID"]);
  print(data["bauName"]);

  notiData["bauID"] = data["bauID"];
  notiData["bauName"] = data["bauName"];
  notiData["date"] = data["date"];
  return notiData;
}

Future<dynamic> _firebaseMessagingBackgroundHandler(
  Map<String, dynamic> message,
) async {
  // Initialize the Firebase app

  print('onBackgroundMessage received: $message');
}
