import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/currency_util.dart';
import 'package:waioz/utility/font_utils.dart';

/// PREMIUM MOBILE DESIGN KIT
/// A small, native design system every premium home component builds on so the
/// look is coherent instead of one-off: a refined type scale, spacing/radius/
/// shadow tokens, a clean image primitive (locked aspect + soft load/fallback),
/// theme-accent buttons with guaranteed contrast, and shared card/section/price
/// pieces. Colors + font still come from the merchant theme (AppColors /
/// FontUtils), so this stays brand-aware.

// ── Spacing / radius / shadow ────────────────────────────────────────────────
class PGap {
  static const double xs = 4, sm = 8, md = 12, lg = 16, xl = 20, xxl = 24, xxxl = 32;
}

class PRadius {
  static const double chip = 12, image = 16, card = 20, sheet = 24, pill = 100;
}

class PShadow {
  /// Soft, low-contrast lift — premium, not the heavy default card shadow.
  static List<BoxShadow> soft = [
    BoxShadow(color: const Color(0xFF272727).withOpacity(0.06), blurRadius: 22, offset: const Offset(0, 10)),
  ];
  static List<BoxShadow> hair = [
    BoxShadow(color: const Color(0xFF272727).withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
  ];
}

// ── Color helpers ────────────────────────────────────────────────────────────
class PColor {
  static Color get accent => AppColors.primary;
  static const Color ink = Color(0xFF1A1A1A);
  static const Color ink70 = Color(0xB31A1A1A);
  static const Color ink45 = Color(0x731A1A1A);
  static const Color line = Color(0xFFEDEDF0);
  static const Color surface = Colors.white;
  static const Color canvas = Color(0xFFF7F7F9);

  /// Contrast-safe text/icon color for a filled accent (never white-on-pale).
  static Color onAccent(Color bg) =>
      bg.computeLuminance() > 0.6 ? ink : Colors.white;

  /// A soft tint of the accent for chips/wash backgrounds.
  static Color accentWash([double o = 0.10]) => AppColors.primary.withOpacity(o);
}

// ── Type scale (respects the merchant font via FontUtils) ─────────────────────
class PType {
  static TextStyle display({Color color = PColor.ink}) => FontUtils.primaryFontStyle(
      fontSize: 23, fontWeight: FontWeight.w800, color: color, letterSpacing: -0.4).copyWith(height: 1.15);
  static TextStyle section({Color color = PColor.ink}) => FontUtils.primaryFontStyle(
      fontSize: 18, fontWeight: FontWeight.w700, color: color, letterSpacing: -0.3).copyWith(height: 1.2);
  static TextStyle sub({Color color = PColor.ink45}) => FontUtils.secondaryFontStyle(
      fontSize: 13, fontWeight: FontWeight.w500, color: color).copyWith(height: 1.3);
  static TextStyle cardTitle({Color color = PColor.ink}) => FontUtils.primaryFontStyle(
      fontSize: 14, fontWeight: FontWeight.w600, color: color, letterSpacing: -0.1).copyWith(height: 1.25);
  static TextStyle price({Color color = PColor.ink, double size = 15}) => FontUtils.primaryFontStyle(
      fontSize: size, fontWeight: FontWeight.w700, color: color, letterSpacing: -0.2);
  static TextStyle strike({Color color = PColor.ink45}) => FontUtils.secondaryFontStyle(
      fontSize: 12, fontWeight: FontWeight.w500, color: color, decoration: TextDecoration.lineThrough);
  static TextStyle label({Color color = PColor.ink70, double size = 12}) => FontUtils.secondaryFontStyle(
      fontSize: size, fontWeight: FontWeight.w600, color: color);
  static TextStyle badge({Color color = PColor.ink}) => FontUtils.primaryFontStyle(
      fontSize: 10, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.4);
}

// ── Image primitive: locked aspect, soft neutral load + graceful fallback ─────
class PImage extends StatelessWidget {
  final String? url;
  final double? aspectRatio; // null => fill parent
  final double radius;
  final BoxFit fit;
  const PImage({super.key, this.url, this.aspectRatio, this.radius = PRadius.image, this.fit = BoxFit.cover});

  Widget _placeholder() => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [PColor.accentWash(0.08), PColor.accentWash(0.04), const Color(0xFFF1F1F4)],
          ),
        ),
      );

  Widget _fallback() => DecoratedBox(
        decoration: const BoxDecoration(color: Color(0xFFF1F1F4)),
        child: Center(
          child: Icon(Icons.image_outlined, size: 22, color: PColor.ink45.withOpacity(0.5)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    Widget img;
    if (url == null || url!.trim().isEmpty) {
      img = _placeholder();
    } else {
      img = CachedNetworkImage(
        imageUrl: url!,
        fit: fit,
        fadeInDuration: const Duration(milliseconds: 200),
        placeholder: (_, __) => _placeholder(),
        errorWidget: (_, __, ___) => _fallback(),
      );
    }
    final clipped = ClipRRect(borderRadius: BorderRadius.circular(radius), child: img);
    return aspectRatio == null ? clipped : AspectRatio(aspectRatio: aspectRatio!, child: clipped);
  }
}

// ── Card primitive ───────────────────────────────────────────────────────────
class PCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double radius;
  final bool shadow;
  const PCard({super.key, required this.child, this.padding, this.color, this.radius = PRadius.card, this.shadow = true});
  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color ?? PColor.surface,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: PColor.line, width: 1),
          boxShadow: shadow ? PShadow.hair : null,
        ),
        child: child,
      );
}

// ── Section header: title + sub on the left, optional CTA pill (wraps safely) ─
class PSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? cta;
  final VoidCallback? onCta;
  final EdgeInsetsGeometry padding;
  const PSectionHeader({super.key, required this.title, this.subtitle, this.cta, this.onCta,
      this.padding = const EdgeInsets.fromLTRB(PGap.lg, 0, PGap.lg, PGap.md)});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: PType.section()),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis, style: PType.sub()),
                ],
              ],
            ),
          ),
          if (cta != null && cta!.isNotEmpty) ...[
            const SizedBox(width: PGap.md),
            PCtaPill(label: cta!, onTap: onCta),
          ],
        ],
      ),
    );
  }
}

// ── CTA pill (ghost, accent) ─────────────────────────────────────────────────
class PCtaPill extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const PCtaPill({super.key, required this.label, this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(color: PColor.accentWash(0.10), borderRadius: BorderRadius.circular(PRadius.pill)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: PType.label(color: PColor.accent, size: 12.5).copyWith(fontWeight: FontWeight.w700))),
            const SizedBox(width: 4),
            Icon(Icons.arrow_forward_rounded, size: 14, color: PColor.accent),
          ]),
        ),
      );
}

// ── Add button (filled accent, contrast-safe) + compact icon variant ─────────
class PAddButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool compact; // icon-only square
  final String label;
  const PAddButton({super.key, this.onTap, this.compact = false, this.label = 'Add'});
  @override
  Widget build(BuildContext context) {
    final fg = PColor.onAccent(PColor.accent);
    if (compact) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          height: 34, width: 34,
          decoration: BoxDecoration(color: PColor.accent, borderRadius: BorderRadius.circular(11)),
          child: Icon(Icons.add_rounded, size: 20, color: fg),
        ),
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: PColor.accent, borderRadius: BorderRadius.circular(PRadius.pill)),
        child: Text(label, style: PType.label(color: fg, size: 13).copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.2)),
      ),
    );
  }
}

// ── Badge ────────────────────────────────────────────────────────────────────
class PBadge extends StatelessWidget {
  final String text;
  const PBadge({super.key, required this.text});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: PColor.ink, borderRadius: BorderRadius.circular(PRadius.pill)),
        child: Text(text.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: PType.badge(color: Colors.white)),
      );
}

// ── Price row (selling + strike + optional % off) ────────────────────────────
class PPrice extends StatelessWidget {
  final String? selling;
  final String? original;
  final double size;
  const PPrice({super.key, this.selling, this.original, this.size = 15});
  @override
  Widget build(BuildContext context) {
    final hasStrike = original != null && original!.isNotEmpty && original != selling;
    return Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
      // Selling price keeps priority (flex 3) so the real price never truncates;
      // the strike (flex 2) gives way first in tight cards.
      Flexible(flex: 3, child: Text(CurrencyUtil.appendCurrency(selling ?? ''), maxLines: 1, overflow: TextOverflow.ellipsis, style: PType.price(size: size))),
      if (hasStrike) ...[
        const SizedBox(width: 6),
        Flexible(flex: 2, child: Text(CurrencyUtil.appendCurrency(original ?? ''), maxLines: 1, overflow: TextOverflow.ellipsis, style: PType.strike())),
      ],
    ]);
  }
}

// ── Rating chip ──────────────────────────────────────────────────────────────
class PRating extends StatelessWidget {
  final num value;
  const PRating({super.key, required this.value});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF5A623)),
        const SizedBox(width: 2),
        Text(value.toStringAsFixed(1), style: PType.label(size: 11.5).copyWith(fontWeight: FontWeight.w700)),
      ]);
}
