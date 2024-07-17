import 'package:flutter/material.dart';
import 'package:front/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../feature_config_service.dart';
import '../notifier/locale_notifier.dart';
import '../notifier/theme_notifier.dart';
import '../pages/bracket_screen.dart';
import '../service/user_service.dart';
import '../widget/bottom_bar.dart';
import 'feature_flag_provider.dart';



Future<List<SingleChildWidget>> getProviders() async {
  final prefs = await SharedPreferences.getInstance();
  final localeCode = prefs.getString('locale') ?? 'en';
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  final FeatureService featureService = FeatureService(dotenv.env['API_URL']!);
  final Map<String, bool> allFeatures = await featureService.getAllFeatures();



  return [
    Provider(create: (_) => UserService()),
    ChangeNotifierProvider(create: (_) => FeatureNotifier(featureService, allFeatures)),
    ChangeNotifierProvider(create: (_) => UserProvider()),
    ChangeNotifierProvider(create: (_) => TournamentNotifier()),
    ChangeNotifierProvider(create: (_) => SelectedPageModel()),
    ChangeNotifierProvider(create: (_) => ThemeNotifier(isDarkMode)),
    ChangeNotifierProvider(create: (_) => LocaleNotifier(Locale(localeCode))),
  ];
}
