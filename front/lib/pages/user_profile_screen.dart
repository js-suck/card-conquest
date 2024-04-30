import 'package:flutter/material.dart';
import 'package:front/widget/app_bar.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: TopAppBar(title: 'Profil'),
    );
  }
}
