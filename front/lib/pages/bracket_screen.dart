import 'package:flutter/material.dart';
import 'package:front/extension/theme_extension.dart';
import 'package:front/generated/tournament.pb.dart';
import 'package:front/grpc/tournament_client.dart';
import 'package:front/widget/bracket/bracket.dart';
import 'package:front/widget/bracket/calendar.dart';
import 'package:front/widget/bracket/results.dart';
import 'package:front/widget/bracket/scoreboard.dart';

class BracketPage extends StatefulWidget {
  const BracketPage({super.key});

  final int tournamentID = 1;

  @override
  State<BracketPage> createState() => _BracketPageState();
}

class _BracketPageState extends State<BracketPage> {
  final isBracket = true;
  late TournamentClient tournamentClient;

  @override
  void initState() {
    super.initState();
    tournamentClient = TournamentClient();
    tournamentClient.subscribeTournamentUpdate(widget.tournamentID);
  }

  @override
  void dispose() {
    tournamentClient.shutdown();
    super.dispose();
  }

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
        body: StreamBuilder<TournamentResponse>(
            stream:
                tournamentClient.subscribeTournamentUpdate(widget.tournamentID),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Erreur de connexion'));
              } else if (!snapshot.hasData) {
                return const Center(child: Text('Aucune donnée'));
              }
              return Column(
                children: [
                  Expanded(
                    child: TabBarView(
                      children: [
                        isBracket ? Bracket(snapshot) : Scoreboard(),
                        Results(),
                        Calendar(),
                      ],
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }
}
