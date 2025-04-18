import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LanguageProvider with ChangeNotifier {
  // Langue par défaut
  bool _isFrench = true; // fr pour le français, en pour l'anglais

  bool get isFrench => _isFrench;

  // Change la langue
  void changeLanguage() {
    
      _isFrench = isFrench;
      notifyListeners();  // Notifie les widgets qui écoutent ce provider

  }

  void setLanguage(bool isFrench) {
    _isFrench = isFrench;
    notifyListeners();  // Notifie les widgets qui écoutent ce provider
  }

 
}
