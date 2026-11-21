// Sound-wave rings on the Theatre product stage (app twin of the web ripple).
// Renders a stage at three moments and writes PNGs to THEATRE_WAVES_OUT when set;
// also checks that nothing is drawn when the phone has animations turned off.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waioz/ui/widgets/home/theatre/theatre_shared.dart';

Widget _stage(GlobalKey key, {bool still = false}) => MediaQuery(
      data:
          MediaQueryData(size: const Size(400, 400), disableAnimations: still),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: RepaintBoundary(
            key: key,
            child: const SizedBox(
              width: 260,
              height: 260,
              child: TheatrePlate(
                  url: null, waves: true, seed: 'Denon AVR-X1800H'),
            ),
          ),
        ),
      ),
    );

void main() {
  testWidgets('rings ripple across the product stage and move over time',
      (tester) async {
    final key = GlobalKey();
    await tester.pumpWidget(_stage(key));
    expect(find.byType(TheatreSoundWaves), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
    final out = Platform.environment['THEATRE_WAVES_OUT'];
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 1000));
      if (out == null) continue;
      final boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 2);
        final png = await image.toByteData(format: ui.ImageByteFormat.png);
        Directory(out).createSync(recursive: true);
        File('$out/waves-$i.png').writeAsBytesSync(png!.buffer.asUint8List());
      });
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('no rings when animations are turned off', (tester) async {
    await tester.pumpWidget(_stage(GlobalKey(), still: true));
    expect(
        find.descendant(
            of: find.byType(TheatreSoundWaves),
            matching: find.byType(CustomPaint)),
        findsNothing);
  });
}
