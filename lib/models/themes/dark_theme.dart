import 'package:flutter/material.dart';

class DarkTheme {
  ThemeData darkThemeData = ThemeData(
    backgroundColor: const Color(0xFF121212),
    cardColor: const Color(0xFF1E1E1E),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Color(0xFF2C2C2C),
      titleTextStyle: TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(
        color: Color(0xFFFFFFFF),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF2C2C2C),
    ),
    textTheme: const TextTheme(
      headline3: TextStyle(
        color: Color(0xFF0066FF),
      ),
      headline5: TextStyle(
        color: Color(0xFFFFFFFF),
      ),
      bodyText2: TextStyle(
        color: Color(0xFFFFFFFF),
      ),
      subtitle1: TextStyle(
        color: Color(0xFFFFFFFF),
      ),
      caption: TextStyle(
        color: Color(0xFFFFFFFF),
      ),
    ),
    dialogTheme: const DialogTheme(
      backgroundColor: Color(0xFF1E1E1E),
      contentTextStyle: TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 16,
      ),
      titleTextStyle: TextStyle(
        color: Color(0xFFFFFFFF),
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    canvasColor: const Color(0xFF1E1E1E),
    indicatorColor: Colors.transparent,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(const Color(0xFFC00C00)),
      ),
    ),
  );
}
