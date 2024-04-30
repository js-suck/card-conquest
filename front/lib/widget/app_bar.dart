import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TopAppBar({
    super.key,
    required this.title,
    this.isAvatar = true,
    this.isPage = true,
    this.isSettings = false,
  });

  final String title;
  final bool isAvatar;
  final bool isPage;
  final bool isSettings;

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
        title: Builder(builder: (context) {
          if (isPage) {
            return Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          } else {
            return const Text('');
          }
        }),
        centerTitle: true,
        actions: [
          Builder(builder: (context) {
            if (!isPage) {
              return Container(
                margin: const EdgeInsets.only(right: 10),
                width: 45,
                height: 45,
                decoration: const BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Colors.white,
                ),
                child: Badge.count(
                  count: 0,
                  child: IconButton(
                    icon: const Icon(Icons.notifications),
                    color: Colors.black,
                    onPressed: () {},
                  ),
                ),
              );
            } else if (!isSettings) {
              return IconButton(
                icon: const Icon(Icons.settings),
                color: Colors.white,
                onPressed: () {
                  Navigator.of(context).pushNamed('/settings');
                },
              );
            } else {
              return const Text('');
            }
          })
        ],
        leadingWidth: isPage ? 64 : 1000,
        leading: Builder(builder: (context) {
          if (isAvatar) {
            return Expanded(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, top: 4, bottom: 4),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed('/profile');
                      },
                      child: const CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage('assets/images/avatar.png'),
                      ),
                    ),
                  ),
                  Builder(builder: (context) {
                    if (!isPage) {
                      return const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('John Doe',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              )),
                          Text('Admin',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                              )),
                        ],
                      );
                    } else {
                      return const Text('');
                    }
                  }),
                ],
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
