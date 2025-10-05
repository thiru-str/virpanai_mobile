import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/ui/widgets/item_video_tile.dart';
import 'package:waioz/utility/app_strings.dart';

import '../../../utility/app_assets.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/currency_util.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/page_route_utils.dart';
import '../../../utility/redirect_utils.dart';
import '../../product_detail_page.dart';
import '../../product_page.dart';

class Banner2 extends StatefulWidget {
  final Content content;

  const Banner2({Key? key, required this.content}) : super(key: key);

  @override
  State<Banner2> createState() => _Banner2State();
}

class _Banner2State extends State<Banner2> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  double get slideInterval =>
      double.tryParse(widget.content.layoutSlideTimeInterval ?? '5') ?? 5;

  @override
  void initState() {
    super.initState();
    // 👇 smaller viewport so next item is partially visible
    _pageController = PageController(viewportFraction: 0.45);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(
      Duration(seconds: slideInterval.toInt()),
          (_) {
        if (!mounted) return;
        final count = widget.content.layoutData?.length ?? 0;
        if (count == 0) return;

        setState(() {
          _currentPage = (_currentPage + 1) % count;
        });

        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      },
    );
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.content;
    final items = content.layoutData ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  content.layoutTitle ?? '',
                  style: FontUtils.secondaryFontStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                Visibility(
                  visible: content.layoutRedirectTitle?.isNotEmpty ?? false,
                  child: GestureDetector(
                    onTap: () {
                      RedirectUtils.handleContentRedirectViewAll(
                        context: context,
                        redirectData: content.redirectData!,
                      );
                    },
                    child: Text(
                      content.layoutRedirectTitle ?? '',
                      style: FontUtils.primaryFontStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// Carousel Section
          SizedBox(
            height: 190,
            child: PageView.builder(
              controller: _pageController,
              padEnds: false, // 👈 makes left/right edges tighter
              itemCount: items.length,
              onPageChanged: (i) {
                setState(() => _currentPage = i);
                _startAutoScroll();
              },
              itemBuilder: (context, index) {
                final item = items[index];
                final mediaUrl = item.image ?? '';
                final isVideo = mediaUrl.toLowerCase().endsWith('.mp4');

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0), // 👈 smaller gap
                  child: GestureDetector(
                    onTap: () {
                      RedirectUtils.handleContentRedirect(
                        context: context,
                        layoutOption: content.layoutOption!,
                        layoutData: item,
                      );
                    },
                    child: isVideo
                        ? ItemVideoTile(
                      key: ValueKey(mediaUrl),
                      videoUrl: mediaUrl,
                      title: item.title ?? '',
                      isActive: index == _currentPage,
                    )
                        : _buildImageTile(mediaUrl, item.title ?? ''),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageTile(String url, String title) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: url,
            width: 160,
            height: 150,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => _imageFallback(160, 180),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}


Widget _imageFallback(double w, double h) {
  return Container(
    width: w,
    height: h,
    color: AppColors.secondary,
    alignment: Alignment.center,
    child: SvgPicture.asset(
      AppAssets.ic_no_image,
      width: w * 0.5,
      height: h * 0.5,
    ),
  );
}
