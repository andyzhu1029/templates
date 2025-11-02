import 'package:flutter/material.dart';

@immutable
class ScanButtonTheme extends ThemeExtension<ScanButtonTheme> {
  final List<Color> gradient;
  final Color labelColor;

  const ScanButtonTheme({required this.gradient, required this.labelColor});

  factory ScanButtonTheme.fromScheme(ColorScheme cs) {
    final light = cs.brightness == Brightness.light;
    return ScanButtonTheme(
      gradient: light
          ? [const Color(0xFF7C3AED), const Color(0xFF60A5FA)]
          : [cs.primary, cs.tertiary],
      labelColor: Colors.white,
    );
  }

  @override
  ScanButtonTheme copyWith({List<Color>? gradient, Color? labelColor}) =>
      ScanButtonTheme(
        gradient: gradient ?? this.gradient,
        labelColor: labelColor ?? this.labelColor,
      );

  @override
  ThemeExtension<ScanButtonTheme> lerp(
    ThemeExtension<ScanButtonTheme>? other,
    double t,
  ) {
    if (other is! ScanButtonTheme) return this;
    return ScanButtonTheme(
      gradient: List<Color>.generate(
        other.gradient.length,
        (i) => Color.lerp(gradient[i % gradient.length], other.gradient[i], t)!,
      ),
      labelColor: Color.lerp(labelColor, other.labelColor, t)!,
    );
  }
}
