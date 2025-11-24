import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:waioz/utility/image_fallback_widget.dart';

class FullscreenImageCarousel extends StatefulWidget {
  final List<dynamic> imageUrls;
  final int initialIndex;
  final Map<String, File?>? videoThumbnails;

  const FullscreenImageCarousel({
    Key? key,
    required this.imageUrls,
    required this.initialIndex,
    this.videoThumbnails,
  }) : super(key: key);

  @override
  _FullscreenImageCarouselState createState() =>
      _FullscreenImageCarouselState();
}

class _FullscreenImageCarouselState extends State<FullscreenImageCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;
  final Map<String, VideoPlayerController> _videoControllers = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);

    for (final url in widget.imageUrls) {
      if (url.toLowerCase().endsWith('.mp4')) {
        final controller = VideoPlayerController.network(url)
          ..initialize().then((_) {
            setState(() {});
          });
        _videoControllers[url] = controller;
      }
    }
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
  void dispose() {
    for (final controller in _videoControllers.values) {
      controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
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

              // Pause all other videos
              for (final controller in _videoControllers.values) {
                if (controller.value.isPlaying) controller.pause();
              }

              final url = widget.imageUrls[index];
              if (url.toLowerCase().endsWith('.mp4')) {
                final controller = _videoControllers[url];
                controller?.play();
              }
            },
            itemBuilder: (context, index) {
              final url = widget.imageUrls[index];
              final isVideo = url.toLowerCase().endsWith('.mp4');

              if (isVideo) {
                final controller = _videoControllers[url];
                final thumbnailFile = widget.videoThumbnails?[url];

                if (controller == null || !controller.value.isInitialized) {
                  // Show thumbnail or loading spinner while initializing
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      if (thumbnailFile != null)
                        Image.file(thumbnailFile, fit: BoxFit.contain)
                      else
                        const Center(child: CircularProgressIndicator()),
                      const Icon(Icons.play_circle_fill, size: 80, color: Colors.white),
                    ],
                  );
                }

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (controller.value.isPlaying) {
                        controller.pause();
                      } else {
                        controller.play();
                      }
                    });
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: controller.value.aspectRatio,
                        child: VideoPlayer(controller),
                      ),
                      if (!controller.value.isPlaying)
                        const Icon(Icons.play_circle_fill, size: 80, color: Colors.white),
                    ],
                  ),
                );
              }


              return InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0,
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.contain,
                  errorWidget: (_, __, ___) => const ImageFallbackWidget(),
                ),
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
