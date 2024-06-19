import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import './../generated/tournament.pb.dart';
import 'tournament_client.dart';

class TournamentUpdateScreen extends StatefulWidget {
  final int tournamentID;

  TournamentUpdateScreen({required this.tournamentID});

  @override
  _TournamentUpdateScreenState createState() => _TournamentUpdateScreenState();
}

class _TournamentUpdateScreenState extends State<TournamentUpdateScreen> {
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
    return Scaffold(
      appBar: AppBar(
        title: Text('tournament Updates'),
      ),
        body: StreamBuilder<TournamentResponse>(
          stream: tournamentClient.subscribeTournamentUpdate(widget.tournamentID),
          builder: (context, snapshot) {
            //log
            print('snapshot: $snapshot');
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              if (snapshot.data?.tournamentSteps == null || snapshot.data!.tournamentSteps.isEmpty) {
                // Handle initial empty data or 'ping'
                return Center(child: Text('Waiting for updates...'));
              }
              return ListTile(
                subtitle:  Text('Data: ${snapshot.data.toString()}')
                   ,
              );
            } else {
              return Center(child: Text('No updates found'));
            }
          },

    ),
    );
  }
}