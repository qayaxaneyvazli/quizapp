import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,  
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.indigo,
    ).copyWith(
      secondary: AppColors.secondary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Color.fromARGB(255, 223, 217, 217)),
      titleTextStyle: TextStyle(
        color: AppColors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 18),
      bodyMedium: TextStyle(fontSize: 16),
    ),
    useMaterial3: true,
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    primaryColor: AppColors.primary,
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.indigo,
      brightness: Brightness.dark,
    ).copyWith(
      secondary: AppColors.secondary,
      background: Colors.black,
      surface: Colors.grey[900],
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: Colors.white70,
      onSurface: Colors.white70,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white70),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 18, color: Colors.white),
      bodyMedium: TextStyle(fontSize: 16, color: Colors.white70),
    ),
    cardColor: Colors.grey[850],
    canvasColor: Colors.grey[900],
    useMaterial3: true,
  );
}
