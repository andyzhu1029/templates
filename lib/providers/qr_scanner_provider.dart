import 'package:flutter/foundation.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class QrScannerProvider extends ChangeNotifier {
  QrScannerProvider()
    : controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        facing: CameraFacing.back,
        torchEnabled: false,
      );

  final MobileScannerController controller;

  bool _torchOn = false;
  bool _handled = false;

  bool get torchOn => _torchOn;

  Future<bool> ensureCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) return true;
    final req = await Permission.camera.request();
    return req.isGranted;
  }

  Future<void> toggleTorch() async {
    await controller.toggleTorch();
    _torchOn = !_torchOn;
    notifyListeners();
  }

  Future<void> switchCamera() async {
    await controller.switchCamera();
    notifyListeners();
  }

  void stop() {
    controller.stop();
  }

  String? handleDetection(BarcodeCapture capture) {
    if (_handled) return null;
    for (final b in capture.barcodes) {
      final v = b.rawValue;
      if (v != null && v.isNotEmpty) {
        _handled = true;
        return v;
      }
    }
    return null;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
