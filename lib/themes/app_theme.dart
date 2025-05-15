import 'package:flutter/material.dart';

class AppTheme {
  // Paleta de colores
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color lightGreen = Color(0xFF81C784);
  static const Color darkGreen = Color(0xFF388E3C);
  static const Color cream = Color.fromARGB(255, 255, 255, 255);
  static const Color lightCream = Color.fromARGB(255, 255, 255, 255);
  static const Color darkCream = Color(0xFFE6D8B5);
  static const Color accentGreen = Color(0xFF8BC34A);
  static const Color black = Color.fromARGB(255, 0, 0, 0);

  static ThemeData get lightTheme {
    return ThemeData(
      // Esquema de colores principal
      colorScheme: ColorScheme.light(
        // Colores principales
        primary: primaryGreen,
        onPrimary: Colors.white,
        primaryContainer: darkGreen,
        onPrimaryContainer: Colors.white,
        
        // Colores secundarios
        secondary: accentGreen,
        onSecondary: Colors.black,
        secondaryContainer: lightGreen,
        onSecondaryContainer: Colors.black,
        
        // Superficies
        surface: lightCream,
        onSurface: Colors.black,
        surfaceContainerHighest: cream,
        onSurfaceVariant: Colors.black87,
        
        // Fondo
        background: lightCream,
        onBackground: Colors.black,
      ),

      // Configuración de scaffold
      scaffoldBackgroundColor: cream,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),

      // Botones
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: const BorderSide(color: primaryGreen),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(color: Colors.black54),
        hintStyle: const TextStyle(color: Colors.black38),
      ),

      // Tipografía
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32, 
          fontWeight: FontWeight.bold, 
          color: Colors.black,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 24, 
          fontWeight: FontWeight.bold, 
          color: Colors.black,
        ),
        bodyLarge: TextStyle(
          fontSize: 16, 
          color: Colors.black87,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14, 
          color: Colors.black87,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontSize: 14, 
          fontWeight: FontWeight.bold, 
          color: Colors.white,
        ),
      ),

      // Iconos
      iconTheme: const IconThemeData(
        color: primaryGreen,
        size: 24,
      ),

      // Tarjetas
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: lightCream,
        margin: const EdgeInsets.all(8),
      ),
      
      // Diálogos
      dialogTheme: DialogTheme(
        backgroundColor: lightCream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
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