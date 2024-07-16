import 'package:flutter/material.dart';

class CrudGuildScreen extends StatelessWidget {
  const CrudGuildScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CRUD Guild'), centerTitle: true, automaticallyImplyLeading: false),
      body: const Center(child: Text('Guild CRUD Page')),
    );
  }
}
