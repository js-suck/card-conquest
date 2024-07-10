
import 'package:flutter/material.dart';
import 'generated/match.pb.dart';
import 'match_client.dart';

class MatchUpdateScreen extends StatefulWidget {
  final int matchId;

  const MatchUpdateScreen({super.key, required this.matchId});

  @override
  _MatchUpdateScreenState createState() => _MatchUpdateScreenState();
}

class _MatchUpdateScreenState extends State<MatchUpdateScreen> {
  late MatchClient matchClient;

  @override
  void initState() {
    super.initState();
    matchClient = MatchClient();
    matchClient.subscribeMatchUpdates(widget.matchId);
  }

  @override
  void dispose() {
    matchClient.shutdown();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Updates'),
      ),
      body: StreamBuilder<MatchResponse>(
        stream: matchClient.subscribeMatchUpdates(widget.matchId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return ListTile(
              title: Text('Match Status: ${snapshot.data!.status}'),
              subtitle: Text(snapshot.data!.detail),
            );
          } else {
            return const Center(child: Text('No updates found'));
          }
        },
      ),
    );
  }
}