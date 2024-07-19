import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationProvider extends ChangeNotifier {
  List<RemoteMessage> _notifications = [];

  List<RemoteMessage> get notifications => _notifications;

  void addNotification(RemoteMessage notification) {
    _notifications.add(notification);
    notifyListeners();
  }

  void addNotifications(List<RemoteMessage> notifications) {
    _notifications.addAll(notifications);
    notifyListeners();
  }

  void removeNotification(RemoteMessage notification) {
    _notifications.remove(notification);
    notifyListeners();
  }

  void removeAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  void removeNotificationAtIndex(int index) {
    _notifications.removeAt(index);
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  void getNotifications() {
    notifyListeners();
  }
}