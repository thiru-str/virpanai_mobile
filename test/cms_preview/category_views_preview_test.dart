// Category page layouts (theme.categoryView, admin "Category Page"): renders
// every layout as a full phone screen at 390 and 320 wide, normal and large
// text, and fails on any overflow. With CATEGORY_VIEWS_OUT set it writes PNGs:
//   CATEGORY_VIEWS_READABLE=1  real font + a sample accent, for review
//   unset                      the neutral grey skeleton used for central
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waioz/model/product_categories_response.dart';
import 'package:waioz/ui/widgets/category_views/category_views.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/image_fallback_widget.dart';

final _readable = Platform.environment['CATEGORY_VIEWS_READABLE'] == '1';

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

var _id = 0;
ProductCategory _c(String name, [List<ProductCategory> children = const []]) =>
    ProductCategory(
        id: 'pcat_${_id++}', name: name, image: '', categoryChildren: children);

List<ProductCategory> _leaves(List<String> names) =>
    [for (final n in names) _c(n)];

final _catalogue = [
  _c('Fruits & vegetables', _leaves([
    'Fresh fruits', 'Fresh vegetables', 'Leafy greens', 'Exotic fruits',
    'Cut and peeled', 'Herbs',
  ])),
  _c('Dairy, bread & eggs', _leaves([
    'Milk', 'Curd and yoghurt', 'Paneer and cheese', 'Butter and ghee',
    'Bread and buns', 'Eggs', 'Breakfast cereals',
  ])),
  _c('Atta, rice & dal', _leaves([
    'Atta and flours', 'Rice', 'Toor, moong and urad dal', 'Millets',
    'Poha and rava',
  ])),
  _c('Masala & spices', _leaves([
    'Whole spices', 'Powdered masala', 'Salt and sugar', 'Ready masala mixes',
  ])),
  _c('Snacks & namkeen', _leaves([
    'Chips', 'Namkeen and mixture', 'Biscuits', 'Murukku and traditional',
  ])),
  _c('Cleaning essentials', _leaves(['Detergent', 'Dishwash', 'Floor cleaner'])),
  _c('Personal care'),
  _c('Pooja needs'),
  _c('Baby care', _leaves(['Diapers', 'Baby food'])),
];

const _layouts = {
  CategoryView.categoryView1: 'Grid',
  CategoryView.categoryView2: 'Side rail',
  CategoryView.categoryView3: 'Sections',
  CategoryView.categoryView4: 'List',
  CategoryView.categoryView5: 'Tabs',
};

Future<void> _shot(WidgetTester t, String name, CategoryView view,
    {double scale = 1, double width = 390}) async {
  const height = 844.0;
  final key = GlobalKey();
  t.view.devicePixelRatio = 3;
  t.view.physicalSize = Size(width * 3, height * 3);
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  await t.pumpWidget(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(fontFamily: _readable ? 'Sofia' : null),
    home: MediaQuery(
      data: MediaQueryData(
          size: Size(width, height),
          textScaler: TextScaler.linear(scale),
          disableAnimations: true),
      child: RepaintBoundary(
        key: key,
        child: Scaffold(
          backgroundColor: const Color(0xFFF9F9FB),
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            title: const Text('Categories',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF272727))),
          ),
          body: categoryViewBody(view, _catalogue),
        ),
      ),
    ),
  ));
  await t.pump(const Duration(milliseconds: 100));
  expect(t.takeException(), isNull, reason: '$name overflowed or threw');
  final out = Platform.environment['CATEGORY_VIEWS_OUT'];
  if (out == null) return;
  await t.runAsync(() async {
    final b = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final img = await b.toImage(pixelRatio: 2);
    final png = await img.toByteData(format: ui.ImageByteFormat.png);
    Directory(out).createSync(recursive: true);
    File('$out/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
  });
}

void main() {
  setUpAll(() async {
    NoImageMark.debugGeneric = true;
    GoogleFonts.config.allowRuntimeFetching = false;
    // central previews stay neutral grey; the review set shows an accent
    AppColors.primary =
        _readable ? const Color(0xFF0C831F) : const Color(0xFF55585E);
    if (_readable) await _font('Sofia', 'fonts/SofiaSans-Variable.ttf');
    await _icons();
  });

  for (final view in _layouts.keys) {
    for (final width in [390.0, 320.0]) {
      for (final scale in [1.0, 1.3]) {
        testWidgets('${_layouts[view]} at $width wide, text x$scale',
            (t) async {
          final base = width == 390 && scale == 1.0
              ? view.name
              : '${view.name}-w${width.toInt()}-x$scale';
          await _shot(t, base, view, scale: scale, width: width);
        });
      }
    }
  }

  testWidgets('List layout with a row opened', (t) async {
    await _shot(t, 'categoryView4-open', CategoryView.categoryView4);
    await t.tap(find.text('Dairy, bread & eggs'));
    await t.pumpAndSettle();
    expect(find.text('All Dairy, bread & eggs'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('Side rail switches category', (t) async {
    await _shot(t, 'categoryView2-switch', CategoryView.categoryView2);
    expect(find.text('Fresh fruits'), findsOneWidget);
    await t.tap(find.text('Atta, rice & dal'));
    await t.pumpAndSettle();
    expect(find.text('Millets'), findsOneWidget);
    expect(find.text('Fresh fruits'), findsNothing);
  });

  test('unknown or empty setting falls back to the grid', () {
    expect(categoryViewFrom(null), CategoryView.categoryView1);
    expect(categoryViewFrom(''), CategoryView.categoryView1);
    expect(categoryViewFrom('header-3'), CategoryView.categoryView1);
    expect(categoryViewFrom('categoryView4'), CategoryView.categoryView4);
  });
}
