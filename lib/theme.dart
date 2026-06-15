import 'package:flutter/material.dart';

/// App color palette and theme. A river-inspired teal/blue scheme.
class AppTheme {
  static const Color primary = Color(0xFF1B6B6B);
  static const Color accent = Color(0xFF2E9E8F);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF4F7F7),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }

  /// Color for the fishing score / rating bands.
  static Color scoreColor(int score) {
    if (score <= 3) return const Color(0xFFD0463B);
    if (score <= 6) return const Color(0xFFE9A23B);
    if (score <= 8) return const Color(0xFF4C9A52);
    return const Color(0xFF2E7D32);
  }
}
