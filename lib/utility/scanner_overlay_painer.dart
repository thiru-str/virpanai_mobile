import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:waioz/utility/app_colors.dart';

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scanBoxSize = size.width * 0.7;
    final left = (size.width - scanBoxSize) / 2;
    final top = (size.height - scanBoxSize) / 2;
    final scanRect = Rect.fromLTWH(left, top, scanBoxSize, scanBoxSize);

    // 1️⃣ Dimmed background (except scan area)
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.5);

    // Use Path to cut out the scan box
    final backgroundPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final holePath = Path()..addRect(scanRect);
    final dimPath = Path.combine(PathOperation.difference, backgroundPath, holePath);

    canvas.drawPath(dimPath, overlayPaint);

    // 2️⃣ Draw only corner marks (no border)
    final cornerPaint = Paint()
      ..color = AppColors.primary // Neon green like screenshot
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    const cornerLength = 24.0;

    // Top-left
    canvas.drawLine(Offset(left, top), Offset(left + cornerLength, top), cornerPaint);
    canvas.drawLine(Offset(left, top), Offset(left, top + cornerLength), cornerPaint);

    // Top-right
    canvas.drawLine(Offset(left + scanBoxSize, top),
        Offset(left + scanBoxSize - cornerLength, top), cornerPaint);
    canvas.drawLine(Offset(left + scanBoxSize, top),
        Offset(left + scanBoxSize, top + cornerLength), cornerPaint);

    // Bottom-left
    canvas.drawLine(Offset(left, top + scanBoxSize),
        Offset(left + cornerLength, top + scanBoxSize), cornerPaint);
    canvas.drawLine(Offset(left, top + scanBoxSize),
        Offset(left, top + scanBoxSize - cornerLength), cornerPaint);

    // Bottom-right
    canvas.drawLine(
        Offset(left + scanBoxSize, top + scanBoxSize),
        Offset(left + scanBoxSize - cornerLength, top + scanBoxSize),
        cornerPaint);
    canvas.drawLine(
        Offset(left + scanBoxSize, top + scanBoxSize),
        Offset(left + scanBoxSize, top + scanBoxSize - cornerLength),
        cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}