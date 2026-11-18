// Renders the REAL Unnwrap app home (get_home_page/v8) through the RIBBON
// family with the store's own photos read from disk, at 390 and 360 wide,
// writes a PNG per section and fails on any overflow or exception. A third
// pass runs with motion on and walks the interactions (hero tap, tab switch,
// voucher steps, gift this).
//
//   RIBBON_HOME_JSON=<get_home_page/v8 response>        (default: the backup)
//   RIBBON_IMAGE_ROOT=<dir that holds the /unnwrap/... files>
//   RIBBON_OUT=<dir for the PNGs>
//   flutter test test/cms_preview/ribbon_unnwrap_preview_test.dart
//
// Skips itself when the JSON or the images are not on this machine.

import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/ui/widgets/home/basket/basket_shared.dart';
import 'package:waioz/ui/widgets/home/marketplace_registry.dart';
import 'package:waioz/utility/currency_util.dart';
import 'package:waioz/utility/image_fallback_widget.dart';

const _backup = '/Users/apple/Documents/VirpanAI/.project-backups/unnwrap-2026-11-18';

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
  final jsonPath = env['RIBBON_HOME_JSON'] ?? '$_backup/work/app-home.json';
  final imageRoot = env['RIBBON_IMAGE_ROOT'] ?? '/Users/apple/Documents/VirpanAI/tmp/iy/web-170/public';
  final outDir = env['RIBBON_OUT'] ?? '$_backup/app-shots';
  final ready = File(jsonPath).existsSync() && Directory('$imageRoot/unnwrap').existsSync();

  setUpAll(() async {
    if (!ready) return;
    NoImageMark.debugGeneric = true;
    GoogleFonts.config.allowRuntimeFetching = false;
    await _loadFont('CircularStd', 'fonts/circular_std_book_regular.ttf');
    await _loadFont('SofiaSans', 'fonts/SofiaSans-Variable.ttf');
    await _loadFont('SofiaSansExtraCondensed', 'fonts/SofiaSansExtraCondensed-Variable.ttf');
    await _loadFont('Archivo', 'fonts/Archivo-Variable.ttf');
    await _loadMaterialIcons();
    await CurrencyUtil.initializeCurrencySymbol('₹');
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
    BasketImage.debugProvider = (url) {
      final path = Uri.tryParse(url)?.path ?? '';
      final f = File('$imageRoot$path');
      if (path.isEmpty || !f.existsSync()) return MemoryImage(kTransparentPng);
      return _memo.putIfAbsent(f.path, () => MemoryImage(f.readAsBytesSync()));
    };
  });

  List<Content> sections() {
    final body = jsonDecode(File(jsonPath).readAsStringSync());
    return (body['content'] as List)
        .map((x) => Content.fromJson(Map<String, dynamic>.from(x)))
        .where((c) => marketplaceHomeWidget(c) != null)
        .toList();
  }

  Future<void> precache(WidgetTester tester) async {
    await tester.runAsync(() async {
      for (final el in find.byType(Image).evaluate().toList()) {
        await precacheImage((el.widget as Image).image, el).timeout(const Duration(seconds: 20), onTimeout: () {});
      }
    });
  }

  Future<void> save(WidgetTester tester, GlobalKey key, String name) async {
    Directory(outDir).createSync(recursive: true);
    final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 2);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      File('$outDir/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
    });
  }

  /// Pumps the whole home; returns the section keys and the page key.
  Future<(List<GlobalKey>, GlobalKey, List<Content>, List<(int, String)>)> pumpHome(WidgetTester tester, Size size,
      {required bool still}) async {
    final list = sections();
    tester.view.devicePixelRatio = 3;
    tester.view.physicalSize = Size(size.width * 3, size.height * 3);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final keys = List.generate(list.length, (_) => GlobalKey());
    final page = GlobalKey();
    final cart = <(int, String)>[];
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MediaQuery(
        data: MediaQueryData(size: size, devicePixelRatio: 3, disableAnimations: still),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: RepaintBoundary(
              key: page,
              child: Column(children: [
                for (var i = 0; i < list.length; i++)
                  RepaintBoundary(
                    key: keys[i],
                    child: marketplaceHomeWidget(list[i], onCartQtyChanged: (d, v) => cart.add((d, v)))!,
                  ),
              ]),
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
    await precache(tester);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));
    return (keys, page, list, cart);
  }

  /// Scrolls [finder] to the middle of the screen (ensureVisible's top edge
  /// leaves a tap target half outside the view).
  Future<void> reveal(WidgetTester tester, Finder finder) async {
    Scrollable.ensureVisible(finder.evaluate().first, alignment: 0.5);
    await tester.pump();
  }

  Future<void> teardown(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  }

  for (final size in const [Size(390, 844), Size(360, 780)]) {
    testWidgets('RIBBON home at ${size.width.toInt()} wide', (tester) async {
      if (!ready) return;
      final (keys, page, list, _) = await pumpHome(tester, size, still: true);
      final tag = size.width.toInt();
      expect(list.length, 7, reason: 'all seven RIBBON sections render');
      for (var i = 0; i < list.length; i++) {
        await save(tester, keys[i], '$tag-${(i + 1).toString().padLeft(2, '0')}-${list[i].layoutName}');
      }
      await save(tester, page, '$tag-00-home');
      // the hero's second button scrolls to the voucher
      expect(find.text('How gifting works'), findsWidgets);

      // voucher states 2 and 3
      final how = list.indexWhere((c) => c.layoutName == 'RibbonHow1');
      await reveal(tester, find.text('Gift voucher'));
      await tester.tap(find.text('Gift voucher'));
      await tester.pump(const Duration(milliseconds: 100));
      await precache(tester);
      await tester.pump(const Duration(milliseconds: 100));
      await save(tester, keys[how], '$tag-04b-RibbonHow1-sent');
      await tester.tap(find.text('Gift voucher'));
      await tester.pump(const Duration(milliseconds: 100));
      await save(tester, keys[how], '$tag-04c-RibbonHow1-booked');
      expect(find.text('Booked'), findsOneWidget);

      // another tab
      final tabs = list.indexWhere((c) => c.layoutName == 'RibbonTabs1');
      final second = basketMultiProducts(list[tabs].layoutData![1]);
      await reveal(tester, find.text(list[tabs].layoutData![1].title!).first);
      await tester.tap(find.text(list[tabs].layoutData![1].title!).first);
      await tester.pump(const Duration(milliseconds: 100));
      await precache(tester);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text(second.first.title!), findsWidgets);
      await save(tester, keys[tabs], '$tag-03b-RibbonTabs1-tab2');

      await teardown(tester);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('RIBBON motion: hero steps, tab switch, voucher, gift this', (tester) async {
    if (!ready) return;
    final (keys, _, list, cart) = await pumpHome(tester, const Size(390, 844), still: false);
    // the first photo settles in, the hero clock runs and moves to slide 2
    await tester.pump(const Duration(milliseconds: 400));
    await save(tester, keys[0], 'motion-01-hero-first-photo');
    await tester.pump(const Duration(milliseconds: 6200));
    await precache(tester); // the next slide's photo
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 450));
    await save(tester, keys[0], 'motion-01b-hero-crossfade');
    await tester.pump(const Duration(seconds: 1));
    // tap the left third: back a slide
    await tester.tapAt(const Offset(40, 300));
    await tester.pump(const Duration(seconds: 1));

    // tabs: switch, cards stagger in
    final tabs = list.indexWhere((c) => c.layoutName == 'RibbonTabs1');
    final label = list[tabs].layoutData![2].title!;
    await reveal(tester, find.text(label).first);
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text(label).first);
    await tester.pump(const Duration(milliseconds: 200));
    await precache(tester);
    await tester.pump(const Duration(milliseconds: 120));
    await save(tester, keys[tabs], 'motion-03-tabs-switching');
    await tester.pump(const Duration(seconds: 1));

    // gift this → cart callback with the voucher's variant
    final gift = find.text('Gift this').first;
    await reveal(tester, gift);
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(gift);
    await tester.pump();
    expect(cart, isNotEmpty);
    expect(cart.first.$1, 1);
    expect(cart.first.$2, startsWith('variant_'));

    // voucher: walk to "Booked", the stamp lands
    await reveal(tester, find.text('Gift voucher'));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Gift voucher'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('Gift voucher'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 520));
    final how = list.indexWhere((c) => c.layoutName == 'RibbonHow1');
    await save(tester, keys[how], 'motion-04-stamp-dropping');
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Booked'), findsOneWidget);

    // voices auto-advance after 7 s once on screen
    final voices = list.indexWhere((c) => c.layoutName == 'RibbonVoices1');
    await reveal(tester, find.byKey(keys[voices]));
    await tester.pump(const Duration(seconds: 8));
    await tester.pump(const Duration(seconds: 1));

    await teardown(tester);
    expect(tester.takeException(), isNull);
  });
}

/// 1×1 transparent PNG for images that are not on disk.
final Uint8List kTransparentPng = Uint8List.fromList(const [
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);
