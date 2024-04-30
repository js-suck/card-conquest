import 'package:flutter/material.dart';
import 'package:front/widget/app_bar.dart';
import 'package:provider/provider.dart';

import 'main.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopAppBar(title: 'Paramètres', isAvatar: false),
      body: Center(
        child: Consumer(builder: (context, ThemeNotifier notifier, child) {
          return Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed('/'); // Retour à la page de connexion
                },
                child: const Text('Se déconnecter'),
              ),
              const SizedBox(height: 20),
              const Text(
                'Thème',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Switch(
                value: notifier.isDarkMode,
                onChanged: (value) {
                  notifier.toggleTheme();
                },
              ),
            ],
          );
        }),
      ),
    );
  }
}
