import 'package:flutter/material.dart';

class AppColors {
  // Update the primary color to your desired purple
  static const Color primary = Color.fromARGB(255, 106, 27, 154);
  
  // You may want to adjust these colors to complement your new primary color
  static const Color secondary = Color.fromARGB(255, 156, 77, 204);
  static const Color background = Color(0xFFF0F0F0);
  static const Color black = Colors.black;
  static const Color gold = Color(0xFFFFD700);
}

// 2. Update the AppTheme class in app_theme.dart

 

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,  
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary, // Use the updated primary color
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.purple, // Changed to purple
    ).copyWith(
      primary: AppColors.primary, // Explicitly set primary in colorScheme
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
    primaryColor: AppColors.primary, // Use the updated primary color
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.purple, // Changed to purple
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.primary, // Explicitly set primary in colorScheme
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
