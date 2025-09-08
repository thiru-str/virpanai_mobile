import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/utility/image_fallback_widget.dart';

class FullscreenImageCarousel extends StatefulWidget {
  final List<dynamic> imageUrls;
  final int initialIndex;

  const FullscreenImageCarousel({
    Key? key,
    required this.imageUrls,
    required this.initialIndex,
  }) : super(key: key);

  @override
  _FullscreenImageCarouselState createState() =>
      _FullscreenImageCarouselState();
}

class _FullscreenImageCarouselState extends State<FullscreenImageCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  void _nextPage() {
    if (_currentIndex == widget.imageUrls.length - 1) {
      _pageController.jumpToPage(0); // Loop back to the first image
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentIndex == 0) {
      _pageController.jumpToPage(
          widget.imageUrls.length - 1); // Loop back to the last image
    } else {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ]),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: widget.imageUrls[index].url!,
                fit: BoxFit.contain,
                errorWidget: (context, url, error) => ImageFallbackWidget(),
              );
            },
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: _previousPage,
                ),
                Text(
                  '${_currentIndex + 1} / ${widget.imageUrls.length}',
                  style: const TextStyle(color: Colors.white),
                ),
                IconButton(
                  icon:
                      const Icon(Icons.arrow_forward_ios, color: Colors.white),
                  onPressed: _nextPage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
