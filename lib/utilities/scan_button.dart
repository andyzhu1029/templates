import 'package:flutter/material.dart';

class ScanButton extends StatelessWidget {
  const ScanButton({
    super.key,
    required this.onPressed,
    this.icon = Icons.qr_code_scanner,
    this.diameter = 56,
    this.iconSize = 28,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final double diameter;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: diameter,
      width: diameter,
      child: Material(
        color: cs.primary,
        shape: const CircleBorder(),
        elevation: 6,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Center(
            child: Icon(icon, size: iconSize, color: cs.onPrimary),
          ),
        ),
      ),
    );
  }
}
