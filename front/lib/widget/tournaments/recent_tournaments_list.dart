import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/models/tournament_home.dart';
import 'package:intl/intl.dart';

class RecentTournamentsList extends StatelessWidget {
  final List<TournamentHome> recentTournaments;
  final Future<void> Function(int, String) onTournamentTapped;

  const RecentTournamentsList({
    super.key,
    required this.recentTournaments,
    required this.onTournamentTapped,
  });

  String _formatDateTime(DateTime dateTime) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: recentTournaments.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recentTournaments.length,
        itemBuilder: (context, index) {
          var item = recentTournaments[index];
          return GestureDetector(
            onTap: () => onTournamentTapped(item.id, item.status),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
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
                      bottom: 10,
                      left: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _formatDateTime(item.startDate),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
