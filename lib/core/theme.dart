import 'package:flutter/material.dart';

class AppTheme {
  // Warna Utama
  static const Color darkBackground = Color(0xFF121212); 
  static const Color glassBackground = Color(0xFF1A1A1A); 
  static const Color neonGreen = Color(0xFFA4FF00); 
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGray = Color(0xFFAAAAAA);

  // Konfigurasi Tema Global
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: neonGreen,
      colorScheme: const ColorScheme.dark(
        primary: neonGreen,
        background: darkBackground,
        surface: glassBackground,
      ),
    );
  }
}