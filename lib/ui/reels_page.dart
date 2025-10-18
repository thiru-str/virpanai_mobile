import 'dart:async';
import 'package:flutter/material.dart';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ReelsPage extends StatefulWidget {
  final List<String> hlsUrls;
  final void Function(int index)? onWatched;

  const ReelsPage({super.key, required this.hlsUrls, this.onWatched});

  @override
  State<ReelsPage> createState() => _ReelsPageState();
}

class _ReelsPageState extends State<ReelsPage> with WidgetsBindingObserver {
  final PageController _pageController = PageController();
  final Map<int, BetterPlayerController> _players = {};
  final Map<int, StreamSubscription> _posSubs = {};
  final Map<int, int> _gen = {};          // controller generation per index
  bool _isTrimming = false;               // trimming in progress guard
  int _current = 0;
  bool _isChanging = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ensurePlayer(0, autoplay: true);
    _ensurePlayer(1);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final s in _posSubs.values) {
      s.cancel();
    }
    for (final p in _players.values) {
      p.dispose();
    }
    _posSubs.clear();
    _players.clear();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (s != AppLifecycleState.resumed) {
      _pauseAll();
    } else {
      _players[_current]?.play();
    }
  }

  void _bumpGen(int index) => _gen[index] = (_gen[index] ?? 0) + 1;

  void _ensurePlayer(int index, {bool autoplay = false}) {
    if (index < 0 || index >= widget.hlsUrls.length) return;
    if (_players[index] != null) return;
    _bumpGen(index); // 🔵 new generation
    _players[index] = _createController(index, widget.hlsUrls[index], autoplay: autoplay);
  }

  void _disposeIndex(int index) {
    _isTrimming = true;
    _posSubs[index]?.cancel();
    _posSubs.remove(index);
    final c = _players[index];
    if (c != null) {
      try { c.pause(); c.dispose(); } catch (_) {}
      _players.remove(index);
    }
    _bumpGen(index); // 🔵 invalidate any pending callbacks
    if (mounted) setState(() {});
    _isTrimming = false;
  }

  Future<void> _safePlay(int index) async {
    final c = _players[index];
    if (c == null) return;
    try {
      final vp = await c.videoPlayerController;
      if (vp == null) return;
      // try reading value; will throw if disposed
      final _ = vp.value;
      if (!_.initialized) return;
      if (!_.isPlaying) await c.play();
    } catch (_) {
      // controller was disposed between checks — ignore
    }
  }

  Future<void> _safePause(int index) async {
    final c = _players[index];
    if (c == null) return;
    try {
      final vp = await c.videoPlayerController;
      if (vp == null) return;
      final _ = vp.value;
      if (_.isPlaying) await c.pause();
    } catch (_) {/* ignore */}
  }



  void _trimPlayers() {
    for (final k in _players.keys.toList()) {
      if (k != _current && k != _current + 1) _disposeIndex(k);
    }
  }

  void _pauseAll() {
    for (final p in _players.values) {
      p.pause();
    }
  }

  void _onPageChanged(int index) {
    _isChanging = true;
    _current = index;

    // pause everyone safely
    for (final k in _players.keys) { _safePause(k); }

    _ensurePlayer(index, autoplay: true);
    _ensurePlayer(index + 1);

    _trimPlayers();

    // capture generation snapshot for this index
    final g = _gen[index] ?? 0;
    Future.delayed(const Duration(milliseconds: 250), () {
      // only act if this controller is still the same generation and current
      if (!_isChanging && _current == index && (_gen[index] ?? -1) == g) {
        _safePlay(index);
      }
    });

    setState(() {});
    _isChanging = false;
  }



  BetterPlayerController _createController(int index, String url,
      {bool autoplay = false}) {
    const reelAspect = 9 / 16;

    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      url,
      useAsmsTracks: true,
      useAsmsSubtitles: true,
      useAsmsAudioTracks: true,
      headers: const {"User-Agent": "ExoPlayer (Android) BetterPlayerPlus"},
      bufferingConfiguration: const BetterPlayerBufferingConfiguration(
        minBufferMs: 1500,
        maxBufferMs: 6000,
        bufferForPlaybackMs: 500,
        bufferForPlaybackAfterRebufferMs: 1200,
      ),
    );

    const config = BetterPlayerConfiguration(
      aspectRatio: reelAspect,
      fit: BoxFit.contain,
      autoPlay: false,
      looping: true,
      handleLifecycle: true,
      controlsConfiguration:
          BetterPlayerControlsConfiguration(showControls: false),
    );

    final ctrl =
        BetterPlayerController(config, betterPlayerDataSource: dataSource);
    if (autoplay) {
      WidgetsBinding.instance.addPostFrameCallback((_) => ctrl.play());
    }

    return ctrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text("Reels", style: TextStyle(color: Colors.white)),
        centerTitle: false,
      ),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.hlsUrls.length,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          final player = _players[index];

          return VisibilityDetector(
            key: Key('reel_$index'),
            onVisibilityChanged: (info) {
              if (_isChanging || _isTrimming) return;
              // only interact if this index still has a live controller
              if (!_players.containsKey(index)) return;

              final visible = info.visibleFraction > 0.6 && index == _current;
              final g = _gen[index] ?? 0;

              // schedule on microtask so we run after any in-flight disposals
              Future.microtask(() {
                if (!_players.containsKey(index)) return;
                if ((_gen[index] ?? -1) != g) return; // controller changed meanwhile
                visible ? _safePlay(index) : _safePause(index);
              });
            },

            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: Colors.black),


                Center(
                  child: AspectRatio(
                    aspectRatio: 9 / 16,
                    child: player != null
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              GestureDetector(
                                  onDoubleTap: () => _toggleLike(index),
                                  behavior: HitTestBehavior.opaque,
                                  child: BetterPlayer(controller: player)),
                              _BufferingOverlay(controller: player),
                            ],
                          )
                        : const Center(
                            child:
                                CircularProgressIndicator(color: Colors.white)),
                  ),
                ),

                Positioned(
                  right: 12,
                  bottom: 110,
                  child: _RightRailControls(
                    index: index,
                    liked: _liked.contains(index),
                    likeCount: _likeCounts[index] ?? 0,
                    commentCount: _commentCounts[index] ?? 0,
                    muted: _muted[index] ?? false,
                    onLike: () => _toggleLike(index),
                    onComment: () {
                      // TODO: open your comments bottom sheet / page
                      debugPrint('Open comments for $index');
                    },
                    onShare: () {
                      // TODO: share sheet
                      debugPrint('Share reel $index');
                    },
                    onMute: () => _toggleMute(index),
                  ),
                ),


                // CTA
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 36,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'Shop Now',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),


                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 16,
                  child: _ReelScrubber(controller: player),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // per-reel UI state
  final Set<int> _liked = {};
  final Map<int, int> _likeCounts = {};
  final Map<int, int> _commentCounts = {};
  final Map<int, bool> _muted = {}; // true => muted

  void _toggleLike(int index) {
    setState(() {
      final wasLiked = _liked.contains(index);
      if (wasLiked) {
        _liked.remove(index);
        _likeCounts[index] = (_likeCounts[index] ?? 0) - 1;
      } else {
        _liked.add(index);
        _likeCounts[index] = (_likeCounts[index] ?? 0) + 1;
      }
    });
  }

  Future<void> _toggleMute(int index) async {
    final ctrl = _players[index];
    if (ctrl == null) return;
    final nowMuted = !(_muted[index] ?? false);
    _muted[index] = nowMuted;
    final vp = await ctrl.videoPlayerController;
    if (vp != null) {
      await vp.setVolume(nowMuted ? 0.0 : 1.0);
    }
    setState(() {});
  }

}

class _BufferingOverlay extends StatefulWidget {
  final BetterPlayerController controller;
  const _BufferingOverlay({required this.controller});

  @override
  State<_BufferingOverlay> createState() => _BufferingOverlayState();
}

class _BufferingOverlayState extends State<_BufferingOverlay> {
  bool _isBuffering = false;
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    _poll = Timer.periodic(const Duration(milliseconds: 300), (_) async {
      final vp = await widget.controller.videoPlayerController;
      if (!mounted) return;
      if (vp == null) {
        if (_isBuffering) setState(() => _isBuffering = false);
        return;
      }
      try {
        final v = vp.value;
        final next = v.initialized && v.isBuffering;
        if (next != _isBuffering) setState(() => _isBuffering = next);
      } catch (_) {
        // controller disposed while polling -> stop showing spinner
        if (_isBuffering) setState(() => _isBuffering = false);
      }
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isBuffering) return const SizedBox.shrink();
    return const Center(
      child: SizedBox(
        width: 36, height: 36,
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
      ),
    );
  }
}


class _ReelScrubber extends StatefulWidget {
  final BetterPlayerController? controller;
  const _ReelScrubber({this.controller});

  @override
  State<_ReelScrubber> createState() => _ReelScrubberState();
}

class _ReelScrubberState extends State<_ReelScrubber> {
  Timer? _t;
  double _played = 0.0;
  double _buffered = 0.0;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(milliseconds: 250), (_) async {
      final ctrl = widget.controller;
      if (ctrl == null || !mounted) return;
      final vp = await ctrl.videoPlayerController;
      if (vp == null) return;

      try {
        final v = vp.value;
        if (!v.initialized) return;

        final dMs = v.duration?.inMilliseconds??0.toDouble();
        if (dMs <= 0) return;
        final pMs = v.position.inMilliseconds.toDouble();

        double buf = 0;
        if (v.buffered.isNotEmpty) {
          buf = v.buffered.last.end.inMilliseconds / dMs;
        }

        if (!mounted) return;
        setState(() {
          _duration = v.duration!;
          _played = (pMs / dMs).clamp(0, 1);
          _buffered = buf.clamp(0, 1);
        });
      } catch (_) {
        // disposed during poll; clear UI
        if (!mounted) return;
        setState(() {
          _played = 0;
          _buffered = 0;
          _duration = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  Future<void> _seekToFraction(double frac) async {
    final ctrl = widget.controller;
    if (ctrl == null) return;
    final vp = await ctrl.videoPlayerController;
    if (vp == null) return;
    try {
      final d = _duration.inMilliseconds;
      if (d <= 0) return;
      final targetMs = (d * frac).clamp(0, d).toInt();
      await vp.seekTo(Duration(milliseconds: targetMs));
      if (!vp.value.isPlaying) {
        await ctrl.play();
      }
    } catch (_) {
      // ignore if disposed during seek
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller == null) return const SizedBox.shrink();

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (d) {
        final box = context.findRenderObject() as RenderBox?;
        if (box == null) return;
        final local = box.globalToLocal(d.globalPosition);
        final w = box.size.width;
        if (w > 0) _seekToFraction((local.dx / w).clamp(0.0, 1.0));
      },
      child: SizedBox(
        height: 12,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(height: 3, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2))),
            FractionallySizedBox(
              widthFactor: _buffered,
              child: Container(height: 3, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(2))),
            ),
            FractionallySizedBox(
              widthFactor: _played,
              child: Container(height: 3, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2))),
            ),
          ],
        ),
      ),
    );
  }
}



class _RightRailControls extends StatelessWidget {
  final int index;
  final bool liked;
  final int likeCount;
  final int commentCount;
  final bool muted;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onMute;

  const _RightRailControls({
    required this.index,
    required this.liked,
    required this.likeCount,
    required this.commentCount,
    required this.muted,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onMute,
  });

  String _shortNum(int n) {
    if (n >= 1000000) return "${(n / 1000000).toStringAsFixed(n % 1000000 == 0 ? 0 : 1)}M";
    if (n >= 1000) return "${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}K";
    return "$n";
  }

  @override
  Widget build(BuildContext context) {
    const iconSize = 28.0;
    const gap = 18.0;

    Widget item({required Widget icon, String? label, required VoidCallback onTap}) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            if (label != null) ...[
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        item(
          onTap: onLike,
          label: _shortNum(likeCount),
          icon: AnimatedScale(
            duration: const Duration(milliseconds: 150),
            scale: liked ? 1.15 : 1.0,
            child: Icon(
              liked ? Icons.favorite : Icons.favorite_border,
              color: liked ? Colors.redAccent : Colors.white,
              size: iconSize,
            ),
          ),
        ),
        const SizedBox(height: gap),
        item(
          onTap: onComment,
          label: _shortNum(commentCount),
          icon: const Icon(Icons.mode_comment_outlined, color: Colors.white, size: iconSize),
        ),
        const SizedBox(height: gap),
        item(
          onTap: onShare,
          label: "Share",
          icon: const Icon(Icons.ios_share, color: Colors.white, size: iconSize),
        ),
        const SizedBox(height: gap),
        item(
          onTap: onMute,
          label: muted ? "Muted" : "Sound",
          icon: Icon(muted ? Icons.volume_off : Icons.volume_up,
              color: Colors.white, size: iconSize),
        ),
      ],
    );
  }
}



