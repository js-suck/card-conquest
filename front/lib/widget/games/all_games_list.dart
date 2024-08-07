import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/models/game.dart';

class AllGamesList extends StatelessWidget {
  final List<Game> allGames;
  final Future<void> Function(int) onGameTapped;

  const AllGamesList({
    Key? key,
    required this.allGames,
    required this.onGameTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: allGames.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: allGames.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) {
                var item = allGames[index];
                return GestureDetector(
                  onTap: () => onGameTapped(item.id),
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
                          height: 175,
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
