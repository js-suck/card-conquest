import 'package:flutter/foundation.dart';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:front/pages/bracket_screen.dart';
import 'package:front/pages/chat_screen.dart';
import 'package:front/pages/guild_screen.dart';
import 'package:front/routes/routes.dart';
import 'package:front/service/notification_service.dart';
import 'package:front/service/user_service.dart';
import 'package:front/widget/bottom_bar.dart';
import 'package:front/widget/bottom_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:front/widget/bottom_bar.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    await Firebase.initializeApp();

    final fcmToken = await FirebaseMessaging.instance.getToken();
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    log("FCMToken $fcmToken");

    await NotificationService().init();
  }

  await dotenv.load(fileName: "lib/env");

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
  );
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
      if (kIsWeb) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: '/login',
          routes: routes,
          theme: notifier.getTheme(),
        );
      }
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: _locale,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          final Uri uri = Uri.parse(settings.name!);
          print(uri);
          print("pathSegments ${uri.path}");
          if (uri.pathSegments.length == 2 &&
              uri.pathSegments.first == 'chat') {
            final String guildID = uri.pathSegments[1];
            return MaterialPageRoute(
              builder: (context) => ChatClientScreen(
                  guildId: int.parse(guildID),
                  username: 'laila',
                  userId: 1,
                  mediaUrl: 'https://www.placecage.com/200/300'),
            );
          }

          if (uri.pathSegments.length == 2 &&
              uri.pathSegments.first == 'guild') {
            final String guildID = uri.pathSegments[1];
            return MaterialPageRoute(
              builder: (context) => GuildView(),
            );
          }
          print("pathSegments ${routes.containsKey("/tournamentUpdatesDemo")}");

          if (routes.containsKey(uri.path)) {
            return MaterialPageRoute(builder: routes[uri.path]!);
          } else {
            return MaterialPageRoute(builder: (context) => HomePage());
          }
        },
        routes: routes,
        theme: notifier.getTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      );
    });
  }
}
