import 'package:flutter/material.dart';
import 'package:front/admin/crud_user_screen.dart';
import 'package:front/admin/crud_tournament_screen.dart';
import 'package:front/admin/crud_game_screen.dart';
import 'package:front/admin/crud_tag_screen.dart';
import 'package:front/admin/admin_dashboard_screen.dart';
import 'package:front/admin/admin_sidebar.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AdminDashboardScreen(),
    const CrudUserScreen(),
    const CrudTournamentScreen(),
    const CrudGameScreen(),
    const CrudTagScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AdminSidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: _onItemTapped,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),
        ],
      ),
    );
  }
}
