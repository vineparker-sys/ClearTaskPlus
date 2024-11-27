import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;

  bool get isDarkMode => _isDarkMode;
  bool get notificationsEnabled => _notificationsEnabled;

  // Tema Claro (Verde)
  ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF24746C), // Verde principal
        scaffoldBackgroundColor: const Color(0xFFF4F9F4), // Fundo claro
        dividerColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF4F9F4),
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF24746C)),
          titleTextStyle: TextStyle(
            color: Color(0xFF24746C),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(color: Color(0xFF24746C)),
          bodyLarge: TextStyle(color: Color(0xFF789F9C)),
          bodyMedium: TextStyle(color: Color(0xFF789F9C)),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF24746C),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF24746C),
          unselectedItemColor: Color(0xFF789F9C),
        ),
      );

  // Tema Escuro (Verde)
  ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF0BA484), // Verde mais escuro
        scaffoldBackgroundColor: const Color(0xFF2C2C3C), // Fundo escuro
        dividerColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2C2C3C),
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF05F7C0)),
          titleTextStyle: TextStyle(
            color: Color(0xFF05F7C0),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(color: Color(0xFF70D4BE)),
          bodyLarge: TextStyle(color: Color(0xFF7C808D)),
          bodyMedium: TextStyle(color: Color(0xFF7C808D)),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF0BA484),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF2C2C3C),
          selectedItemColor: Color(0xFF05F7C0),
          unselectedItemColor: Color(0xFF7C808D),
        ),
      );

  // Alterna entre modo claro e escuro
  void toggleDarkMode(bool isEnabled) {
    _isDarkMode = isEnabled;
    notifyListeners();
  }

  // Alterna notificações
  void toggleNotifications(bool isEnabled) {
    _notificationsEnabled = isEnabled;
    notifyListeners();
  }
}
