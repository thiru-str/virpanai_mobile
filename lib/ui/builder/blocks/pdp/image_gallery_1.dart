import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../model/block_config.dart';
import '../../../../utility/app_colors.dart';

/// ImageGallery1 - Swipe-based full-width image carousel with dot indicators.
/// Extracted from product_detail_page.dart buildProductImages()
class ImageGallery1Widget extends StatefulWidget {
  final List<String> images;
  final BlockConfig config;
  final Function(int)? onImageTap;

  const ImageGallery1Widget({
    super.key,
    required this.images,
    required this.config,
    this.onImageTap,
  });

  @override
  State<ImageGallery1Widget> createState() => _ImageGallery1WidgetState();
}

class _ImageGallery1WidgetState extends State<ImageGallery1Widget> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return Container(
        height: 300,
        color: Colors.grey[100],
        child: const Center(child: Icon(Icons.image, size: 48, color: Colors.grey)),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 350,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => widget.onImageTap?.call(index),
                child: CachedNetworkImage(
                  imageUrl: widget.images[index],
                  fit: BoxFit.contain,
                  placeholder: (_, __) => Container(color: Colors.grey[100]),
                  errorWidget: (_, __, ___) => Container(
                    color: Colors.grey[100],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.images.length > 1 && widget.config.getBool('show_image_count', defaultValue: true))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.images.length, (index) {
                return Container(
                  width: _currentIndex == index ? 20 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? AppColors.primary
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}
