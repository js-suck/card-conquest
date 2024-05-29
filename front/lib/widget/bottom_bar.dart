import 'package:flutter/material.dart';
import 'package:front/pages/games_screen.dart';
import 'package:front/pages/home_user_screen.dart';
import 'package:front/pages/tournaments_screen.dart';
import 'package:front/pages/user_profile_screen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeUserPage(),
    const TournamentsPage(),
    const GamesPage(),
    const UserProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    final selectedPageModel =
        Provider.of<SelectedPageModel>(context, listen: false);
    selectedPageModel.changePage(_pages[_selectedIndex], _selectedIndex);
  }

  get selectedPage => _pages[_selectedIndex];

  @override
  Widget build(BuildContext context) {
    final selectedPageModel = Provider.of<SelectedPageModel>(context);
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: BottomNavigationBar(
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(MdiIcons.swordCross),
            label: 'Tournois',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.videogame_asset_rounded),
            label: 'Jeux',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Mes tournois',
          ),
        ],
        currentIndex: selectedPageModel.selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class SelectedPageModel extends ChangeNotifier {
  Widget _selectedPage = const HomeUserPage();
  int _selectedIndex = 0;

  Widget get selectedPage => _selectedPage;
  int get selectedIndex => _selectedIndex;

  void changePage(Widget page, int index) {
    _selectedPage = page;
    _selectedIndex = index;
    notifyListeners();
  }
}
