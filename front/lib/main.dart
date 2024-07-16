import 'package:flutter/material.dart';
import 'package:front/pages/orga_manage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:front/pages/bracket_screen.dart';
import 'package:front/routes/routes.dart';
import 'package:front/service/user_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notifier/locale_notifier.dart';
import 'notifier/theme_notifier.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "lib/.env");

  final prefs = await SharedPreferences.getInstance();
  final localeCode = prefs.getString('locale') ?? 'en';
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => UserService()),
        ChangeNotifierProvider(create: (_) => TournamentNotifier()),
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
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: _locale,
        initialRoute: '/',
        //initialRoute: '/orga/home',
        // initialRoute: '/orga/tounament',
        routes: routes,
        onGenerateRoute: (settings) {
          if (settings.name == '/orga/manage/tournament' ||
              settings.name == '/bracket') {
            final int tournamentId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (context) =>
                  OrganizerManagePage(tournamentId: tournamentId),
            );
          }
          return null; // Return null if the route name is not handled
        },
        theme: notifier.getTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      );
    });
  }
}
