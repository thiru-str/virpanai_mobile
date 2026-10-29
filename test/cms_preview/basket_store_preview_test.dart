// Renders a REAL store home through the BASKET app components, with the
// store's own packshots read from disk, so the app can be compared with the
// web storefront section by section. Not part of the skeleton-preview suite.
//
//   BASKET_HOME_JSON=<home_page_web/v2 or get_home_page/v8 response> \
//   BASKET_IMAGE_DIR=<dir with map.json {url: file}> \
//   BASKET_OUT=<dir for the PNGs> \
//   flutter test test/cms_preview/basket_store_preview_test.dart
//
// Skips itself when the env vars are not set.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/ui/widgets/home/app_header_basket1.dart';
import 'package:waioz/ui/widgets/home/basket/basket_shared.dart';
import 'package:waioz/ui/widgets/home/cms_text_color.dart';
import 'package:waioz/ui/widgets/home/marketplace_registry.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/currency_util.dart';

Future<ByteData> _bytes(String path) async => ByteData.view((await File(path).readAsBytes()).buffer);

Future<void> _loadFont(String family, String path) async {
  final loader = FontLoader(family)..addFont(_bytes(path));
  await loader.load();
}

Future<void> _loadMaterialIcons() async {
  final root = Platform.environment['FLUTTER_ROOT'];
  final candidates = <String>[
    if (root != null) '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    '${File(Platform.resolvedExecutable).parent.parent.parent.path}/artifacts/material_fonts/MaterialIcons-Regular.otf',
  ];
  for (final c in candidates) {
    if (File(c).existsSync()) {
      final loader = FontLoader('MaterialIcons')..addFont(_bytes(c));
      await loader.load();
      return;
    }
  }
}

final Map<String, MemoryImage> _memo = {};

void main() {
  final env = Platform.environment;
  final jsonPath = env['BASKET_HOME_JSON'];
  final imageDir = env['BASKET_IMAGE_DIR'];
  final outDir = env['BASKET_OUT'];
  final ready = jsonPath != null && imageDir != null && outDir != null;

  setUpAll(() async {
    if (!ready) return;
    GoogleFonts.config.allowRuntimeFetching = false;
    await _loadFont('CircularStd', 'fonts/circular_std_book_regular.ttf');
    await _loadFont('Gabarito', 'fonts/gabarito_regular.ttf');
    await _loadMaterialIcons();
    await CurrencyUtil.initializeCurrencySymbol('₹');
    // PREVIEW_PRIMARY=#rrggbb sets the store's theme colour (default: Galaxy's).
    final primary = (env['PREVIEW_PRIMARY'] ?? '').replaceAll('#', '');
    AppColors.primary = primary.length == 6 ? Color(int.parse('FF$primary', radix: 16)) : const Color(0xFF0A6E93);
    // Report visibility at once — film tiles start loading when they are seen.
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
    final map = Map<String, dynamic>.from(jsonDecode(File('$imageDir/map.json').readAsStringSync()));
    BasketImage.debugProvider = (url) {
      final f = map[url];
      if (f == null) return MemoryImage(kTransparentPng);
      return _memo.putIfAbsent(f, () => MemoryImage(File('$imageDir/$f').readAsBytesSync()));
    };
  });

  testWidgets('store home through BASKET', (tester) async {
    if (!ready) return;
    final body = jsonDecode(File(jsonPath).readAsStringSync());
    final sections = (body['content'] as List)
        .map((x) => Content.fromJson(Map<String, dynamic>.from(x)))
        .where((c) => marketplaceHomeWidget(c) != null)
        .toList();

    tester.view.devicePixelRatio = 3;
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final keys = List.generate(sections.length, (_) => GlobalKey());
    final page = GlobalKey();
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MediaQuery(
        data: const MediaQueryData(size: Size(390, 844), devicePixelRatio: 3, disableAnimations: true),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: RepaintBoundary(
              key: page,
              child: Column(children: [
                // PREVIEW_HEADER=none leaves the BASKET header off (another family's store).
                if (env['PREVIEW_HEADER'] != 'none')
                  const SizedBox(height: AppHeaderBasket1.height, child: AppHeaderBasket1(cartCount: 2)),
                for (var i = 0; i < sections.length; i++)
                  RepaintBoundary(
                    key: keys[i],
                    child: CmsTextColor(
                      color: parseCmsColor(sections[i].layoutSecondaryColor),
                      cardColor: parseCmsColor(sections[i].layoutCardColor),
                      accent: parseCmsColor(sections[i].layoutPrimaryColor),
                      child: marketplaceHomeWidget(sections[i], onCartQtyChanged: (_, __) {})!,
                    ),
                  ),
              ]),
            ),
          ),
        ),
      ),
    ));
    // Decode the packshots (real async I/O), then let frames settle.
    // ignore: avoid_print
    print('pumped ${sections.length} sections');
    await tester.runAsync(() async {
      final els = find.byType(Image).evaluate().toList();
      // ignore: avoid_print
      print('images ${els.length}');
      for (final el in els) {
        final img = el.widget as Image;
        await precacheImage(img.image, el).timeout(const Duration(seconds: 20), onTimeout: () {
          // ignore: avoid_print
          print('timeout ${img.image}');
        });
      }
    });
    // ignore: avoid_print
    print('precached');
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));

    Directory(outDir).createSync(recursive: true);
    Future<void> save(GlobalKey key, String name) async {
      final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 2);
        final png = await image.toByteData(format: ui.ImageByteFormat.png);
        File('$outDir/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
      });
    }

    for (var i = 0; i < sections.length; i++) {
      await save(keys[i], '${(i + 1).toString().padLeft(2, '0')}-${sections[i].layoutName}');
    }
    await save(page, '00-home');
    final prev = FlutterError.onError;
    FlutterError.onError = (d) {
      // ignore: avoid_print
      print('TEARDOWN ERROR ${d.exceptionAsString()}\n${d.stack}');
    };
    await tester.pumpWidget(const SizedBox());
    FlutterError.onError = prev;
    final errors = <Object>[];
    Object? e;
    while ((e = tester.takeException()) != null) {
      errors.add(e!);
    }
    expect(errors, isEmpty, reason: errors.join('\n'));
  });
}

/// 1×1 transparent PNG for images the map does not know.
final Uint8List kTransparentPng = Uint8List.fromList(const [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);
