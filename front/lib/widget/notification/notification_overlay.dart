import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../notifier/theme_notifier.dart';

class NotificationsOverlay extends StatelessWidget {
  final List<RemoteMessage> notifications;

  NotificationsOverlay({required this.notifications});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    final accentBackgroundColor = themeNotifier.themeColors.backgroundAccentColor;
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: accentBackgroundColor,
                border: Border(
                  bottom: BorderSide(color: Colors.grey),
                ),
              ),
              child: ListTile(
                contentPadding: const  EdgeInsets.only(top: 12, left: 10),
                title: Text('Notifications',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                trailing: IconButton(
                  icon: Icon(Icons.close),
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return ListTile(
                    title: Text(notification.notification?.title ?? 'No Title', style: TextStyle(color: Colors.black)),
                    subtitle: Text(notification.notification?.body ?? 'No Body'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
