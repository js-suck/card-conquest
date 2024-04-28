import 'package:flutter/material.dart';
import 'package:front/widget/app_bar.dart';
import 'package:front/widget/bottom_bar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomBar(),
      appBar: const TopAppBar(title: 'Connexion', isAvatar: false),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(
                  'assets/avatar.png'), // Assurez-vous d'avoir un fichier image nommé 'avatar.png' dans le dossier 'assets'
            ),
            const SizedBox(height: 20),
            const Text(
              'Nom Utilisateur',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'email@example.com',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/settings');
              },
              child: const Text('Paramètres'),
            ),
          ],
        ),
      ),
    );
  }
}
