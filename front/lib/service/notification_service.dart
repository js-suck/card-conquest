import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  List<RemoteMessage> _notifications = [];

  Future<void> init() async {
    await _initializeLocalNotifications();
    await _requestNotificationPermissions();
    await _configureFirebaseMessaging();
    await _loadNotifications();
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {});

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _requestNotificationPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      log('User granted provisional permission');
    } else {
      log('User declined or has not accepted permission');
    }
  }

  Future<void> _configureFirebaseMessaging() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _notifications.add(message);
      _saveNotifications();
      _showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle notification tap
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    _firebaseMessaging.getToken().then((String? token) {
      assert(token != null);
      log("FCM Token: $token");
      const storage = FlutterSecureStorage();
      storage.write(key: 'fcm_token', value: token);
    });
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    log('Handling a background message: ${message.messageId}');
  }

  void _showNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'your_channel_id',
        'your_channel_name',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        platformChannelSpecifics,
        payload: message.data['payload'],
      );
    }
  }

  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> notificationStrings = _notifications.map((notification) => jsonEncode(notification.toMap())).toList();
    print("notificationStrings $notificationStrings");
    await prefs.setStringList('notifications', notificationStrings);
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? notificationStrings = prefs.getStringList('notifications');
    print("notificationStrings received $notificationStrings");
    if (notificationStrings != null) {
      _notifications = notificationStrings.map((string) => RemoteMessage.fromMap(jsonDecode(string))).toList();
    }
  }
  Future<List<RemoteMessage>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? notificationStrings = prefs.getStringList('notifications');
    print("notificationStrings received $notificationStrings");
    if (notificationStrings != null) {
      _notifications = notificationStrings.map((string) => RemoteMessage.fromMap(jsonDecode(string))).toList();
    }
    return _notifications;
  }

  Future<void> resetCount() async {
    _notifications = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('notifications', []);
  }

  int getCount() {
    return _notifications.length;
  }


}