import 'package:flutter/material.dart';

class CrudTournamentScreen extends StatelessWidget {
  const CrudTournamentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CRUD Tournament'), centerTitle: true, automaticallyImplyLeading: false),
      body: const Center(child: Text('Tournament CRUD Page')),
    );
  }
}
