import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../utility/font_utils.dart';

class ItemVideoTile extends StatefulWidget {
  final String videoUrl;
  final String title;
  final bool isActive;
  final bool isMuted;
  final VoidCallback onMute;
  final VoidCallback? onTap;
  final String? redirectLabel;
  final VoidCallback onCompleted;
  final ValueChanged<bool> onFullscreenChanged;

  const ItemVideoTile({
    super.key,
    required this.videoUrl,
    required this.title,
    required this.isActive,
    required this.isMuted,
    required this.onMute,
    required this.onTap,
    this.redirectLabel,
    required this.onCompleted,
    required this.onFullscreenChanged,
  });

  @override
  State<ItemVideoTile> createState() => ItemVideoTileState();
}

class ItemVideoTileState extends State<ItemVideoTile>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  Future<void>? _releaseFuture;
  bool _fullscreen = false;
  bool _openingDetails = false;
  bool _appActive = true;
  bool _completed = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.isActive) unawaited(_initialize());
  }

  Future<void> _initialize() async {
    await _releaseFuture;
    if (!mounted ||
        !widget.isActive ||
        _openingDetails ||
        _controller != null) {
      return;
    }
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl.trim().replaceAll(' ', '%20')),
    );
    _controller = controller;
    _completed = false;
    _hasError = false;
    controller.addListener(_onVideoChanged);
    try {
      await controller.initialize();
      if (!mounted || _controller != controller) return;
      await controller.setLooping(false);
      if (!mounted || _controller != controller) return;
      await controller.setVolume(widget.isMuted ? 0 : 1);
      if (!mounted || _controller != controller) return;
      if (widget.isActive && _appActive && !_openingDetails) {
        await controller.play();
      }
      if (mounted && _controller == controller) setState(() {});
    } catch (_) {
      if (mounted && _controller == controller) {
        setState(() => _hasError = true);
      }
    }
  }

  void _onVideoChanged() {
    final value = _controller?.value;
    if (value == null || !mounted) return;
    if (value.hasError && !_hasError) {
      setState(() => _hasError = true);
    }
    if (!value.isInitialized || _fullscreen || !widget.isActive || _completed) {
      return;
    }
    if (value.duration > Duration.zero && value.position >= value.duration) {
      _completed = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.isActive && !_fullscreen && !_openingDetails) {
          widget.onCompleted();
        }
      });
      WidgetsBinding.instance.ensureVisualUpdate();
    }
  }

  Future<void> pauseAndRelease() {
    final controller = _controller;
    _controller = null;
    if (controller == null) return _releaseFuture ?? Future<void>.value();
    controller.removeListener(_onVideoChanged);
    return _releaseFuture = _release(controller);
  }

  Future<void> _release(VideoPlayerController controller) async {
    await Future<void>.value();
    try {
      await controller.pause();
    } finally {
      await controller.dispose();
    }
  }

  @override
  void didUpdateWidget(covariant ItemVideoTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive) _openingDetails = false;
    if (oldWidget.videoUrl != widget.videoUrl) {
      unawaited(pauseAndRelease().then((_) => _initialize()));
    } else if (!widget.isActive && !_fullscreen) {
      unawaited(Future<void>.microtask(() async {
        if (mounted && !widget.isActive && !_fullscreen) {
          await _controller?.pause();
        }
      }));
    } else if (widget.isActive && _controller == null && !_openingDetails) {
      unawaited(_initialize());
    } else if (!oldWidget.isActive && widget.isActive && _appActive) {
      unawaited(Future<void>.microtask(() async {
        if (mounted && widget.isActive && !_openingDetails) {
          await _controller?.play();
        }
      }));
    }
    if (oldWidget.isMuted != widget.isMuted) {
      unawaited(Future<void>.microtask(() async {
        if (mounted) await _controller?.setVolume(widget.isMuted ? 0 : 1);
      }));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appActive = state == AppLifecycleState.resumed;
    if (!_appActive) {
      unawaited(_controller?.pause());
    } else if ((widget.isActive || _fullscreen) && !_openingDetails) {
      unawaited(_controller?.play());
    }
  }

  Future<void> _openDetails() async {
    if (_openingDetails || widget.onTap == null) return;
    _openingDetails = true;
    await pauseAndRelease();
    if (mounted) widget.onTap?.call();
  }

  Future<void> _openFullscreen() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _fullscreen) {
      return;
    }
    _fullscreen = true;
    widget.onFullscreenChanged(true);
    await controller.setLooping(true);
    if (!mounted) return;
    // Reuse the inline controller so fullscreen keeps the playback position.
    final openDetails = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _FullscreenVideoPage(
          controller: controller,
          title: widget.title,
          onMute: widget.onMute,
          redirectLabel: widget.redirectLabel,
          canRedirect: widget.onTap != null,
        ),
      ),
    );
    if (!mounted) return;
    _fullscreen = false;
    if (openDetails == true) _openingDetails = true;
    widget.onFullscreenChanged(false);
    if (openDetails == true) {
      await pauseAndRelease();
      if (mounted) widget.onTap?.call();
    } else {
      await controller.setLooping(false);
      _completed = false;
      if (widget.isActive && _appActive) {
        await controller.play();
      } else {
        await controller.pause();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(pauseAndRelease());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: widget.onTap == null ? null : _openDetails,
            child: ColoredBox(
              color: Colors.black,
              child: _hasError
                  ? Center(
                      child: IconButton(
                        tooltip: 'Retry video',
                        color: Colors.white,
                        icon: const Icon(Icons.refresh),
                        onPressed: () async {
                          await pauseAndRelease();
                          if (mounted) {
                            setState(() => _hasError = false);
                            await _initialize();
                          }
                        },
                      ),
                    )
                  : controller?.value.isInitialized == true
                      ? Center(
                          child: AspectRatio(
                            aspectRatio: controller!.value.aspectRatio,
                            child: VideoPlayer(controller),
                          ),
                        )
                      : widget.isActive && !_openingDetails
                          ? const Center(child: CircularProgressIndicator())
                          : const SizedBox.shrink(),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _VideoControl(
                  tooltip: widget.isMuted ? 'Unmute' : 'Mute',
                  icon: widget.isMuted ? Icons.volume_off : Icons.volume_up,
                  onPressed: widget.onMute,
                ),
                const SizedBox(width: 8),
                _VideoControl(
                  tooltip: 'Fullscreen',
                  icon: Icons.fullscreen,
                  onPressed: controller?.value.isInitialized == true
                      ? _openFullscreen
                      : null,
                ),
              ],
            ),
          ),
          if (widget.redirectLabel != null && widget.onTap != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 12,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Material(
                  color: Colors.black54,
                  child: VideoRedirectLink(
                    label: widget.redirectLabel!,
                    color: Colors.white,
                    onTap: _openDetails,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FullscreenVideoPage extends StatelessWidget {
  final VideoPlayerController controller;
  final String title;
  final VoidCallback onMute;
  final String? redirectLabel;
  final bool canRedirect;

  const _FullscreenVideoPage({
    required this.controller,
    required this.title,
    required this.onMute,
    required this.redirectLabel,
    required this.canRedirect,
  });

  Future<void> _openDestination(BuildContext context) async {
    await controller.pause();
    if (context.mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ValueListenableBuilder<VideoPlayerValue>(
          valueListenable: controller,
          builder: (context, value, _) => Stack(
            fit: StackFit.expand,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: canRedirect ? () => _openDestination(context) : null,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: value.aspectRatio,
                    child: VideoPlayer(controller),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                right: 8,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    _VideoControl(
                      tooltip: 'Close fullscreen',
                      icon: Icons.close,
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    _VideoControl(
                      tooltip: value.isPlaying ? 'Pause' : 'Play',
                      icon: value.isPlaying ? Icons.pause : Icons.play_arrow,
                      onPressed: () => value.isPlaying
                          ? controller.pause()
                          : controller.play(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: VideoProgressIndicator(
                        controller,
                        allowScrubbing: true,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _VideoControl(
                      tooltip: value.volume == 0 ? 'Unmute' : 'Mute',
                      icon: value.volume == 0
                          ? Icons.volume_off
                          : Icons.volume_up,
                      onPressed: onMute,
                    ),
                  ],
                ),
              ),
              if (canRedirect && redirectLabel != null)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 80,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Material(
                      color: Colors.black54,
                      child: VideoRedirectLink(
                        label: redirectLabel!,
                        color: Colors.white,
                        onTap: () => _openDestination(context),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class VideoRedirectLink extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const VideoRedirectLink({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      link: true,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: color,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          shape: const RoundedRectangleBorder(),
        ),
        child: Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: FontUtils.primaryFontStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}

class _VideoControl extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  const _VideoControl({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon),
        color: Colors.white,
        disabledColor: Colors.white38,
        constraints: const BoxConstraints.tightFor(width: 48, height: 48),
      ),
    );
  }
}
