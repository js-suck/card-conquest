import 'package:flutter/material.dart';
import 'package:front/extension/theme_extension.dart';
import 'package:front/widget/bracket/bracket.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class Summary extends StatelessWidget {
  const Summary({super.key, required this.match});

  final Match match;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 2),
        const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'S',
            ),
            SizedBox(width: 10),
            Text(
              '1',
            ),
            SizedBox(width: 10),
            Text(
              '2',
            ),
            SizedBox(width: 30),
          ],
        ),
        const SizedBox(height: 2),
        Container(
          color: context.themeColors.backgroundAccentColor,
          child: Column(
            children: [
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      match.player1!,
                      style: TextStyle(
                        fontWeight: match.winnerId == match.playerOneId
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: context.themeColors.fontColor,
                      ),
                    ),
                  ),
                  Text(match.score1.toString(),
                      style: TextStyle(
                        fontWeight: match.winnerId == match.playerOneId
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: context.themeColors.fontColor,
                      )),
                  const SizedBox(width: 10),
                  Text(match.score1.toString(),
                      style: TextStyle(
                        fontWeight: match.winnerId == match.playerOneId
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: context.themeColors.fontColor,
                      )),
                  const SizedBox(width: 10),
                  Text(
                    match.score2.toString(),
                    style: TextStyle(
                      color: context.themeColors.fontColor,
                    ),
                  ),
                  const SizedBox(width: 30),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      match.player2!,
                      style: TextStyle(
                        fontWeight: match.winnerId == match.playerOneId
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: context.themeColors.fontColor,
                      ),
                    ),
                  ),
                  Text(match.score1.toString(),
                      style: TextStyle(
                        fontWeight: match.winnerId == match.playerOneId
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: context.themeColors.fontColor,
                      )),
                  const SizedBox(width: 10),
                  Text(match.score1.toString(),
                      style: TextStyle(
                        fontWeight: match.winnerId == match.playerOneId
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: context.themeColors.fontColor,
                      )),
                  const SizedBox(width: 10),
                  Text(
                    match.score2.toString(),
                    style: TextStyle(
                      color: context.themeColors.fontColor,
                    ),
                  ),
                  const SizedBox(width: 30),
                ],
              ),
              const SizedBox(height: 2),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text(
            'Informations de match',
          ),
        ),
        Container(
          color: context.themeColors.backgroundAccentColor,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(MdiIcons.mapMarker,
                      color: context.themeColors.fontColor),
                  Expanded(
                      child: Text('Lieu :',
                          style:
                              TextStyle(color: context.themeColors.fontColor))),
                  match.location != null
                      ? Text(match.location!,
                          style:
                              TextStyle(color: context.themeColors.fontColor))
                      : Text('Non défini',
                          style:
                              TextStyle(color: context.themeColors.fontColor)),
                ],
              ),
            ),
            const Row(
              children: [],
            )
          ]),
        )
      ],
    );
  }
}
