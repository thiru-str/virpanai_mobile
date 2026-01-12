import 'package:flutter/material.dart';

Widget withSystemBottomPadding({
  required BuildContext context,
  required Widget child,
}) {
  final bottomInset = MediaQuery.of(context).viewPadding.bottom;

  return Padding(
    padding: EdgeInsets.only(bottom: bottomInset),
    child: child,
  );
}

