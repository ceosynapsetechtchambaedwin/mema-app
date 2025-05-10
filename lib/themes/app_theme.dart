import 'package:flutter/material.dart';

class AppThemes {
  static const Color primaryBlue = Color.fromARGB(255, 68, 138, 255);

  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    primaryColor: primaryBlue,
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.black),
    ),
    cardColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    ),
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
        .copyWith(background: Colors.white),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    primaryColor: primaryBlue,
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white),
    ),
    cardColor: const Color(0xFF1E1E1E),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF121212),
      foregroundColor: Colors.white,
    ),
    colorScheme: ColorScheme.fromSwatch(
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
    ).copyWith(background: Colors.black),
  );
}
