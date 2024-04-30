import 'package:flutter/material.dart';
import 'package:front/widget/app_bar.dart';
import 'package:front/widget/bottom_bar.dart';
import 'package:provider/provider.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SelectedPageModel(),
      child: Consumer<SelectedPageModel>(
        builder: (context, notifier, child) {
          return Scaffold(
            bottomNavigationBar: const BottomBar(),
            body: notifier.selectedPage,
          );
        },
      ),
    );
  }
}
