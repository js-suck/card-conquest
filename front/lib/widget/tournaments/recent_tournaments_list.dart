import 'package:flutter/material.dart';
import 'package:front/models/tournament.dart';

class RecentTournamentsList extends StatelessWidget {
  final List<Tournament> recentTournaments;
  final Future<void> Function(int) onTournamentTapped;

  const RecentTournamentsList({
    Key? key,
    required this.recentTournaments,
    required this.onTournamentTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: recentTournaments.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recentTournaments.length,
        itemBuilder: (context, index) {
          var item = recentTournaments[index];
          return GestureDetector(
            onTap: () => onTournamentTapped(item.id),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(item.imageUrl),
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
                            "${item.startDate.split('T')[0]} - ${item.startDate.split('T')[1].substring(0, 5)}",
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
