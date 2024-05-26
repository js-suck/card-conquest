import 'package:flutter/material.dart';
import 'package:front/auth/login_screen.dart';
import 'package:front/auth/signup_screen.dart';
import 'package:front/home_screen.dart';
import 'package:front/main_screen.dart';
import 'package:front/orga_new_tournament.dart';
import 'package:front/pages/bracket_screen.dart';
import 'package:front/pages/games_screen.dart';
import 'package:front/pages/match_screen.dart';
import 'package:front/pages/player_screen.dart';
import 'package:front/pages/profile_screen.dart';
import 'package:front/pages/scoreboard_screen.dart';
import 'package:front/settings_screen.dart';

var routes = <String, WidgetBuilder>{
  '/': (context) => const HomePage(),
  '/main': (context) => const MainPage(),
  '/login': (context) => const LoginPage(),
  '/signup': (context) => SignUpPage(),
  '/profile': (context) => const ProfilePage(),
  '/settings': (context) => const SettingsPage(),
  '/games': (context) => const GamesPage(),
  '/bracket': (context) => const BracketPage(),
  '/match': (context) => MatchPage(),
  '/player': (context) => PlayerPage(),
  '/scoreboard': (context) => const ScoreboardPage(),
  '/orga/tounament': (context) => const OrgaPage(),
};
