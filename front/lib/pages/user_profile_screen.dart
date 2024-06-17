import 'package:flutter/material.dart';
import 'package:front/pages/games_screen.dart';
import 'package:front/widget/app_bar.dart';
import 'package:provider/provider.dart';

import '../widget/bottom_bar.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedPageModel =
        Provider.of<SelectedPageModel>(context, listen: false);
    return Scaffold(
      appBar: TopAppBar(title: 'Profil'),
      body: ElevatedButton(
        onPressed: () {
          // change selected index
          selectedPageModel.changePage(const GamesPage(), 2);
        },
        child: Text('change page'),
      ),
    );
  }
}
