import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/extension/theme_extension.dart';
import 'package:front/models/match/match.dart';
import 'package:front/models/match/score.dart';

class MatchTile extends StatelessWidget {
  const MatchTile(
      {super.key,
      required this.match,
      required this.isPast,
      required this.isLastMatches,
      this.isSecond = false,
      this.matchId,
      this.playerId = 0});

  final Match match;
  final bool isPast;
  final bool isLastMatches;
  final bool isSecond;
  final matchId;
  final int playerId;

  @override
  Widget build(BuildContext context) {
    debugPrint(
        'player name: ${match.playerOne.username} ${match.playerOne.media?.fileName}');
    String? playerOneUsername = match.playerOne.username.split(' ')[0] ?? '';
    String? playerTwoUsername = match.playerTwo.username.split(' ')[0] ?? '';
    Color playerOneColor = context.themeColors.fontColor;
    Color playerTwoColor = context.themeColors.fontColor;
    Color playerOneScoreColor = context.themeColors.fontColor;
    Color playerTwoScoreColor = context.themeColors.fontColor;
    Color tileColor = context.themeColors.secondaryBackgroundAccentColor;
    Color matchWinningStatusColor;
    String matchWinningStatus;
    FontWeight playerOneFontWeight = FontWeight.normal;
    FontWeight playerTwoFontWeight = FontWeight.normal;
    String playerOneScore = match.scores!
        .firstWhere((s) => s.playerId == match.playerOne.id,
            orElse: () => Score(score: 0, playerId: match.playerOne.id))
        .score
        .toString();
    String playerTwoScore = match.scores!
        .firstWhere((s) => s.playerId == match.playerTwo.id,
            orElse: () => Score(score: 0, playerId: match.playerTwo.id))
        .score
        .toString();
    if (match.winner.id != null) {
      if (match.playerOne.id == match.winner.id) {
        playerOneScoreColor = Colors.green;
        playerTwoScoreColor = Colors.red;
        playerOneFontWeight = FontWeight.bold;
      } else {
        playerOneScoreColor = Colors.red;
        playerTwoScoreColor = Colors.green;
        playerTwoFontWeight = FontWeight.bold;
      }
    } else {
      playerOneScoreColor = Colors.redAccent;
      playerTwoScoreColor = Colors.redAccent;
    }
    if (match.playerOne.username == '') {
      playerOneUsername = 'Bye';
      playerOneColor = Colors.grey;
      playerOneScore = '';
      playerTwoScore = '';
    } else {
      playerOneColor = context.themeColors.fontColor;
    }
    if (match.playerTwo.username == '') {
      playerTwoUsername = 'Bye';
      playerTwoColor = Colors.grey;
      playerTwoScore = '';
      playerOneScore = '';
    } else {
      playerTwoColor = context.themeColors.fontColor;
    }
    if (matchId != null && matchId == match.id) {
      tileColor = context.themeColors.secondaryBackgroundAccentActiveColor;
    }
    matchWinningStatus = playerId == match.winner.id ? 'V' : 'D';
    matchWinningStatusColor =
        playerId == match.winner.id ? Colors.green : Colors.red;

    return GestureDetector(
      onTap: () {
        if (matchId != null && matchId == match.id) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Ce match est déjà sélectionné',
              ),
            ),
          );
          return;
        }
        if (match.playerOne.username != '' && match.playerTwo.username != '') {
          Navigator.pushNamed(context, '/match', arguments: match.id);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Il n\'y a pas de match',
              ),
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        color: tileColor,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      '${match.startTime.day.toString().padLeft(2, '0')}.${match.startTime.month.toString().padLeft(2, '0')}.'),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.transparent,
                            backgroundImage: match.playerOne.username != ''
                                ? NetworkImage(match
                                            .playerOne.media?.fileName ==
                                        ''
                                    ? '${dotenv.env['MEDIA_URL']}avatar.jpg'
                                    : '${dotenv.env['MEDIA_URL']}${match.playerOne.media?.fileName}')
                                : null,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            playerOneUsername,
                            style: TextStyle(
                                color: playerOneColor,
                                fontWeight: playerOneFontWeight),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.transparent,
                            backgroundImage: match.playerTwo.username != ''
                                ? NetworkImage(match
                                            .playerTwo.media?.fileName ==
                                        ''
                                    ? '${dotenv.env['MEDIA_URL']}avatar.jpg'
                                    : '${dotenv.env['MEDIA_URL']}${match.playerTwo.media?.fileName}')
                                : null,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            playerTwoUsername,
                            style: TextStyle(
                              color: playerTwoColor,
                              fontWeight: playerTwoFontWeight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Builder(builder: (context) {
                    if (match.status != 'created') {
                      return Builder(builder: (context) {
                        if (isLastMatches) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  Text(playerOneScore,
                                      style: TextStyle(
                                          color: playerOneScoreColor)),
                                  const SizedBox(height: 10),
                                  Text(playerTwoScore,
                                      style: TextStyle(
                                          color: playerTwoScoreColor)),
                                ],
                              ),
                              Container(
                                width: 25,
                                height: 25,
                                padding: const EdgeInsets.all(2),
                                margin: const EdgeInsets.only(left: 10),
                                decoration: BoxDecoration(
                                  color: matchWinningStatusColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  matchWinningStatus,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              Text(playerOneScore,
                                  style: TextStyle(color: playerOneScoreColor)),
                              const SizedBox(height: 10),
                              Text(playerTwoScore,
                                  style: TextStyle(color: playerTwoScoreColor)),
                            ],
                          );
                        }
                      });
                    } else {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                              '${match.startTime.hour.toString().padLeft(2, '0')}:${match.startTime.minute.toString().padLeft(2, '0')}'),
                        ],
                      );
                    }
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
