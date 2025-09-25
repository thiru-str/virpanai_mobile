import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

class RichTextHelper extends StatelessWidget {
  final List<RichTextSegment> segments;
  final TextAlign textAlign;
  final double? fontSize;
  final FontWeight? baseFontWeight;
  final Color? baseColor;
  final TextOverflow? overflow;

  const RichTextHelper({
    Key? key,
    required this.segments,
    this.textAlign = TextAlign.start,
    this.fontSize,
    this.baseFontWeight,
    this.baseColor,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: textAlign,
      overflow: overflow ?? TextOverflow.clip,
      text: TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: baseFontWeight,
          color: baseColor,
        ),
        children: segments.map((segment) {
          return TextSpan(
            text: segment.text,
            style: segment.textStyle,
            recognizer: segment.onTap != null
                ? (TapGestureRecognizer()..onTap = segment.onTap)
                : null,
          );
        }).toList(),
      ),
    );
  }
}

class RichTextSegment {
  final String text;
  final TextStyle? textStyle;
  final VoidCallback? onTap;

  RichTextSegment({
    required this.text,
    this.textStyle,
    this.onTap,
  });
}