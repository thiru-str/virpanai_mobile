import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:waioz/ui/widgets/common_header_app_bar.dart';

import '../utility/app_assets.dart';
import '../utility/scanner_overlay_painer.dart';

class ScannerView extends StatefulWidget {
  final Function(String code)? onScanned;

  const ScannerView({super.key, this.onScanned});

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool _hasScanned = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: CommonHeaderAppBar(
        title: 'Scanner',
        onBackTap: () {
          Navigator.pop(context,true);
        },
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                MobileScanner(
                  controller: _scannerController,
                  onDetect: (barcode) async {
                    if (_hasScanned) return;

                    final code = barcode.barcodes.firstOrNull?.rawValue;
                    if (code == null) return;

                    debugPrint('scanned code'+code);
                    _hasScanned = true;
                    await _scannerController.stop();

                    Navigator.pop(context,code); // remove scanner from view stack

                  },

                ),
                Positioned.fill(
                  child: CustomPaint(
                    painter: ScannerOverlayPainter(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}













