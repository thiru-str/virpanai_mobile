import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/ui/widgets/home/basket/basket_shared.dart';

import 'maison_shared.dart';

/// Full-screen viewers the MAISON feed opens: a story viewer (tap right / left,
/// hold to pause, auto-advance) and a vertical reel player (swipe up / down,
/// sound on, "Shop this edit"). Both leave the feed's own players paused.

/// Follows an item's link from inside a viewer: close the viewer first so the
/// destination opens on the feed, not on top of a full-screen player.
void _follow(BuildContext context, Content content, LayoutDatum item) {
  final nav = Navigator.of(context);
  final host = nav.context;
  nav.pop();
  maisonOpenItem(host, content, item);
}

// ── Stories ─────────────────────────────────────────────────────────────────
class MaisonStoryViewer extends StatefulWidget {
  final Content content;
  final List<LayoutDatum> items;
  final int start;
  final MaisonColors colors;
  const MaisonStoryViewer({super.key, required this.content, required this.items, required this.start, required this.colors});

  @override
  State<MaisonStoryViewer> createState() => _MaisonStoryViewerState();
}

class _MaisonStoryViewerState extends State<MaisonStoryViewer> with SingleTickerProviderStateMixin {
  static const _photoTime = Duration(seconds: 5);
  late int _i = widget.start;
  late final AnimationController _clock = AnimationController(vsync: this, duration: _photoTime)
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed) _step(1);
    });
  VideoPlayerController? _video;

  @override
  void initState() {
    super.initState();
    _load();
  }

  LayoutDatum get _item => widget.items[_i];

  Future<void> _load() async {
    _clock.stop();
    final old = _video;
    _video = null;
    await old?.dispose();
    final url = (_item.video ?? '').trim();
    if (url.isEmpty) {
      _clock.duration = _photoTime;
      _clock.forward(from: 0);
      if (mounted) setState(() {});
      return;
    }
    final c = VideoPlayerController.networkUrl(Uri.parse(url.replaceAll(' ', '%20')));
    _video = c;
    if (mounted) setState(() {});
    try {
      await c.initialize();
      if (!mounted || _video != c) return;
      final d = c.value.duration;
      _clock.duration = d.inMilliseconds > 0 ? (d > const Duration(seconds: 15) ? const Duration(seconds: 15) : d) : _photoTime;
      await c.play();
      _clock.forward(from: 0);
      setState(() {});
    } catch (_) {
      _clock.duration = _photoTime;
      _clock.forward(from: 0);
    }
  }

  void _step(int dir) {
    final next = _i + dir;
    if (next < 0) {
      _clock.forward(from: 0);
      _video?.seekTo(Duration.zero);
      return;
    }
    if (next >= widget.items.length) {
      Navigator.of(context).maybePop();
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _i = next);
    _load();
  }

  void _hold(bool on) {
    if (on) {
      _clock.stop();
      _video?.pause();
    } else {
      _clock.forward();
      _video?.play();
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    _video?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final it = _item;
    final v = _video;
    final ready = v != null && v.value.isInitialized;
    final cta = maisonField(it, ['button_text', 'btnText']);
    final pad = MediaQuery.of(context).padding;
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapUp: (d) => _step(d.localPosition.dx < MediaQuery.of(context).size.width * 0.33 ? -1 : 1),
        onLongPressStart: (_) => _hold(true),
        onLongPressEnd: (_) => _hold(false),
        onVerticalDragEnd: (d) {
          if ((d.primaryVelocity ?? 0) > 300) Navigator.of(context).maybePop();
        },
        child: Stack(fit: StackFit.expand, children: [
          BasketImage(url: it.image, fit: BoxFit.cover),
          if (ready) FittedBox(fit: BoxFit.cover, child: SizedBox(width: v.value.size.width, height: v.value.size.height, child: VideoPlayer(v))),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x99000000), Color(0x00000000), Color(0x00000000), Color(0xCC000000)],
                stops: [0, 0.18, 0.55, 1],
              ),
            ),
          ),
          // progress
          Positioned(
            left: 10,
            right: 10,
            top: pad.top + 8,
            child: Row(children: [
              for (var k = 0; k < widget.items.length; k++)
                Expanded(
                  child: Container(
                    height: 2.5,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
                    alignment: Alignment.centerLeft,
                    child: k < _i
                        ? Container(color: Colors.white)
                        : k == _i
                            ? AnimatedBuilder(
                                animation: _clock,
                                builder: (_, __) => FractionallySizedBox(widthFactor: _clock.value.clamp(0.0, 1.0), child: Container(color: Colors.white)),
                              )
                            : null,
                  ),
                ),
            ]),
          ),
          // who + close
          Positioned(
            left: 14,
            right: 6,
            top: pad.top + 20,
            child: Row(children: [
              Container(
                width: 34,
                height: 34,
                padding: const EdgeInsets.all(1.5),
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: widget.colors.metal, width: 1.5)),
                child: ClipOval(child: BasketImage(url: it.image, fit: BoxFit.cover)),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(it.title ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: maisonCaps(Colors.white, size: 11))),
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
              ),
            ]),
          ),
          // caption + CTA
          Positioned(
            left: 22,
            right: 22,
            bottom: pad.bottom + 28,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(it.title ?? '', style: maisonSerif(Colors.white, size: 38)),
              if ((it.subTitle ?? '').isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(it.subTitle!, maxLines: 3, overflow: TextOverflow.ellipsis, style: maisonBody(Colors.white.withValues(alpha: 0.85), size: 14)),
              ],
              const SizedBox(height: 18),
              MaisonPill(
                label: cta.isNotEmpty ? cta : 'Explore',
                fill: widget.colors.metal,
                icon: Icons.arrow_forward_rounded,
                onTap: () => _follow(context, widget.content, it),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ── Reels ───────────────────────────────────────────────────────────────────
class MaisonReelViewer extends StatefulWidget {
  final Content content;
  final List<LayoutDatum> items;
  final int start;
  final MaisonColors colors;
  const MaisonReelViewer({super.key, required this.content, required this.items, required this.start, required this.colors});

  @override
  State<MaisonReelViewer> createState() => _MaisonReelViewerState();
}

class _MaisonReelViewerState extends State<MaisonReelViewer> {
  late final PageController _page = PageController(initialPage: widget.start);
  late int _i = widget.start;
  bool _sound = true;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        PageView.builder(
          controller: _page,
          scrollDirection: Axis.vertical,
          itemCount: widget.items.length,
          onPageChanged: (i) {
            HapticFeedback.selectionClick();
            setState(() => _i = i);
          },
          itemBuilder: (_, i) => _Reel(
            key: ValueKey('reel-$i'),
            item: widget.items[i],
            active: i == _i,
            sound: _sound,
            content: widget.content,
            colors: widget.colors,
          ),
        ),
        Positioned(
          left: 8,
          right: 8,
          top: pad.top + 6,
          child: Row(children: [
            IconButton(onPressed: () => Navigator.of(context).maybePop(), icon: const Icon(Icons.arrow_back_rounded, color: Colors.white)),
            const Spacer(),
            IconButton(
              onPressed: () => setState(() => _sound = !_sound),
              icon: Icon(_sound ? Icons.volume_up_rounded : Icons.volume_off_rounded, color: Colors.white),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _Reel extends StatefulWidget {
  final LayoutDatum item;
  final bool active;
  final bool sound;
  final Content content;
  final MaisonColors colors;
  const _Reel({super.key, required this.item, required this.active, required this.sound, required this.content, required this.colors});

  @override
  State<_Reel> createState() => _ReelState();
}

class _ReelState extends State<_Reel> {
  VideoPlayerController? _c;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    final url = (widget.item.video ?? '').trim();
    if (url.isEmpty) return;
    final c = VideoPlayerController.networkUrl(Uri.parse(url.replaceAll(' ', '%20')));
    _c = c;
    c.setLooping(true);
    c.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
      _sync();
    }).catchError((_) {});
  }

  @override
  void didUpdateWidget(covariant _Reel old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    final c = _c;
    if (c == null || !c.value.isInitialized) return;
    c.setVolume(widget.sound ? 1 : 0);
    (widget.active && !_paused) ? c.play() : c.pause();
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _c;
    final ready = c != null && c.value.isInitialized;
    final it = widget.item;
    final cta = maisonField(it, ['button_text', 'btnText']);
    final pad = MediaQuery.of(context).padding;
    return GestureDetector(
      onTap: () {
        setState(() => _paused = !_paused);
        _sync();
      },
      child: Stack(fit: StackFit.expand, children: [
        if ((it.image ?? '').trim().isNotEmpty) BasketImage(url: it.image, fit: BoxFit.cover),
        if (ready) FittedBox(fit: BoxFit.cover, child: SizedBox(width: c.value.size.width, height: c.value.size.height, child: VideoPlayer(c))),
        if (!ready) const Center(child: SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))),
        if (_paused) const Center(child: Icon(Icons.play_arrow_rounded, size: 72, color: Colors.white70)),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.center, colors: [Color(0xCC000000), Color(0x00000000)]),
          ),
        ),
        Positioned(
          left: 22,
          right: 22,
          bottom: pad.bottom + 30,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(it.title ?? '', style: maisonSerif(Colors.white, size: 36)),
            if ((it.subTitle ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(it.subTitle!, maxLines: 2, overflow: TextOverflow.ellipsis, style: maisonBody(Colors.white.withValues(alpha: 0.85), size: 14)),
            ],
            const SizedBox(height: 16),
            MaisonPill(
              label: cta.isNotEmpty ? cta : 'Shop this edit',
              fill: widget.colors.metal,
              icon: Icons.shopping_bag_outlined,
              onTap: () => _follow(context, widget.content, it),
            ),
          ]),
        ),
        if (ready)
          Positioned(
            left: 0,
            right: 0,
            bottom: pad.bottom,
            child: VideoProgressIndicator(c, allowScrubbing: true, colors: VideoProgressColors(playedColor: widget.colors.metal, bufferedColor: Colors.white24, backgroundColor: Colors.white10)),
          ),
      ]),
    );
  }
}
