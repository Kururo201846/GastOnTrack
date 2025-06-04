import 'package:flutter/material.dart';

class AppTheme {
  // Paleta de colores
  static const Color primaryBlue = Color(0xFF00A8E8);
  static const Color lightGray = Color(0xFFF4F6F8);
  static const Color white = Color(0xFFFFFFFF);
  static const Color cream = Color.fromARGB(255, 255, 255, 255);
  static const Color lightCream = Color.fromARGB(255, 255, 255, 255);
  static const Color textPrimary = Color(0xFF2E2E2E); 
  static const Color textSecondary = Color(0xFF7D7D7D);
  static const Color shadows = Color.fromARGB(149, 177, 177, 177);
  static const Color successGreen = Color(0xFF4BB543,); 
  static const Color errorRed = Color(0xFFFF4C4C);
  static const Color darkGreen = Color(0xFF388E3C);
  static const Color accentGreen = Color(0xFF8BC34A);

  static ThemeData get lightTheme {
    return ThemeData(
      // Esquema de colores principal
      colorScheme: ColorScheme.light(
        // Colores principales
        primary: primaryBlue,
        onPrimary: Colors.white,
        primaryContainer: primaryBlue,
        onPrimaryContainer: Colors.white,

        // Colores secundarios
        secondary: successGreen,
        onSecondary: Colors.white,
        secondaryContainer: white,
        onSecondaryContainer: textPrimary,

        // Superficies
        surface: white,
        onSurface: textPrimary,
        surfaceContainerHighest: cream,
        onSurfaceVariant: textPrimary,

        // Fondo
        // ignore: deprecated_member_use
        background: lightGray,
        // ignore: deprecated_member_use
        onBackground: textPrimary,
      ),

      // Configuración de scaffold
      scaffoldBackgroundColor: lightGray,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),

      // Botones
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          side: const BorderSide(color: primaryBlue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),

      // Campos de texto
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: Color(0x997D7D7D)),
      ),

      // Tipografía
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: textPrimary, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, color: textPrimary, height: 1.5),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      // Iconos
      iconTheme: const IconThemeData(color: primaryBlue, size: 24),

      // Tarjetas
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: lightCream,
        margin: const EdgeInsets.all(8),
      ),

      // Diálogos
      dialogTheme: DialogTheme(
        backgroundColor: lightCream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
      ),

      // Divisores
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE0E0E0),
        thickness: 1,
        space: 0,
      ),
    );
  }
}
