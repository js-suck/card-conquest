import 'package:flutter/material.dart';
import 'package:front/extension/theme_extension.dart';
import 'package:front/generated/tournament.pb.dart' as tournament;

class MatchTile extends StatelessWidget {
  const MatchTile(
      {super.key,
      required this.match,
      required this.isPast,
      required this.isLastMatches});

  final tournament.Match match;
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
        color: match.status == 'started'
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
                            match.playerOne.username,
                            style: TextStyle(
                              fontWeight: match.winnerId.toString() ==
                                      match.playerOne.userId
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
                            match.playerTwo.username,
                            style: TextStyle(
                              fontWeight: match.winnerId.toString() ==
                                      match.playerTwo.userId
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
                                  Text(match.playerOne.score.toString(),
                                      style: TextStyle(
                                          color: match.winnerId.toString() ==
                                                  match.playerOne.userId
                                              ? Colors.green
                                              : Colors.red)),
                                  const SizedBox(height: 10),
                                  Text(match.playerTwo.score.toString(),
                                      style: TextStyle(
                                          color: match.winnerId.toString() ==
                                                  match.playerTwo.userId
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
                                  color: match.playerOne.userId ==
                                          match.winnerId.toString()
                                      ? Colors.green
                                      : Colors.red,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  match.playerOne.userId ==
                                          match.winnerId.toString()
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
                              Text(match.playerOne.score.toString(),
                                  style: TextStyle(
                                      color: match.winnerId.toString() ==
                                              match.playerOne.userId
                                          ? Colors.green
                                          : Colors.red)),
                              const SizedBox(height: 10),
                              Text(match.playerTwo.score.toString(),
                                  style: TextStyle(
                                      color: match.winnerId.toString() ==
                                              match.playerTwo.userId
                                          ? Colors.green
                                          : Colors.red)),
                            ],
                          );
                        }
                      });
                    } else {
                      return const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('18:00'),
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
