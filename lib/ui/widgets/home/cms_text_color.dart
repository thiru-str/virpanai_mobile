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
  final Color? color; // Text Color (layout_secondary_color) — section-bg text
  final Color? cardColor; // Card Background (layout_card_color) — card surfaces
  final Color? accent; // Primary Color (layout_primary_color) — CTAs/buttons
  const CmsTextColor(
      {super.key,
      required this.color,
      this.cardColor,
      this.accent,
      required super.child});

  static CmsTextColor? _of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CmsTextColor>();

  static Color? of(BuildContext context) => _of(context)?.color;
  static Color? cardOf(BuildContext context) => _of(context)?.cardColor;
  static Color? accentOf(BuildContext context) => _of(context)?.accent;

  @override
  bool updateShouldNotify(CmsTextColor oldWidget) =>
      oldWidget.color != color ||
      oldWidget.cardColor != cardColor ||
      oldWidget.accent != accent;
}

// Colour for text that sits on the SECTION background (titles, descriptions,
// category labels): the Text Color cascade if set, else the theme default.
Color cmsText(BuildContext context, Color fallback) =>
    CmsTextColor.of(context) ?? fallback;

// Card surface colour: the Card Background cascade if set, else the default.
Color cmsCard(BuildContext context, Color fallback) =>
    CmsTextColor.cardOf(context) ?? fallback;

// Colour for text INSIDE a card: when the card is themed (Card Background set),
// it follows the Text Color so it's readable on the themed card; otherwise it
// keeps its default (dark on a white card).
Color cmsCardText(BuildContext context, Color fallback) {
  if (CmsTextColor.cardOf(context) == null) return fallback;
  return CmsTextColor.of(context) ?? fallback;
}

// Solid CTA / button FILL: the Primary Color cascade if set, else the widget's
// own fallback. Pair with cmsOn(...) for a contrast-correct label colour.
Color cmsAccent(BuildContext context, Color fallback) =>
    CmsTextColor.accentOf(context) ?? fallback;

// A DARK panel/island background: Card Background if set, else a dark fallback.
// Text inside such a panel should use cmsText(context, Colors.white) so it
// follows Text Color but defaults to white on the dark surface.
Color cmsPanel(BuildContext context, Color fallback) =>
    CmsTextColor.cardOf(context) ?? fallback;

// True when a colour is light enough to need a dark label on top of it.
bool cmsIsLight(Color c) =>
    (0.2126 * c.red + 0.7152 * c.green + 0.0722 * c.blue) / 255 > 0.6;

// Contrast-correct label colour for text/icons sitting ON a filled button.
Color cmsOn(Color background) =>
    cmsIsLight(background) ? const Color(0xFF0B0B0B) : const Color(0xFFFFFFFF);

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
