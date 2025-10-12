import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ItemVideoTile extends StatefulWidget {
  final String videoUrl;
  final String title;
  final bool isActive;

  const ItemVideoTile({
    super.key,
    required this.videoUrl,
    required this.title,
    required this.isActive,
  });

  @override
  State<ItemVideoTile> createState() => _ItemVideoTileState();
}

class _ItemVideoTileState extends State<ItemVideoTile> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        if (mounted) setState(() {});
      });
  }

  @override
  void didUpdateWidget(covariant ItemVideoTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive) {
      _controller?.setLooping(true);
      _controller?.setVolume(0);
      _controller?.play();
    } else {
      _controller?.pause();
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
            width: 160,
            height: 150, // 👈 fixed compact size (same as image)
            child: _controller?.value.isInitialized ?? false
                ? FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: VideoPlayer(_controller!),
              ),
            )
                : Container(color: Colors.black12),
          ),
        ),
        const SizedBox(height: 6),
        Flexible(
          child: Text(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            widget.title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

