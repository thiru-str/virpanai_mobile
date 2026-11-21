// THEATRE app chrome: the dark header (header-20, AppHeaderTheatre1) and the
// product-list card (productView13, ProductCard13). Checks neither overflows
// at normal and large text sizes, and writes PNGs to THEATRE_CHROME_OUT when
// set (for review and for the central preview images, which are greyed after).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waioz/model/product_response.dart' as plp;
import 'package:waioz/ui/widgets/home/app_header_theatre1.dart';
import 'package:waioz/ui/widgets/product_card_13.dart';
import 'package:waioz/utility/currency_util.dart';
import 'package:waioz/utility/image_fallback_widget.dart';

Future<ByteData> _bytes(String path) async =>
    ByteData.view((await File(path).readAsBytes()).buffer);

Future<void> _font(String family, String path) async {
  final l = FontLoader(family)..addFont(_bytes(path));
  await l.load();
}

Future<void> _icons() async {
  final root = Platform.environment['FLUTTER_ROOT'];
  for (final c in [
    if (root != null)
      '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    '${File(Platform.resolvedExecutable).parent.parent.parent.path}/artifacts/material_fonts/MaterialIcons-Regular.otf',
  ]) {
    if (File(c).existsSync()) return _font('MaterialIcons', c);
  }
}

plp.Product _p(String title, num price, {num? mrp, int variants = 1}) =>
    plp.Product(
      id: title,
      title: title,
      thumbnail: '',
      variants: [
        for (var i = 0; i < variants; i++)
          plp.Variant(
              id: '$title-$i',
              calculatedPrice: plp.CalculatedPrice(
                  calculatedAmount: price, originalAmount: mrp ?? price)),
      ],
    );

Future<void> _shot(WidgetTester t, String name, Widget child,
    {double scale = 1, double width = 390}) async {
  final key = GlobalKey();
  t.view.devicePixelRatio = 3;
  t.view.physicalSize = Size(width * 3, 1400 * 3);
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  await t.pumpWidget(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MediaQuery(
      data: MediaQueryData(
          size: Size(width, 1400),
          textScaler: TextScaler.linear(scale),
          disableAnimations: true),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9FB),
        body: SingleChildScrollView(
            child: RepaintBoundary(key: key, child: child)),
      ),
    ),
  ));
  await t.runAsync(() async {
    final ctx = key.currentContext!;
    // optional per store: a store without the light logo shows its name
    await precacheImage(const AssetImage('images/app_logo_light.webp'), ctx,
        onError: (_, __) {});
  });
  await t.pump(const Duration(milliseconds: 100));
  expect(t.takeException(), isNull, reason: '$name overflowed or threw');
  final out = Platform.environment['THEATRE_CHROME_OUT'];
  if (out == null) return;
  await t.runAsync(() async {
    final b = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final img = await b.toImage(pixelRatio: 3);
    final png = await img.toByteData(format: ui.ImageByteFormat.png);
    Directory(out).createSync(recursive: true);
    File('$out/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
  });
}

Widget _pair(plp.Product a, plp.Product b) => Padding(
      padding: const EdgeInsets.all(16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: ProductCard13(product: a, onTapCard: () {})),
        const SizedBox(width: 16),
        Expanded(child: ProductCard13(product: b, onTapCard: () {})),
      ]),
    );

void main() {
  setUpAll(() async {
    NoImageMark.debugGeneric = true;
    GoogleFonts.config.allowRuntimeFetching = false;
    await CurrencyUtil.initializeCurrencySymbol('₹');
    await _font('Archivo', 'fonts/Archivo-Variable.ttf');
    await _icons();
  });

  testWidgets('header-20', (t) async {
    await _shot(
        t,
        'AppHeaderTheatre1',
        const SizedBox(
            height: AppHeaderTheatre1.height,
            child: AppHeaderTheatre1(cartCount: 3)));
  });

  for (final scale in [1.0, 1.3]) {
    testWidgets('productView13 at text x$scale', (t) async {
      await _shot(
          t,
          'productView13-x$scale',
          Column(children: [
            _pair(
                _p('Denon AVR-X1800H 7.2 Channel 8K AV Receiver with Dolby Atmos and HEOS',
                    89990,
                    mrp: 99990),
                _p('Polk Signa S4 Dolby Atmos Wireless Soundbar', 24999,
                    variants: 3)),
            _pair(_p('Klipsch R-120SW 12 inch Subwoofer', 32900),
                _p('Marantz Cinema 70s 7.2 Ch 8K AV Receiver', 114900)),
          ]),
          scale: scale);
    });
  }

  for (final scale in [1.0, 1.3]) {
    testWidgets('productView13 on a small phone at text x$scale', (t) async {
      await _shot(
          t,
          'productView13-320-x$scale',
          _pair(
              _p('Denon AVR-X1800H 7.2 Channel 8K AV Receiver with Dolby Atmos',
                  89990,
                  mrp: 99990),
              _p('Sony Bravia Projector', 315000)),
          width: 320,
          scale: scale);
    });
  }

  // Central picker previews: no merchant names, greyed after capture.
  testWidgets('previews', (t) async {
    await _shot(
        t,
        'productView13',
        _pair(_p('Maker AV-100 7.2 Ch 8K Receiver', 89990, mrp: 99990),
            _p('Maker S-20 Wireless Soundbar', 24999, variants: 3)));
  });
}
