import 'package:cached_network_image/cached_network_image.dart';
import 'cms_text_color.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_utils.dart';
import 'package:waioz/utility/currency_util.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/image_fallback_widget.dart';
import 'package:waioz/utility/redirect_utils.dart';

class Slider6 extends StatelessWidget {
  final Content content;

  const Slider6({
    Key? key,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backgroundDecoration = AppUtils.buildLayoutBackground(content);
    final containerPadding = backgroundDecoration == null
        ? const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0)
        : const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0);

    return Container(
      decoration: backgroundDecoration,
      child: Padding(
        padding: containerPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Text(
                  content.layoutTitle ?? '',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: FontUtils.secondaryFontStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: cmsCardText(context, AppColors.textColor),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (int i = 0;
                        i < (content.layoutData?.length ?? 0);
                        i++) ...[
                      _Slider6Card(
                        layoutData: content.layoutData![i],
                        onTap: () {
                          RedirectUtils.handleContentRedirect(
                            context: context,
                            layoutOption: content.layoutOption ?? "",
                            layoutData: content.layoutData![i],
                          );
                        },
                      ),
                      if (i != content.layoutData!.length - 1)
                        const SizedBox(width: 16),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slider6Card extends StatelessWidget {
  final LayoutDatum layoutData;
  final VoidCallback onTap;

  const _Slider6Card({
    required this.layoutData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final product = layoutData.productData;
    final mediaUrl = layoutData.image ?? '';
    final productImage = product?.image ?? '';
    final title = product?.title ?? '';
    final sellingPrice = product?.prices?.sellingPrice ?? '0';
    final originalPrice = product?.prices?.originalPrice ?? '0';
    final hasDiscount = product?.prices?.discountedPrice != null &&
        product!.prices!.discountedPrice != "0";

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: cmsCard(context, Colors.white),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 260,
                    child: _Slider6Media(mediaUrl: mediaUrl),
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: -28,
                  child: Container(
                    width: 56,
                    height: 56,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD2D2DE),
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x22000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: productImage.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: Uri.encodeFull(productImage),
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) =>
                                  const ImageFallbackWidget(
                                w: 24,
                                h: 24,
                                fit: BoxFit.contain,
                              ),
                            )
                          : const ImageFallbackWidget(
                              w: 24,
                              h: 24,
                              fit: BoxFit.contain,
                            ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 34),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: FontUtils.primaryFontStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cmsCardText(context, AppColors.textColor),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
              child: Row(
                children: [
                  Text(
                    CurrencyUtil.appendCurrency(sellingPrice),
                    style: FontUtils.primaryFontStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: cmsCardText(context, AppColors.textColor),
                    ),
                  ),
                  if (hasDiscount) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        CurrencyUtil.appendCurrency(originalPrice),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FontUtils.primaryFontStyle(
                          fontSize: 14,
                          color: cmsCardText(context, AppColors.textColor).withOpacity(0.35),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slider6Media extends StatefulWidget {
  final String mediaUrl;

  const _Slider6Media({
    required this.mediaUrl,
  });

  @override
  State<_Slider6Media> createState() => _Slider6MediaState();
}

class _Slider6MediaState extends State<_Slider6Media> {
  VideoPlayerController? _controller;
  bool _isVisible = false;

  bool get _isVideo => widget.mediaUrl.toLowerCase().endsWith('.mp4');

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    if (_isVideo && widget.mediaUrl.isNotEmpty) {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(Uri.encodeFull(widget.mediaUrl)),
      )..initialize().then((_) {
          _controller?.setLooping(true);
          _controller?.setVolume(0);
          if (_isVisible) {
            _controller?.play();
          }
          if (mounted) setState(() {});
        });
    }
  }

  @override
  void didUpdateWidget(covariant _Slider6Media oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mediaUrl != widget.mediaUrl) {
      _controller?.dispose();
      _controller = null;
      _isVisible = false;
      _initController();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _handleVisibility(double visibleFraction) {
    final shouldPlay = visibleFraction > 0.6;
    if (shouldPlay == _isVisible) return;

    _isVisible = shouldPlay;
    if (_controller?.value.isInitialized ?? false) {
      if (shouldPlay) {
        _controller?.play();
      } else {
        _controller?.pause();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.mediaUrl),
      onVisibilityChanged: (info) {
        _handleVisibility(info.visibleFraction);
      },
      child: _buildMedia(),
    );
  }

  Widget _buildMedia() {
    if (_isVideo) {
      if (_controller?.value.isInitialized ?? false) {
        return FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller!.value.size.width,
            height: _controller!.value.size.height,
            child: VideoPlayer(_controller!),
          ),
        );
      }

      return Container(
        color: const Color(0xFFD9DBE6),
      );
    }

    if (widget.mediaUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: Uri.encodeFull(widget.mediaUrl),
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => const ImageFallbackWidget(
          h: 260,
          w: double.infinity,
          fit: BoxFit.contain,
        ),
      );
    }

    return const ImageFallbackWidget(
      h: 260,
      w: double.infinity,
      fit: BoxFit.contain,
    );
  }
}
