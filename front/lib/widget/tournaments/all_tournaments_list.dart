import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
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
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.75,
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
                    height: 180,
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
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${_formatDateTime(item.startDate)}",
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black),
                        ),
                        const SizedBox(height: 2),
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
