import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_scanner/models/qr_dao.dart';
import 'package:qr_scanner/providers/qr_history_provider.dart';
import 'package:qr_scanner/utilities/themed_background.dart';
import 'package:url_launcher/url_launcher.dart';

class QrDisplayScreen extends StatefulWidget {
  const QrDisplayScreen({super.key, required this.content, this.initialLabel});

  final String content;
  final String? initialLabel;

  @override
  State<QrDisplayScreen> createState() => _QrDisplayScreenState();
}

class _QrDisplayScreenState extends State<QrDisplayScreen> {
  bool _saved = false;
  bool _saving = false;
  bool _sharing = false;
  String? _label;

  @override
  void initState() {
    super.initState();
    _label = widget.initialLabel?.trim().isEmpty == true
        ? null
        : widget.initialLabel?.trim();
    _checkSaved();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _adoptLabelFromProvider(),
    );
  }

  Future<void> _adoptLabelFromProvider() async {
    final history = context.read<QrHistoryProvider?>();
    if (history == null) return;
    final match = history.items.where(
      (e) =>
          e.content == widget.content && (e.label?.trim().isNotEmpty ?? false),
    );
    if (match.isNotEmpty && mounted) {
      setState(() => _label = match.first.label!.trim());
    }
  }

  Future<void> _checkSaved() async {
    final exists = await QrDao().exists(widget.content);
    if (!mounted) return;
    setState(() => _saved = exists);
  }

  Uri? _normalizedHttpUri(String input) {
    final raw = input.trim();
    if (raw.isEmpty) return null;
    final parsed = Uri.tryParse(raw);
    if (parsed != null &&
        (parsed.isScheme('http') || parsed.isScheme('https'))) {
      return parsed;
    }
    final domain = RegExp(
      r'^(?:https?://)?(?:www\.)?([a-z0-9-]+\.)+[a-z]{2,}(?:/.*)?$',
      caseSensitive: false,
    );
    if (domain.hasMatch(raw)) {
      return Uri.parse(raw.startsWith('http') ? raw : 'https://$raw');
    }
    return null;
  }

  bool get _isOpenableLink => _normalizedHttpUri(widget.content) != null;

  Future<void> _openLink() async {
    final uri = _normalizedHttpUri(widget.content);
    if (uri == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Not a valid link')));
      }
      return;
    }
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open link')));
    }
  }

  Future<String?> _promptLabel() async {
    final controller = TextEditingController(text: _label ?? '');
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Label'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter a label'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_saving || _saved) return;
    final label = await _promptLabel();
    if (label == null || label.isEmpty) return;
    setState(() => _saving = true);
    final dao = QrDao();
    final existed = await dao.exists(widget.content);
    await dao.upsertLabel(widget.content, label);
    if (!mounted) return;
    setState(() {
      _saving = false;
      _saved = true;
      _label = label;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(existed ? 'Updated' : 'Saved')));
    final history = context.read<QrHistoryProvider?>();
    if (history != null) {
      await history.refresh();
    }
  }

  Future<void> _shareTextAndQr() async {
    if (_sharing) return;
    setState(() => _sharing = true);

    try {
      final data = widget.content.trim();
      const canvasSize = 1280.0;
      const inset = 160.0;
      final qrSide = canvasSize - inset * 2;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      canvas.drawRect(
        const Rect.fromLTWH(0, 0, canvasSize, canvasSize),
        Paint()..color = Colors.white,
      );

      final painter = QrPainter(
        data: data,
        version: QrVersions.auto,
        gapless: true,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: Colors.black,
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: Colors.black,
        ),
      );

      canvas.save();
      canvas.translate(inset, inset);
      painter.paint(canvas, Size(qrSide, qrSide));
      canvas.restore();

      final image = await recorder.endRecording().toImage(
        canvasSize.toInt(),
        canvasSize.toInt(),
      );
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) return;

      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/qr_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);

      final renderBox = context.findRenderObject() as RenderBox?;
      final origin = renderBox != null
          ? (renderBox.localToGlobal(Offset.zero) & renderBox.size)
          : null;

      final params = ShareParams(
        text: data,
        subject: 'QR code',
        files: [XFile(file.path, mimeType: 'image/png', name: 'qr.png')],
        sharePositionOrigin: origin,
      );

      await SharePlus.instance.share(params);
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  String get _fallbackTitle {
    final s = widget.content.trim();
    if (s.isEmpty) return 'QR content';
    return s.length <= 24 ? s : '${s.substring(0, 24)}…';
  }

  @override
  Widget build(BuildContext context) {
    final baseTheme = Theme.of(context);
    final themed = baseTheme.copyWith(
      textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme),
    );
    final colors = themed.colorScheme;
    final content = widget.content.trim();

    final appBarBg = colors.primary;
    final appBarFg = colors.onPrimary;
    final isDarkBar =
        ThemeData.estimateBrightnessForColor(appBarBg) == Brightness.dark;

    Widget chip({
      required String text,
      required Color bg,
      required Color fg,
      IconData? icon,
    }) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) Icon(icon, size: 14, color: fg),
            if (icon != null) const SizedBox(width: 6),
            Text(text, style: themed.textTheme.labelSmall?.copyWith(color: fg)),
          ],
        ),
      );
    }

    final qrCard = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: colors.surface.withValues(alpha: 0.55),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.70),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.10),
            blurRadius: 48,
            spreadRadius: 6,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(14),
              child: QrImageView(
                data: content,
                version: QrVersions.auto,
                gapless: true,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Colors.black,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Colors.black,
                ),
                size: 240,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              chip(
                text: _isOpenableLink ? 'URL' : 'TEXT',
                bg: colors.secondaryContainer,
                fg: colors.onSecondaryContainer,
                icon: _isOpenableLink
                    ? Icons.link
                    : Icons.text_snippet_outlined,
              ),
              const SizedBox(width: 8),
              if (_saved)
                chip(
                  text: 'Saved',
                  bg: colors.primaryContainer,
                  fg: colors.onPrimaryContainer,
                  icon: Icons.check_circle_rounded,
                ),
            ],
          ),
        ],
      ),
    );

    final bottomBar = Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: 0.60),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.70),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: (_saved || _saving) ? null : _save,
                        icon: _saving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_alt),
                        label: Text(_saved ? 'Saved' : 'Save'),
                        style: FilledButton.styleFrom(
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: _sharing ? null : _shareTextAndQr,
                        icon: _sharing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.share),
                        label: const Text('Share'),
                        style: FilledButton.styleFrom(
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: _isOpenableLink ? _openLink : null,
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Open'),
                        style: FilledButton.styleFrom(
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
            appBar: AppBar(
              backgroundColor: appBarBg,
              foregroundColor: appBarFg,
              elevation: 0,
              systemOverlayStyle: isDarkBar
                  ? SystemUiOverlayStyle.light
                  : SystemUiOverlayStyle.dark,
              title: Text(
                _label?.isNotEmpty == true ? _label! : _fallbackTitle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            body: SafeArea(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            qrCard,
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colors.surface.withValues(alpha: 0.55),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: colors.outlineVariant.withValues(
                                    alpha: 0.70,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: SelectableText(
                                      content,
                                      textAlign: TextAlign.center,
                                      style: themed.textTheme.titleMedium,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton.filledTonal(
                                    onPressed: () async {
                                      await Clipboard.setData(
                                        ClipboardData(text: content),
                                      );
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Copied to clipboard',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.copy),
                                    tooltip: 'Copy',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  bottomBar,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
