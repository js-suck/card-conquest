import 'package:flutter/material.dart';
import 'package:front/extension/theme_extension.dart';
import 'package:front/widget/bracket/bracket.dart';
import 'package:front/widget/bracket/calendar.dart';
import 'package:front/widget/bracket/results.dart';
import 'package:front/widget/bracket/scoreboard.dart';

class BracketPage extends StatelessWidget {
  const BracketPage({super.key});

  final isBracket = true;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Tableau',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: context.themeColors.fontColor,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            )
          ],
          bottom: TabBar(
            tabs: [
              isBracket
                  ? const Tab(text: 'Tableau')
                  : const Tab(text: 'Classement'),
              const Tab(text: 'Résultats'),
              const Tab(text: 'Calendrier'),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  isBracket ? Bracket() : Scoreboard(),
                  Results(),
                  Calendar(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
