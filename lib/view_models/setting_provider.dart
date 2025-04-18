import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  String _language = "fr";
  bool _notificationsEnabled = true;

  String get language => _language;
  bool get notificationsEnabled => _notificationsEnabled;


  void setNotifications(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }
}
