import 'package:flutter/material.dart';
import 'package:qr_scanner/theme/background_theme.dart';

class ThemedBackground extends StatelessWidget {
  const ThemedBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext =
        theme.extension<BackgroundTheme>() ??
        BackgroundTheme.fromScheme(theme.colorScheme);
    return CustomPaint(
      painter: _AuroraPainter(ext, theme.colorScheme),
      child: const SizedBox.expand(),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  final BackgroundTheme bg;
  final ColorScheme cs;
  const _AuroraPainter(this.bg, this.cs);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final basePaint = Paint()
      ..shader = LinearGradient(
        colors: bg.colors,
        begin: bg.begin,
        end: bg.end,
      ).createShader(rect);
    canvas.drawRect(rect, basePaint);

    final a = cs.primary;
    final b = cs.tertiary;
    final c = cs.secondary;

    void blob(Color color, Offset center, double radius, double alpha) {
      final shader = RadialGradient(
        colors: [
          color.withValues(alpha: alpha),
          color.withValues(alpha: 0),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawRect(
        rect,
        Paint()
          ..shader = shader
          ..blendMode = BlendMode.plus,
      );
    }

    final s = size.shortestSide;
    blob(a, Offset(size.width * .25, size.height * .22), s * .80, .38);
    blob(b, Offset(size.width * .85, size.height * .28), s * .65, .34);
    blob(c, Offset(size.width * .55, size.height * .85), s * .85, .28);

    final sweep = SweepGradient(
      colors: [
        Colors.transparent,
        a.withValues(alpha: 0.18),
        Colors.transparent,
        b.withValues(alpha: 0.14),
        Colors.transparent,
      ],
      stops: const [0.00, 0.18, 0.36, 0.58, 0.80],
      center: const Alignment(-.6, -.6),
      startAngle: 0,
      endAngle: 6.28318,
      transform: const GradientRotation(.35),
    ).createShader(rect);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = sweep
        ..blendMode = BlendMode.plus,
    );

    final gloss = LinearGradient(
      colors: [Colors.white.withValues(alpha: .10), Colors.transparent],
      begin: Alignment.topCenter,
      end: Alignment.center,
    ).createShader(rect);
    canvas.drawRect(rect, Paint()..shader = gloss);

    final vignette = RadialGradient(
      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.20)],
      stops: const [.65, 1.0],
      center: Alignment.bottomRight,
      radius: 1.25,
    ).createShader(rect);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = vignette
        ..blendMode = BlendMode.darken,
    );
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter old) =>
      old.bg != bg || old.cs.brightness != cs.brightness;
}
