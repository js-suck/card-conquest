import 'package:flutter/material.dart';
import 'package:front/widget/app_bar.dart';
import 'package:front/widget/game_card.dart';

class GamesPage extends StatelessWidget {
  const GamesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopAppBar(title: 'Jeux'),
      // list of cards with games
      body: Container(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Les jeux du moment',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(
                height: 180,
                child: GridView.count(
                  scrollDirection: Axis.horizontal,
                  crossAxisCount: 1,
                  children: List.generate(
                    10,
                    (index) {
                      return GameCard(
                        imageName: 'images/img.png',
                        gameName: 'Jeu $index',
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Tous les jeux',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(
                height: 540,
                child: GridView.count(
                  scrollDirection: Axis.vertical,
                  crossAxisCount: 2,
                  children: List.generate(
                    20,
                    (index) {
                      return GameCard(
                        imageName: 'images/img.png',
                        gameName: 'Jeu $index',
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
