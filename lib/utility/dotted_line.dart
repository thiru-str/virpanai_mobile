import 'package:flutter/material.dart';

class DottedLine extends StatelessWidget {
  final double height;
  final Color color;
  final double dotWidth;
  final double spaceWidth;

  const DottedLine({
    Key? key,
    this.height = 1.0,
    this.color = Colors.black,
    this.dotWidth = 4.0,
    this.spaceWidth = 4.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxCount = (constraints.constrainWidth() / (dotWidth + spaceWidth)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(boxCount, (index) {
            return Container(
              width: dotWidth,
              height: height,
              decoration: BoxDecoration(
                color: color.withAlpha(32),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            );
          }),
        );
      },
    );
  }
}
