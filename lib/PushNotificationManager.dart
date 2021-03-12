import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
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

      _firebaseMessaging.requestNotificationPermissions();

      _firebaseMessaging.configure(
          onBackgroundMessage: _firebaseMessagingBackgroundHandler,
          onMessage: (message) async {},
          onResume: (message) async {},
          onLaunch: (message) async {});
      // For testing purposes print the Firebase Messaging token
      String token = await _firebaseMessaging.getToken();
      print("FirebaseMessaging token: $token");
      _initialized = true;
      return token;
    }
  }
}

Future<dynamic> _firebaseMessagingBackgroundHandler(
  Map<String, dynamic> message,
) async {
  // Initialize the Firebase app

  print('onBackgroundMessage received: $message');
}
