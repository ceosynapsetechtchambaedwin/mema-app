import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;  // Valeur initiale

  ThemeMode get themeMode => _themeMode;  // Getter qui renvoie la valeur de _themeMode

  bool get isDarkMode => _themeMode == ThemeMode.dark;  // Vérifier si le mode sombre est activé

  void toggleTheme(bool isOn) {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();  // Notifier tous les listeners (tout widget qui écoute ce provider)
  }
}
