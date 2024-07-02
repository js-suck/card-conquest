import 'package:flutter/material.dart';
import 'package:front/service/user_service.dart';
import 'package:front/utils/custom_future_builder.dart';

import '../models/stat/ranking.dart';
import '../widget/app_bar.dart';

class ScoreboardPage extends StatefulWidget {
  const ScoreboardPage({super.key});

  @override
  State<ScoreboardPage> createState() => _ScoreboardPageState();
}

class _ScoreboardPageState extends State<ScoreboardPage> {
  late UserService userService;

  @override
  void initState() {
    super.initState();
    userService = UserService();
    userService.fetchRanking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopAppBar(title: 'Classement'),
      body: CustomFutureBuilder<List<Ranking>>(
        future: userService.fetchRanking(),
        onLoaded: (rankings) {
          return ListView.builder(
            itemCount: rankings.length,
            itemBuilder: (context, index) {
              final ranking = rankings[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(ranking.user.media == null
                      ? '${dotenv.env['MEDIA_URL']}avatar.jpg'
                      : '${dotenv.env['MEDIA_URL']}${ranking.user.media?.fileName}'),
                ),
                title: Text(ranking.user.username),
                subtitle: Text('Score: ${ranking.score}'),
                trailing: Text('#${ranking.rank}'),
                onTap: () {
                  // Rediriger vers la page profile
                  Navigator.of(context).pushNamed('/player',
                      arguments: {'player': ranking, 'isTournament': false});
                },
              );
            },
          );
        },
      ),
    );
  }
}
