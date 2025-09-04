import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:waioz/utility/image_fallback_widget.dart';

class ItemVideoTile extends StatefulWidget {
  final String? videoUrl;
  final String? title;

  const ItemVideoTile({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  @override
  State<ItemVideoTile> createState() => _ItemVideoTileState();
}

class _ItemVideoTileState extends State<ItemVideoTile> {
  VideoPlayerController? _controller;

  // @override
  // void initState() {
  //   super.initState();
  //   _controller = VideoPlayerController.network(widget.videoUrl)
  //     ..initialize().then((_) {
  //       setState(() {});
  //       _controller.setLooping(true);
  //       _controller.setVolume(0);
  //       _controller.play(); // 🔁 Always autoplay
  //     });
  // }
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
      _controller = VideoPlayerController.network(widget.videoUrl!)
        ..initialize().then((_) {
          if (!mounted) return;
          setState(() {});
          _controller!
            ..setLooping(true)
            ..setVolume(0)
            ..play();
        }).catchError((error) {
          setState(() {
            _isError = true;
          });
        });
    } else {
      _isError = true;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 150,
            height: 150,
            // child: _controller.value.isInitialized
            //     ? VideoPlayer(_controller)
            //     : Container(color: Colors.black12),
            child: _isError
                ? ImageFallbackWidget(h: 120) // fallback widget
                : (_controller != null && _controller!.value.isInitialized
                    ? VideoPlayer(_controller!)
                    : Container(color: Colors.black12)),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          widget.title ?? "",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
