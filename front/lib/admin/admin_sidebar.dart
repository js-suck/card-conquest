import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const AdminSidebar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onItemSelected,
      labelType: NavigationRailLabelType.all,
      destinations: [
        const NavigationRailDestination(
          icon: Icon(Icons.dashboard),
          selectedIcon: Icon(Icons.dashboard),
          label: Text('Dashboard'),
        ),
        const NavigationRailDestination(
          icon: Icon(Icons.person),
          selectedIcon: Icon(Icons.person),
          label: Text('Users'),
        ),
        NavigationRailDestination(
          icon: Icon(MdiIcons.swordCross),
          selectedIcon: Icon(MdiIcons.swordCross),
          label: const Text('Tournaments'),
        ),
        const NavigationRailDestination(
          icon: Icon(Icons.videogame_asset_rounded),
          selectedIcon: Icon(Icons.videogame_asset_rounded),
          label: Text('Games'),
        ),
        const NavigationRailDestination(
          icon: Icon(Icons.tag),
          selectedIcon: Icon(Icons.tag),
          label: Text('Tags'),
        ),
        const NavigationRailDestination(
          icon: Icon(Icons.flag),
          selectedIcon: Icon(Icons.flag),
          label: Text('Flags'),
        ),
      ],
    );
  }
}
