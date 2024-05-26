import 'package:flutter/material.dart';
import 'package:front/auth/login_screen.dart';
import 'package:front/auth/signup_screen.dart';
import 'package:front/home_screen.dart';
import 'package:front/main_screen.dart';
import 'package:front/pages/bracket_screen.dart';
import 'package:front/pages/games_screen.dart';
import 'package:front/pages/match_screen.dart';
import 'package:front/pages/player_screen.dart';
import 'package:front/pages/profile_screen.dart';
import 'package:front/pages/scoreboard_screen.dart';
import 'package:front/settings_screen.dart';
import 'package:front/pages/home_user_screen.dart';

import '../grpc/tournament_update_screen.dart';

var routes = <String, WidgetBuilder>{
  '/': (context) => const HomePage(),
  '/main': (context) => const MainPage(),
  '/login': (context) => const LoginPage(),
  '/signup': (context) => SignUpPage(),
  '/profile': (context) => const ProfilePage(),
  '/settings': (context) => const SettingsPage(),
  '/games': (context) => const GamesPage(),
  '/tournamentUpdatesDemo': (context) =>
      TournamentUpdateScreen(tournamentID: 1),
  '/bracket': (context) => const BracketPage(),
  '/match': (context) => MatchPage(),
  '/player': (context) => PlayerPage(),
  '/scoreboard': (context) => const ScoreboardPage(),
  '/home_user': (context) => const HomeUserPage(),
};
