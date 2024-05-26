import 'package:flutter/material.dart';
import 'package:front/extension/theme_extension.dart';
import 'package:front/main.dart';
import 'package:front/widget/bracket/bracket.dart';
import 'package:provider/provider.dart';

class BracketMatch extends StatelessWidget {
  const BracketMatch({super.key, required this.match});

  final Match match;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/match', arguments: match);
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
                        match.player1!,
                        style: TextStyle(
                          fontWeight: match.winnerId == match.playerOneId &&
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
                        match.player2!,
                        style: TextStyle(
                          fontWeight: match.winnerId == match.playerTwoId &&
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
                              match.score1!,
                              style: TextStyle(
                                  color: match.winnerId == match.playerOneId
                                      ? Colors.green
                                      : Colors.red),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              match.score2!,
                              style: TextStyle(
                                  color: match.winnerId == match.playerTwoId
                                      ? Colors.green
                                      : Colors.red),
                            ),
                          ],
                        );
                      } else if (match.status == 'in progress') {
                        return Column(
                          children: [
                            Text(
                              match.score1!,
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(match.score2!,
                                style:
                                    const TextStyle(color: Colors.redAccent)),
                          ],
                        );
                      } else {
                        return Text(
                          match.time!,
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
