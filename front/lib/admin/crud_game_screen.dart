import 'package:flutter/material.dart';

class CrudGameScreen extends StatelessWidget {
  const CrudGameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CRUD Game'), centerTitle: true, automaticallyImplyLeading: false),
      body: const Center(child: Text('Game CRUD Page')),
    );
  }
}
