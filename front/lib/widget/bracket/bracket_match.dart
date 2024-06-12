import 'package:flutter/material.dart';
import 'package:front/extension/theme_extension.dart';
import 'package:front/generated/tournament.pb.dart' as tournament;

class BracketMatch extends StatelessWidget {
  const BracketMatch({super.key, required this.match});

  final tournament.Match match;

  @override
  Widget build(BuildContext context) {
    String playerOneUsername = match.playerOne.username;
    String playerTwoUsername = match.playerTwo.username;
    String playerOneScore = match.playerOne.score.toString();
    String playerTwoScore = match.playerTwo.score.toString();
    Color playerOneColor = context.themeColors.invertedBackgroundColor;
    Color playerTwoColor = context.themeColors.invertedBackgroundColor;
    Color matchBorderColor = context.themeColors.backgroundColor;
    Color playerOneScoreColor = context.themeColors.fontColor;
    Color playerTwoScoreColor = context.themeColors.fontColor;
    FontWeight playerOneFontWeight = FontWeight.normal;
    FontWeight playerTwoFontWeight = FontWeight.normal;
    if (match.status != '') {
      if (match.status == 'started') {
        playerOneColor = Colors.redAccent;
        playerTwoColor = Colors.redAccent;
        matchBorderColor = Colors.redAccent;
      }
      if (match.status == 'finished') {
        if (match.winnerId.toString() == match.playerOne.userId) {
          playerOneFontWeight = FontWeight.bold;
          playerOneScoreColor = Colors.green;
          playerTwoScoreColor = Colors.red;
        } else {
          playerTwoFontWeight = FontWeight.bold;
          playerTwoScoreColor = Colors.green;
          playerOneScoreColor = Colors.red;
        }
      }
      if (match.playerOne.username == '') {
        playerOneUsername = 'Bye';
        playerOneColor = Colors.grey;
        playerOneScore = '';
        playerTwoScore = '';
      }
      if (match.playerTwo.username == '') {
        playerTwoUsername = 'Bye';
        playerTwoColor = Colors.grey;
        playerTwoScore = '';
        playerOneScore = '';
      }
    }
    return GestureDetector(
      onTap: () {
        if (match.status != '' &&
            match.playerOne.username != '' &&
            match.playerTwo.username != '') {
          Navigator.pushNamed(context, '/match', arguments: match.matchId);
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
      child: Column(
        children: [
          Container(
            width: 225,
            decoration: BoxDecoration(
              color: context.themeColors.secondaryBackgroundAccentColor,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              border: Border.fromBorderSide(
                BorderSide(
                  color: matchBorderColor,
                  width: 1,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        playerOneUsername,
                        style: TextStyle(
                          fontWeight: playerOneFontWeight,
                          color: playerOneColor,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        playerTwoUsername,
                        style: TextStyle(
                          fontWeight: playerTwoFontWeight,
                          color: playerTwoColor,
                        ),
                      ),
                    ],
                  ),
                  Builder(
                    builder: (context) {
                      if (match.status == 'finished') {
                        return Column(
                          children: [
                            Text(
                              playerOneScore,
                              style: TextStyle(color: playerOneScoreColor),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              playerTwoScore,
                              style: TextStyle(color: playerTwoScoreColor),
                            ),
                          ],
                        );
                      } else if (match.status == 'started') {
                        return Column(
                          children: [
                            Text(
                              playerOneScore,
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(playerTwoScore,
                                style:
                                    const TextStyle(color: Colors.redAccent)),
                          ],
                        );
                      } else {
                        return Text(
                          match.status != '' ? '18:00' : '',
                          style: TextStyle(
                            fontSize: 16,
                            color: context.themeColors.invertedBackgroundColor,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
