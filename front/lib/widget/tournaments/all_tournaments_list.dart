import 'package:flutter/material.dart';
import 'package:front/models/tournament.dart';

class AllTournamentsList extends StatelessWidget {
  final List<Tournament> allTournaments;
  final Future<void> Function(int) onTournamentTapped;

  const AllTournamentsList({
    Key? key,
    required this.allTournaments,
    required this.onTournamentTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: allTournaments.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: allTournaments.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.67,
        ),
        itemBuilder: (context, index) {
          var item = allTournaments[index];
          return GestureDetector(
            onTap: () => onTournamentTapped(item.id),
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
                        image: NetworkImage(item.imageUrl),
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
                              fontSize: 16, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${item.startDate.split('T')[0]} - ${item.startDate.split('T')[1].substring(0, 5)}",
                          style: const TextStyle(
                              fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 2),
                        Wrap(
                          spacing: 2,
                          children: item.tags
                              .map(
                                (tag) => Chip(
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(5),
                                side: const BorderSide(
                                    color: Colors.transparent),
                              ),
                              padding: EdgeInsets.zero,
                              label: Text(tag,
                                  style: const TextStyle(
                                      color: Colors.white)),
                              backgroundColor: Colors.orange,
                            ),
                          )
                              .toList(),
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
