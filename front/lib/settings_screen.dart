import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:front/utils/shared_pref_cached_data.dart';
import 'package:front/widget/app_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'main.dart';
import 'notifier/theme_notifier.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;
    final Locale locale = Localizations.localeOf(context);
    var languages = <String, String>{
      'fr': 'Français',
      'en': 'English',
    };
    return Scaffold(
      appBar: TopAppBar(
          title: t.settingsTitle,
          isAvatar: false,
          isPage: true,
          isSettings: true),
      body: Center(
        child: Consumer(builder: (context, ThemeNotifier notifier, child) {
          return Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  var mySharedPreferences = MySharedPreferences();
                  mySharedPreferences.clearData();
                  const storage = FlutterSecureStorage();
                  storage.deleteAll();
                  Navigator.of(context)
                      .pushNamed('/'); // Retour à la page de connexion
                },
                child: Text(t.settingsLogout),
              ),
              const SizedBox(height: 20),
              Text(
                t.settingsTheme,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Switch(
                value: notifier.isDarkMode,
                onChanged: (value) {
                  notifier.toggleTheme();
                },
              ),
              const SizedBox(height: 20),
              Text(t.settingsLanguage,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: locale.languageCode,
                onChanged: (String? language) async {
                  if (language != null) {
                    final newLocale = Locale(language);
                    MyApp.setLocale(context, newLocale);

                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('locale', language);
                  }
                },
                items: languages.keys
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(languages[value]!),
                  );
                }).toList(),
              ),
            ],
          );
        }),
      ),
    );
  }
}
