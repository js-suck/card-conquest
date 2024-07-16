import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard'), centerTitle: true, automaticallyImplyLeading: false),
      body: GridView.count(
        crossAxisCount: 3,
        padding: const EdgeInsets.all(16.0),
        children: const [
          DashboardCard(title: 'Users', count: '50'),
          DashboardCard(title: 'Tournaments', count: '20'),
          DashboardCard(title: 'Guilds', count: '10'),
          DashboardCard(title: 'Games', count: '30'),
          DashboardCard(title: 'Tags', count: '15'),
          DashboardCard(title: 'Matches', count: '100'),
        ],
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String count;

  const DashboardCard({
    Key? key,
    required this.title,
    required this.count,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: Theme.of(context).textTheme.headline6),
            const SizedBox(height: 8.0),
            Text(count, style: Theme.of(context).textTheme.headline4),
          ],
        ),
      ),
    );
  }
}
