import 'package:flutter/material.dart';
import 'package:front/auth/login_screen.dart';
import 'package:front/auth/signup_screen.dart';
import 'package:front/home_screen.dart';
import 'package:front/main_screen.dart';
import 'package:front/pages/bracket_screen.dart';
import 'package:front/pages/games_screen.dart';
import 'package:front/pages/home_user_screen.dart';
import 'package:front/pages/match_screen.dart';
import 'package:front/pages/player_screen.dart';
import 'package:front/pages/profile_screen.dart';
import 'package:front/pages/scoreboard_tournament_screen.dart';
import 'package:front/pages/scoreboard_screen.dart';
import 'package:front/pages/tournament_map_screen.dart';
import 'package:front/settings_screen.dart';

import '../grpc/tournament_update_screen.dart';
import '../pages/chat_screen.dart';
import '../pages/create_guild_screen.dart';
import '../pages/guild_list_screen.dart';
import '../pages/guild_screen.dart';
import 'package:front/admin/admin_home_screen.dart';

var routes = <String, WidgetBuilder>{
  '/': (context) => const HomePage(),
  '/main': (context) => const MainPage(),
  '/login': (context) => const LoginPage(),
  '/signup': (context) => SignUpPage(),
  '/profile': (context) => const ProfilePage(),
  '/settings': (context) => const SettingsPage(),
  '/games': (context) => const GamesPage(),
  '/tournamentUpdatesDemo': (context) =>  TournamentUpdateScreen(tournamentID: 1),
  '/tournaments/map': (context) => TournamentMap(),
  '/bracket': (context) => const BracketPage(tournamentID: 1),
  '/match': (context) => MatchPage(),
  '/player': (context) => PlayerPage(),
  '/scoreboard': (context) => const ScoreboardTournamentPage(),
  '/createGuild': (context) => const CreateGuildPage(),
  '/guild': (context) => const GuildView(),
  '/guilds': (context) => const GuildListScreen(),
  '/guild/create': (context) => const CreateGuildPage(),
  '/chat/:guildId': (context) => const ChatClientScreen(guildId: 1, username: 'laila', userId: 1, mediaUrl: 'https://www.placecage.com/200/300'),
  '/home_user': (context) => const HomeUserPage(),
  '/chat': (context) => const ChatClientScreen(guildId: 1, username: 'laila', userId: 1, mediaUrl: 'https://www.placecage.com/200/300'),
  '/admin': (context) => const AdminHomeScreen(),
};
