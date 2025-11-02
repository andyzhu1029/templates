import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_scanner/utilities/themed_background.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final themed = base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
    );
    final cs = themed.colorScheme;

    final avatar = Container(
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [cs.primary, cs.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: .25),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.emoji_emotions_rounded,
          color: cs.onPrimary,
          size: 56,
        ),
      ),
    );

    final card = ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cs.surface.withValues(alpha: .60),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: .7)),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Developed by',
                style: themed.textTheme.labelLarge?.copyWith(
                  color: cs.onSurface.withValues(alpha: .75),
                  letterSpacing: .3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Andy Zhu',
                style: themed.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Theme(
      data: themed,
      child: Stack(
        children: [
          const Positioned.fill(child: ThemedBackground()),
          Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [avatar, const SizedBox(height: 20), card],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
