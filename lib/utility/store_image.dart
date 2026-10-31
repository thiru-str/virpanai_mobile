import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:waioz/utility/app_config.dart';

/// The widths the storefront's /_next/image accepts (Next's defaults, above
/// the icon sizes). Anything else answers 400, so targets snap UP to one of
/// these — which also means the app and the website share cached files.
const List<int> _kOptimiserWidths = [256, 384, 640, 750, 828, 1080, 1200, 1920];

/// Physical pixels an image needs across, for a box [width]×[height] (logical).
/// `cover` scales by whichever side overflows, so a tall frame needs more than
/// its width: decoding at the width alone would blur a square photo in a 4:5
/// card.
int storeImagePixels(double width, double? height, double devicePixelRatio, BoxFit? fit) {
  final side = fit == BoxFit.cover && height != null && height.isFinite ? math.max(width, height) : width;
  final target = side * math.min(devicePixelRatio, 3);
  return _kOptimiserWidths.firstWhere((w) => w >= target, orElse: () => _kOptimiserWidths.last);
}

/// [url] as a resized WebP from the storefront's image optimiser, or null when
/// this build has no optimiser or the file isn't on the store's CDN (the
/// optimiser refuses hosts it doesn't list).
String? optimisedImageUrl(
  String url,
  int width, {
  String base = AppConfig.imageOptimiserBase,
  String cdnHost = AppConfig.imageCdnHost,
}) {
  if (base.isEmpty) return null;
  final escaped = url.trim().replaceAll(' ', '%20');
  final uri = Uri.tryParse(escaped);
  if (uri == null || uri.host != cdnHost) return null;
  final path = uri.path.toLowerCase();
  if (path.endsWith('.gif') || path.endsWith('.svg')) return null;
  return '$base/_next/image?url=${Uri.encodeComponent(escaped)}&w=$width&q=75';
}

/// Drop-in for [CachedNetworkImage] that loads and decodes an image at the size
/// it is shown, rather than at the size it was uploaded:
///  - decodes to the box's pixels (memory, and smooth scrolling on long homes);
///  - downloads a resized WebP from the storefront's optimiser where the build
///    has one, and falls back to the original file if that request fails, so
///    the app never depends on the website being up.
///
/// A box with no explicit width is measured with a LayoutBuilder, which cannot
/// answer intrinsic-size queries: inside IntrinsicHeight/Width pass [width].
/// Full-screen zoom keeps [CachedNetworkImage], which needs every original pixel.
class StoreImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final Alignment alignment;
  final Duration fadeInDuration;
  final Duration? placeholderFadeInDuration;
  final PlaceholderWidgetBuilder? placeholder;
  final LoadingErrorWidgetBuilder? errorWidget;

  const StoreImage({
    super.key,
    required this.imageUrl,
    this.fit,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.fadeInDuration = const Duration(milliseconds: 500),
    this.placeholderFadeInDuration,
    this.placeholder,
    this.errorWidget,
  });

  Widget _network(String url, int pixels, LoadingErrorWidgetBuilder? onError, {Map<String, String>? headers}) =>
      CachedNetworkImage(
        imageUrl: url,
        httpHeaders: headers,
        fit: fit,
        width: width,
        height: height,
        alignment: alignment,
        fadeInDuration: fadeInDuration,
        placeholderFadeInDuration: placeholderFadeInDuration,
        placeholder: placeholder,
        errorWidget: onError,
        memCacheWidth: pixels,
      );

  Widget _sized(BuildContext context, double boxWidth, double? boxHeight) {
    final pixels = storeImagePixels(boxWidth, boxHeight, MediaQuery.of(context).devicePixelRatio, fit);
    final optimised = optimisedImageUrl(imageUrl, pixels);
    if (optimised == null) return _network(imageUrl, pixels, errorWidget);
    return _network(
      optimised,
      pixels,
      (_, __, ___) => _network(imageUrl, pixels, errorWidget),
      // the optimiser only answers WebP to a client that says it takes WebP
      headers: const {'accept': 'image/webp,*/*'},
    );
  }

  @override
  Widget build(BuildContext context) {
    final fixedWidth = width;
    if (fixedWidth != null && fixedWidth.isFinite) return _sized(context, fixedWidth, height);
    return LayoutBuilder(
      builder: (context, box) => _sized(
        context,
        box.hasBoundedWidth ? box.maxWidth : MediaQuery.of(context).size.width,
        box.hasBoundedHeight ? box.maxHeight : height,
      ),
    );
  }
}
