import 'package:flutter/material.dart';
import 'package:qr_scanner/theme/background_theme.dart';
import 'package:qr_scanner/theme/scan_button_theme.dart';

class AppTheme {
  static ThemeData light = _build(
    ColorScheme.fromSeed(
      seedColor: const Color(0xFF6750A4),
      brightness: Brightness.light,
    ),
  );

  static ThemeData dark = _build(
    ColorScheme.fromSeed(
      seedColor: const Color(0xFF6750A4),
      brightness: Brightness.dark,
    ),
  );

  static ThemeData _build(ColorScheme scheme) {
    final base = ThemeData(colorScheme: scheme, useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: Colors.transparent,
      extensions: <ThemeExtension<dynamic>>[
        ScanButtonTheme.fromScheme(scheme),
        BackgroundTheme.fromScheme(scheme),
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }
}
