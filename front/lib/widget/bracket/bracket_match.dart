import 'package:flutter/material.dart';
import 'package:front/extension/theme_extension.dart';
import 'package:front/main.dart';
import 'package:front/widget/bracket/bracket.dart';
import 'package:provider/provider.dart';
import 'package:front/generated/tournament.pb.dart' as tournament;

class BracketMatch extends StatelessWidget {
  const BracketMatch({super.key, required this.match});

  final tournament.Match match;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    return GestureDetector(
      onTap: () {
        if (match.status != '') {
          Navigator.pushNamed(context, '/match', arguments: match);
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
                  color: match.status == 'in progress'
                      ? Colors.redAccent
                      : context.themeColors.backgroundColor,
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
                        match.playerOne.username,
                        style: TextStyle(
                          fontWeight: match.winnerId.toString() ==
                                      match.playerOne.userId &&
                                  match.status == 'finished'
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: match.status == 'in progress'
                              ? Colors.redAccent
                              : context.themeColors.invertedBackgroundColor,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        match.playerTwo.username,
                        style: TextStyle(
                          fontWeight: match.winnerId.toString() ==
                                      match.playerTwo.userId &&
                                  match.status == 'finished'
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: match.status == 'in progress'
                              ? Colors.redAccent
                              : context.themeColors.invertedBackgroundColor,
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
                              match.playerOne.score.toString(),
                              style: TextStyle(
                                  color: match.winnerId.toString() ==
                                          match.playerOne.userId
                                      ? Colors.green
                                      : Colors.red),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              match.playerTwo.score.toString(),
                              style: TextStyle(
                                  color: match.winnerId.toString() ==
                                          match.playerTwo.userId
                                      ? Colors.green
                                      : Colors.red),
                            ),
                          ],
                        );
                      } else if (match.status == 'in progress') {
                        return Column(
                          children: [
                            Text(
                              match.playerOne.score.toString(),
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(match.playerTwo.score.toString(),
                                style:
                                    const TextStyle(color: Colors.redAccent)),
                          ],
                        );
                      } else {
                        return Text(
                          match.status != '' ? '18:00' : '',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode ? Colors.white : Colors.black,
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
