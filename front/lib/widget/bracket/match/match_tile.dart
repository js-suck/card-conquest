import 'package:flutter/material.dart';
import 'package:front/extension/theme_extension.dart';
import 'package:front/widget/bracket/bracket.dart';

class MatchTile extends StatelessWidget {
  const MatchTile(
      {super.key,
      required this.match,
      required this.isPast,
      required this.isLastMatches});

  final Matcha match;
  final bool isPast;
  final bool isLastMatches;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/match', arguments: match);
      },
      child: Container(
        width: double.infinity,
        color: match.status == 'in progress'
            ? Colors.redAccent
            : context.themeColors.secondaryBackgroundAccentColor,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('04.05.'),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 10,
                            backgroundImage:
                                AssetImage('assets/images/avatar.png'),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            match.player1!,
                            style: TextStyle(
                              fontWeight: match.winnerId == match.playerOneId
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 10,
                            backgroundImage:
                                AssetImage('assets/images/avatar.png'),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            match.player2!,
                            style: TextStyle(
                              fontWeight: match.winnerId == match.playerTwoId
                                  ? FontWeight.bold
                                  : FontWeight.normal,
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
                    if (isPast) {
                      return Builder(builder: (context) {
                        if (isLastMatches) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  Text(match.score1!,
                                      style: TextStyle(
                                          color: match.winnerId ==
                                                  match.playerOneId
                                              ? Colors.green
                                              : Colors.red)),
                                  const SizedBox(height: 10),
                                  Text(match.score2!,
                                      style: TextStyle(
                                          color: match.winnerId ==
                                                  match.playerTwoId
                                              ? Colors.green
                                              : Colors.red)),
                                ],
                              ),
                              Container(
                                width: 25,
                                height: 25,
                                padding: const EdgeInsets.all(2),
                                margin: const EdgeInsets.only(left: 10),
                                decoration: BoxDecoration(
                                  color: match.playerOneId == match.winnerId
                                      ? Colors.green
                                      : Colors.red,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  match.playerOneId == match.winnerId
                                      ? 'V'
                                      : 'D',
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
                              Text(match.score1!,
                                  style: TextStyle(
                                      color: match.winnerId == match.playerOneId
                                          ? Colors.green
                                          : Colors.red)),
                              const SizedBox(height: 10),
                              Text(match.score2!,
                                  style: TextStyle(
                                      color: match.winnerId == match.playerTwoId
                                          ? Colors.green
                                          : Colors.red)),
                            ],
                          );
                        }
                      });
                    } else {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('match.time!'),
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
