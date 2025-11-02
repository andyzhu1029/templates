import 'package:flutter/material.dart';

@immutable
class BackgroundTheme extends ThemeExtension<BackgroundTheme> {
  final List<Color> colors;
  final Alignment begin;
  final Alignment end;

  const BackgroundTheme({
    required this.colors,
    required this.begin,
    required this.end,
  });

  static BackgroundTheme fromScheme(ColorScheme cs) {
    if (cs.brightness == Brightness.dark) {
      return BackgroundTheme(
        colors: [
          const Color(0xFF0B1020),
          const Color(0xFF151B3A),
          cs.primaryContainer.withValues(alpha: .25),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return BackgroundTheme(
      colors: [
        const Color(0xFFF8F9FF),
        cs.primaryContainer.withValues(alpha: .45),
        Colors.white,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  @override
  BackgroundTheme copyWith({
    List<Color>? colors,
    Alignment? begin,
    Alignment? end,
  }) => BackgroundTheme(
    colors: colors ?? this.colors,
    begin: begin ?? this.begin,
    end: end ?? this.end,
  );

  @override
  ThemeExtension<BackgroundTheme> lerp(
    ThemeExtension<BackgroundTheme>? other,
    double t,
  ) {
    if (other is! BackgroundTheme) return this;
    return BackgroundTheme(
      colors: List<Color>.generate(
        colors.length,
        (i) => Color.lerp(colors[i], other.colors[i % other.colors.length], t)!,
      ),
      begin: Alignment.lerp(begin, other.begin, t)!,
      end: Alignment.lerp(end, other.end, t)!,
    );
  }
}
