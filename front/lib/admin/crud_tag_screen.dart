import 'package:flutter/material.dart';

class CrudTagScreen extends StatelessWidget {
  const CrudTagScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CRUD Tag'), centerTitle: true, automaticallyImplyLeading: false),
      body: const Center(child: Text('Tag CRUD Page')),
    );
  }
}
