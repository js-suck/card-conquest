import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:front/extension/theme_extension.dart';
import 'package:front/models/match/tournament.dart';
import 'package:intl/intl.dart';

class AllTournamentsList extends StatelessWidget {
  final List<Tournament> allTournaments;
  final Future<void> Function(int, String) onTournamentTapped;
  final String emptyMessage;

  const AllTournamentsList({
    Key? key,
    required this.allTournaments,
    required this.onTournamentTapped,
    required this.emptyMessage,
  }) : super(key: key);

  String _formatDateTime(DateTime dateTime) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(dateTime);
  }

  double getChildAspectRatio(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 1200) {
      return 0.62;
    } else if (screenWidth > 600) {
      return 0.56;
    } else {
      return 0.55;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final status = {
      'opened': t.tournamentStatusOpened,
      'started': t.tournamentStatusStarted,
      'finished': t.tournamentStatusFinished,
    };
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: allTournaments.isEmpty
          ? Center(
        child: Text(
          emptyMessage,
          style: TextStyle(
              fontSize: 18, color: context.themeColors.fontColor),
        ),
      )
          : GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: allTournaments.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: getChildAspectRatio(context),
        ),
        itemBuilder: (context, index) {
          var item = allTournaments[index];
          return GestureDetector(
            onTap: () => onTournamentTapped(item.id, item.status),
            child: Container(
              width: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12)),
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(item
                            .media?.fileName !=
                            null
                            ? '${dotenv.env['MEDIA_URL']}${item.media?.fileName}'
                            : '${dotenv.env['MEDIA_URL']}yugiho.webp'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 2, horizontal: 4),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              status[item.status] ?? '',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDateTime(item.startDate),
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black),
                        ),
                        const SizedBox(height: 2),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 4),
                              decoration: BoxDecoration(
                                color: context.themeColors.accentColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'J: ${item.playersRegistered}/${item.maxPlayers}',
                                style:
                                const TextStyle(color: Colors.white),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 4),
                              decoration: BoxDecoration(
                                color: Colors.teal[400],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Jeu: ${item.game.name}',
                                style:
                                const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
