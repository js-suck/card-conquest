import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TopAppBar({super.key, required this.title, this.isAvatar = true});

  final String title;
  final bool isAvatar;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(30),
        bottomRight: Radius.circular(30),
      ),
      child: AppBar(
        actions: [
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Titre',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Sous-titre',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(right: 10),
            width: 45,
            height: 45,
            decoration: const BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(20)),
              color: Colors.white,
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications),
              color: Colors.black,
              onPressed: () {},
            ),
          ),
        ],
        leading: Builder(builder: (context) {
          if (isAvatar) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed('/profile');
                },
                child: const CircleAvatar(
                  radius: 30,
                  child: Icon(Icons.person),
                ),
              ),
            );
          } else {
            // Retourne un bouton de retour par défaut
            return IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
            );
          }
        }),
      ),
    );
  }
}
