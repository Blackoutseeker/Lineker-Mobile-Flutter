import 'package:flutter/material.dart';

class LightTheme {
  ThemeData lightThemeData = ThemeData(
    backgroundColor: const Color(0xFF005884),
    cardColor: const Color(0xFF003B59),
    scaffoldBackgroundColor: const Color(0xFF005884),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF003B59),
      foregroundColor: Color(0xFFFFFFFF),
    ),
    textTheme: const TextTheme(
      headline3: TextStyle(
        color: Color(0xFF212121),
      ),
    ),
    canvasColor: const Color(0xFFFFFFFF),
    indicatorColor: const Color(0xFF9E9E9E),
  );
}
