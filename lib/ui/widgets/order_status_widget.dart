import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../utility/app_colors.dart';

class OrderStatusStep {
  final String label;
  final String svgAsset; // pass svg path
  final Color activeColor;

  OrderStatusStep({
    required this.label,
    required this.svgAsset,
    required this.activeColor,
  });
}

class OrderStatusWidget extends StatelessWidget {
  final int currentStep;
  final List<OrderStatusStep> steps;
  final bool isCanceled;

  const OrderStatusWidget({
    super.key,
    required this.currentStep,
    required this.steps,
    this.isCanceled = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const circleSize = 38.0;
    const labelWidth = 70.0;
    final circleRadius = circleSize / 2;

    // Available width for connectors
    final availableLineWidth =
        (screenWidth - (steps.length * labelWidth)) / (steps.length - 1);
    final connectorWidth = availableLineWidth.clamp(20.0, 60.0);

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;

          final bool isCancelledStep = isCanceled && index == currentStep;
          final bool isCompleted = !isCanceled && index <= currentStep;

          final Color stepColor = isCancelledStep
              ? Colors.red
              : isCompleted
              ? AppColors.primary
              : Colors.grey;

          final circleWithLabel = Column(
            children: [
              Container(
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: stepColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      spreadRadius: 1,
                    )
                  ],
                ),
                child: Center(
                  child: SvgPicture.asset(
                    step.svgAsset,
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(stepColor, BlendMode.srcIn),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: labelWidth,
                height: 30, // keeps labels equal height
                child: Text(
                  step.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isCompleted || isCancelledStep
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: stepColor,
                  ),
                ),
              ),
            ],
          );

          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              circleWithLabel,
              if (index != steps.length - 1)
                SizedBox(
                  height: circleSize,
                  child: Center(
                    child: CustomPaint(
                      painter: DashedLinePainter(color: stepColor),
                      child: SizedBox(
                        height: 2,
                        // 👇 shorten connector so it doesn’t touch circles
                        width: connectorWidth - (circleRadius ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}









/// Draw dashed line horizontally (center aligned)
class DashedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;
  final double overlap; // how much to extend each segment beyond its area

  DashedLinePainter({
    required this.color,
    this.dashWidth = 6,
    this.dashSpace = 4,
    this.overlap = 8, // tweak if you still see tiny gaps
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.square;

    final centerY = size.height / 2;
    // Start slightly before 0 and end slightly after width
    double startX = -overlap;
    final endX = size.width + overlap;

    while (startX < endX) {
      final dashEnd = (startX + dashWidth).clamp(-overlap, endX);
      canvas.drawLine(Offset(startX, centerY), Offset(dashEnd, centerY), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


