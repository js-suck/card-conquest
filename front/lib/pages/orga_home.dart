import 'dart:convert';
import 'package:front/main.dart';
import 'package:front/service/tournament_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:front/widget/app_bar.dart';
import 'package:provider/src/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:front/notifier/theme_notifier.dart';
import 'package:front/models/tournament.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:front/utils/custom_future_builder.dart';

class OrganizerHomePage extends StatefulWidget {
  const OrganizerHomePage({super.key});

  @override
  _OrganizerHomePageState createState() => _OrganizerHomePageState();
}

class _OrganizerHomePageState extends State<OrganizerHomePage> {
  final storage = const FlutterSecureStorage();
  late Future<List<Tournament>> futureTournaments;
  late TournamentService tournamentService;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    tournamentService = TournamentService();
    tournamentService.fetchTournamentsOfOrganizer();
  }

  Future<void> _refreshTournaments() async {
    setState(() {
      futureTournaments = tournamentService.fetchTournamentsOfOrganizer();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    final fontColor = isDarkMode ? Colors.red : Colors.blue;

    return Scaffold(
      appBar: TopAppBar(title: t.organizerTitle),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refreshTournaments,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/orga/add/tournament');
                  },
                  child: Center(
                    // Utilisation de Center
                    child: Text(
                      t.organizerCreateTournament,
                      style: TextStyle(
                        color: fontColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  t.organizerOngoingTournaments,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                CustomFutureBuilder<List<Tournament>>(
                  future: tournamentService.fetchTournamentsOfOrganizer(),
                  onLoaded: (tournaments) {
                    if (tournaments.isEmpty) {
                      return Text(t.noOngoingTournaments);
                    }
                    var ongoingTournaments = tournaments
                        .where((t) =>
                            t.startDate
                                .toUtc()
                                .isBefore(DateTime.now().toUtc()) &&
                            t.endDate.toUtc().isAfter(DateTime.now().toUtc()))
                        .toList();
                    if (ongoingTournaments.isEmpty) {
                      return Text(t.noOngoingTournaments);
                    }
                    print(ongoingTournaments);
                    return SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: ongoingTournaments.length,
                        itemBuilder: (context, index) {
                          var tournament = ongoingTournaments[index];
                          DateTime startDate = tournament.startDate;
                          String formattedDate =
                              DateFormat('dd.MM.yyyy').format(startDate);
                          String formattedTime =
                              DateFormat('HH:mm').format(startDate);

                          return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/orga/manage/tournament',
                                arguments: tournament.id,
                              );
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: NetworkImage(
                                      '${dotenv.env['MEDIA_URL']}${tournament.imageFilename}'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                      8.0), // Ajout de padding pour éviter que le texte ne touche les bords
                                  child: Column(
                                    mainAxisSize: MainAxisSize
                                        .min, // Pour que la colonne ne prenne pas plus de place que nécessaire
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tournament.name,
                                        style: const TextStyle(
                                          fontSize: 20.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize
                                            .min, // Pour que la rangée ne prenne que la place nécessaire
                                        children: [
                                          Text(
                                            formattedDate,
                                            style: const TextStyle(
                                              fontSize: 16.0,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(
                                              width:
                                                  8.0), // Espacement entre la date et le point
                                          const Icon(
                                            Icons.circle,
                                            size: 6.0,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(
                                              width:
                                                  8.0), // Espacement entre le point et l'heure
                                          Text(
                                            formattedTime,
                                            style: const TextStyle(
                                              fontSize: 16.0,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  t.organizerTournaments,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                CustomFutureBuilder<List<Tournament>>(
                  future: tournamentService.fetchTournamentsOfOrganizer(),
                  onLoaded: (tournaments) {
                    if (tournaments.isEmpty) {
                      return Text(t.noOrganizerTournaments);
                    }
                    var draftTournaments = tournaments.toList();
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: draftTournaments.length,
                      itemBuilder: (context, index) {
                        var tournament = draftTournaments[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/orga/manage/tournament',
                              arguments: tournament.id,
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: NetworkImage(
                                    '${dotenv.env['MEDIA_URL']}${tournament.imageFilename}'),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  color: Colors.black54,
                                  child: ListTile(
                                    title: Text(
                                      tournament.name,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    subtitle: Text(
                                      '${DateFormat('dd.MM.yyyy').format(tournament.startDate)} ${DateFormat('HH:mm').format(tournament.startDate)}', // Date et heure formatées
                                      style: const TextStyle(
                                          color: Colors.white70),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
