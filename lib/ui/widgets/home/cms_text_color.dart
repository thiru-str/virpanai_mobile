import 'package:flutter/widgets.dart';

// CmsTextColor — carries a per-component "Text Color" (from
// content.layoutSecondaryColor) down the widget tree so shared text widgets
// (e.g. HomeMerchSectionHeader) recolour their on-background text to match a
// coloured section background. Card text keeps its own explicit colours.
//
// This is the Flutter analogue of the web's CSS-variable override in
// getLayoutStyles — wrap each rendered CMS component with it (see the
// buildComponentList item builders in home_page.dart / custom_page.dart).
class CmsTextColor extends InheritedWidget {
  final Color? color;
  const CmsTextColor({super.key, required this.color, required super.child});

  static Color? of(BuildContext context) {
    final w = context.dependOnInheritedWidgetOfExactType<CmsTextColor>();
    return w?.color;
  }

  @override
  bool updateShouldNotify(CmsTextColor oldWidget) => oldWidget.color != color;
}

// Resolve the colour for text that sits on the SECTION background: the
// per-component Text Color cascade if set, else the given fallback (the theme
// default). Use this for titles, descriptions, category labels, etc. — text
// inside cards should keep its own explicit colour so it stays readable.
Color cmsText(BuildContext context, Color fallback) {
  return CmsTextColor.of(context) ?? fallback;
}

// Parse a hex ("#rrggbb"/"#rgb") or rgb()/rgba() string into a Color. Returns
// null for empty/gradient/unparseable values (so the default colour is used).
Color? parseCmsColor(String? raw) {
  if (raw == null) return null;
  var v = raw.trim();
  if (v.isEmpty || v.contains('gradient')) return null;
  if (v.startsWith('#')) {
    var h = v.substring(1);
    if (h.length == 3) {
      h = h.split('').map((c) => '$c$c').join();
    }
    if (h.length == 6) {
      final n = int.tryParse('FF$h', radix: 16);
      if (n != null) return Color(n);
    }
    if (h.length == 8) {
      final n = int.tryParse(h, radix: 16);
      if (n != null) return Color(n);
    }
    return null;
  }
  final m = RegExp(r'rgba?\(([^)]+)\)').firstMatch(v);
  if (m != null) {
    final parts = m.group(1)!.split(',').map((e) => e.trim()).toList();
    if (parts.length >= 3) {
      final r = int.tryParse(parts[0]);
      final g = int.tryParse(parts[1]);
      final bl = int.tryParse(parts[2]);
      if (r != null && g != null && bl != null) {
        return Color.fromARGB(255, r, g, bl);
      }
    }
  }
  return null;
}
