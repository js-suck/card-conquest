import 'package:flutter/material.dart';
import 'package:front/widget/app_bar.dart';
import 'package:front/widget/bracket/scoreboard.dart';

class ScoreboardTournamentPage extends StatelessWidget {
  const ScoreboardTournamentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopAppBar(
          title: 'Classement',
          isPage: true,
          isAvatar: false,
          isSettings: false),
      body: Scoreboard(isTounament: false),
    );
  }
}
