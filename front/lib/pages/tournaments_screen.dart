import 'package:flutter/material.dart';
import 'package:front/widget/app_bar.dart';

class TournamentsPage extends StatelessWidget {
  const TournamentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: TopAppBar(title: 'Tournois'),
    );
  }
}
