import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:front/firebase_options.dart';
import 'package:front/pages/bracket_screen.dart';
import 'package:front/pages/chat_screen.dart';
import 'package:front/pages/guild_screen.dart';
import 'package:front/routes/routes.dart';
import 'package:front/service/user_service.dart';
import 'package:front/widget/bottom_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';

import 'notifier/locale_notifier.dart';
import 'notifier/theme_notifier.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final fcmToken = await FirebaseMessaging.instance.getToken();
  await FirebaseMessaging.instance.setAutoInitEnabled(true);
  log("FCMToken $fcmToken");

  await NotificationService().init();
  await dotenv.load(fileName: "lib/.env");

  final prefs = await SharedPreferences.getInstance();
  final localeCode = prefs.getString('locale') ?? 'en';
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => UserService()),
        ChangeNotifierProvider(create: (_) => TournamentNotifier()),
        ChangeNotifierProvider(
          create: (context) => SelectedPageModel(),
        ),
        ChangeNotifierProvider(create: (_) => ThemeNotifier(isDarkMode)),
        ChangeNotifierProvider(
            create: (_) => LocaleNotifier(Locale(localeCode))),
      ],
      child: const MyApp(),
    ),
  );}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    await _initializeLocalNotifications();
    await _requestNotificationPermissions();
    await _configureFirebaseMessaging();
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
      _showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle notification tap
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    _firebaseMessaging.getToken().then((String? token) {
      assert(token != null);
      log("FCM Token: $token");
      // save locally the token
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
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final localeNotifier = Provider.of<LocaleNotifier>(context, listen: false);
    _locale = localeNotifier.locale;
  }

  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
    final localeNotifier = Provider.of<LocaleNotifier>(context, listen: false);
    localeNotifier.updateLocale(locale);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ThemeNotifier notifier, child) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: _locale,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          final Uri uri = Uri.parse(settings.name!);
          if (uri.pathSegments.length == 2 && uri.pathSegments.first == 'chat') {
            final String guildID = uri.pathSegments[1];
            return MaterialPageRoute(
              builder: (context) =>ChatClientScreen(guildId: int.parse(guildID), username: 'laila', userId: 1, mediaUrl: 'https://www.placecage.com/200/300'),
            );
          }

          if (uri.pathSegments.length == 2 && uri.pathSegments.first == 'guild') {
            final String guildID = uri.pathSegments[1];
            return MaterialPageRoute(
              builder: (context) => GuildView(),
            );
          }
          return MaterialPageRoute(builder: (context) => HomePage());
        },
        routes: routes,
        theme: notifier.getTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      );
    });
  }
}
