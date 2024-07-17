import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:front/extension/theme_extension.dart';
import 'package:front/pages/bracket_screen.dart';
import 'package:front/pages/tournaments_registration_screen.dart';
import 'package:front/service/tournament_service.dart';
import 'package:front/utils/custom_future_builder.dart';
import 'package:front/widget/app_bar.dart';
import 'package:front/widget/tournaments/all_tournaments_list.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../models/match/tournament.dart';

class TournamentHistoryPage extends StatefulWidget {
  const TournamentHistoryPage({super.key});

  @override
  _TournamentHistoryPageState createState() => _TournamentHistoryPageState();
}

class _TournamentHistoryPageState extends State<TournamentHistoryPage>
    with SingleTickerProviderStateMixin {
  final storage = const FlutterSecureStorage();
  late Future<int> userIdFuture;
  late TournamentService tournamentService;

  @override
  void initState() {
    super.initState();
    tournamentService = TournamentService();
    userIdFuture = _fetchUserId();
  }

  Future<int> _fetchUserId() async {
    String? token = await storage.read(key: 'jwt_token');
    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken['user_id'];
    } else {
      throw Exception('Failed to load user id');
    }
    return 0;
  }

  Future<void> _onTournamentTapped(int tournamentId, String status) async {
    Widget page;
    switch (status) {
      case 'opened':
        page = RegistrationPage(tournamentId: tournamentId);
        break;
      case 'started':
      case 'finished':
      case 'canceled':
        page = BracketPage(tournamentID: tournamentId);
        break;
      default:
        page = RegistrationPage(tournamentId: tournamentId);
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: FutureBuilder<int>(
        future: userIdFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshot.hasData || snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(
                title: TopAppBar(title: t.tournamentHistoryTitle),
              ),
              body: Center(
                child: Text(
                  t.errorLoadingUser,
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          int userId = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: TopAppBar(title: t.tournamentHistoryTitle),
              automaticallyImplyLeading: false,
              bottom: TabBar(
                isScrollable: true,
                labelColor: context.themeColors.accentColor,
                indicatorColor: context.themeColors.accentColor,
                unselectedLabelColor: Colors.white,
                tabs: [
                  Tab(text: t.tournamentHistoryUpcoming),
                  Tab(text: t.tournamentHistoryPast),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                SingleChildScrollView(
                  child: CustomFutureBuilder<List<Tournament>>(
                    future: tournamentService.fetchUpcomingTournamentsOfUser(userId),
                    onLoaded: (upcomingTournaments) {
                      if (upcomingTournaments.isEmpty) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(
                              child: Text(
                                t.noUpcomingTournaments,
                                style: TextStyle(fontSize: 20),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        );
                      }
                      return AllTournamentsList(
                        allTournaments: upcomingTournaments,
                        onTournamentTapped: _onTournamentTapped,
                        emptyMessage: t.noUpcomingTournaments,
                      );
                    },
                    onError: (error) => Center(
                      child: Text(
                        error,
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    onLoading: () => Center(child: CircularProgressIndicator()),
                  ),
                ),
                SingleChildScrollView(
                  child: CustomFutureBuilder<List<Tournament>>(
                    future: tournamentService.fetchPastTournamentsOfUser(userId),
                    onLoaded: (pastTournaments) {
                      if (pastTournaments.isEmpty) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(
                              child: Text(
                                t.noPastTournaments,
                                style: TextStyle(fontSize: 20),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        );
                      }
                      return AllTournamentsList(
                        allTournaments: pastTournaments,
                        onTournamentTapped: _onTournamentTapped,
                        emptyMessage: t.noPastTournaments,
                      );
                    },
                    onError: (error) => Center(
                      child: Text(
                        error,
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    onLoading: () => Center(child: CircularProgressIndicator()),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
