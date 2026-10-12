import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player/video_player.dart';
// The fake uses the platform interface bundled with video_player.
// ignore: depend_on_referenced_packages
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/ui/widgets/home/banner_2.dart';
import 'package:waioz/ui/widgets/item_video_tile.dart';
import 'package:waioz/utility/app_strings.dart';

class _FakeVideoPlatform extends VideoPlayerPlatform {
  final Map<int, StreamController<VideoEvent>> streams = {};
  final Map<int, Duration> positions = {};
  final Map<int, double> volumes = {};
  final Map<int, bool> looping = {};
  final Set<int> playing = {};
  final List<int> disposed = [];
  final List<String> sources = [];
  int nextId = 0;
  bool delayInitialization = false;

  @override
  Future<void> init() async {}

  @override
  Future<int?> createWithOptions(VideoCreationOptions options) async {
    final id = nextId++;
    sources.add(options.dataSource.uri!);
    streams[id] = StreamController<VideoEvent>();
    if (!delayInitialization) initialize(id);
    return id;
  }

  void initialize(int id) {
    streams[id]!.add(VideoEvent(
      eventType: VideoEventType.initialized,
      size: const Size(1080, 1920),
      duration: const Duration(seconds: 10),
    ));
  }

  void complete(int id) {
    positions[id] = const Duration(seconds: 10);
    streams[id]!.add(VideoEvent(eventType: VideoEventType.completed));
  }

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) => streams[playerId]!.stream;

  @override
  Future<void> dispose(int playerId) async {
    playing.remove(playerId);
    disposed.add(playerId);
    await streams[playerId]!.close();
  }

  @override
  Future<void> play(int playerId) async => playing.add(playerId);

  @override
  Future<void> pause(int playerId) async => playing.remove(playerId);

  @override
  Future<void> setVolume(int playerId, double volume) async {
    volumes[playerId] = volume;
  }

  @override
  Future<void> setLooping(int playerId, bool isLooping) async {
    looping[playerId] = isLooping;
  }

  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) async {}

  @override
  Future<void> seekTo(int playerId, Duration position) async {
    positions[playerId] = position;
  }

  @override
  Future<Duration> getPosition(int playerId) async =>
      positions[playerId] ?? Duration.zero;

  @override
  Widget buildViewWithOptions(VideoViewOptions options) => ColoredBox(
      key: ValueKey('video-${options.playerId}'), color: Colors.green);
}

void main() {
  late _FakeVideoPlatform platform;

  setUp(() {
    platform = _FakeVideoPlatform();
    VideoPlayerPlatform.instance = platform;
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  Future<void> pumpBanner(WidgetTester tester,
      {int count = 2, Content? content}) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Banner2(
                content: content ??
                    Content(
                      layoutTitle: 'HAKA videos',
                      layoutData: [
                        for (int i = 0; i < count; i++)
                          LayoutDatum(
                            id: '$i',
                            image: 'https://example.com/$i.mp4?token=test',
                            title: 'Video $i',
                          ),
                      ],
                    ),
              ),
              const SizedBox(height: 1000),
            ],
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
  }

  Future<void> cleanUp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
  }

  Future<void> finishTransition(WidgetTester tester) async {
    await tester.pump();
    // Stream subscription cancellation completes outside Flutter's fake clock.
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
  }

  testWidgets('one visible video starts unmuted and finishes before advancing',
      (tester) async {
    await pumpBanner(tester);
    expect(platform.sources, hasLength(1));
    expect(platform.playing, {0});
    expect(platform.volumes[0], 1);
    expect(platform.looping[0], false);
    final pageView = tester.widget<PageView>(find.byType(PageView));
    expect(pageView.controller!.viewportFraction, 1);
    final firstDot = tester.getCenter(find.byTooltip('Show video 1'));
    final secondDot = tester.getCenter(find.byTooltip('Show video 2'));
    expect(secondDot.dx - firstDot.dx, 16);
    expect(tester.getSize(find.byType(PageView)).height,
        inInclusiveRange(380, 480));
    await tester.pump(const Duration(seconds: 6));
    expect(platform.sources, hasLength(1));
    platform.complete(0);
    await tester.pump();
    await finishTransition(tester);
    expect(platform.disposed, contains(0));
    expect(platform.playing, {1});
    expect(platform.sources.last, contains('1.mp4'));
    expect(find.text('Video 1'), findsOneWidget);
    await cleanUp(tester);
  });

  testWidgets('dots switch videos and mute choice carries to the next video',
      (tester) async {
    await pumpBanner(tester);
    await tester.tap(find.byTooltip('Mute'));
    await tester.pump();
    expect(platform.volumes[0], 0);
    await tester.tap(find.byTooltip('Show video 2'));
    await finishTransition(tester);
    expect(platform.playing, {1});
    expect(platform.volumes[1], 0);
    await cleanUp(tester);
  });

  testWidgets(
      'fullscreen reuses playback, supports mute, and returns to banner',
      (tester) async {
    await pumpBanner(tester);
    platform.positions[0] = const Duration(seconds: 3);
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(find.byTooltip('Fullscreen'));
    await tester.pumpAndSettle();
    expect(platform.sources, hasLength(1));
    expect(platform.playing, {0});
    expect(platform.looping[0], true);
    final fullscreenVideo =
        tester.widget<VideoPlayer>(find.byType(VideoPlayer));
    expect(
        fullscreenVideo.controller.value.position, const Duration(seconds: 3));
    await tester.tap(find.byTooltip('Mute'));
    await tester.pump();
    expect(platform.volumes[0], 0);
    await tester.tap(find.byTooltip('Pause'));
    await tester.pump();
    expect(platform.playing, isEmpty);
    await tester.tap(find.byTooltip('Play'));
    await tester.pump();
    expect(platform.playing, {0});
    await tester.tap(find.byTooltip('Close fullscreen'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Fullscreen'), findsOneWidget);
    expect(platform.sources, hasLength(1));
    expect(platform.looping[0], false);
    expect(platform.playing, {0});
    await cleanUp(tester);
  });

  testWidgets('fullscreen video tap closes player before detail callback',
      (tester) async {
    bool openedDetails = false;
    bool fullscreen = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          height: 420,
          child: ItemVideoTile(
            videoUrl: 'https://example.com/video.mp4',
            title: 'Video',
            isActive: true,
            isMuted: true,
            onMute: () {},
            onCompleted: () {},
            onFullscreenChanged: (value) => fullscreen = value,
            onTap: () {
              expect(fullscreen, false);
              expect(platform.playing, isEmpty);
              expect(platform.disposed, [0]);
              openedDetails = true;
            },
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.byTooltip('Fullscreen'));
    await tester.pumpAndSettle();
    await tester.tapAt(tester.getCenter(find.byType(VideoPlayer)));
    await finishTransition(tester);
    await tester.pumpAndSettle();
    expect(openedDetails, true);
    expect(find.byTooltip('Close fullscreen'), findsNothing);
    await cleanUp(tester);
  });

  testWidgets('offscreen and backgrounded videos release or pause playback',
      (tester) async {
    await pumpBanner(tester);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    expect(platform.playing, isEmpty);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await finishTransition(tester);
    expect(platform.playing, hasLength(1));
    await cleanUp(tester);
    expect(platform.playing, isEmpty);
  });

  testWidgets('a single video replays after completion', (tester) async {
    await pumpBanner(tester, count: 1);
    platform.complete(0);
    await tester.pump();
    await finishTransition(tester);
    expect(platform.sources, hasLength(2));
    expect(platform.disposed, [0]);
    expect(platform.playing, {1});
    await cleanUp(tester);
  });

  testWidgets('swiping and scrolling away never leave hidden audio playing',
      (tester) async {
    await pumpBanner(tester);
    await tester.drag(find.byType(PageView), const Offset(-600, 0));
    await finishTransition(tester);
    expect(platform.disposed, contains(0));
    expect(platform.playing, {1});
    await tester.drag(
        find.byType(SingleChildScrollView).first, const Offset(0, -700));
    await finishTransition(tester);
    expect(platform.playing, isEmpty);
    await tester.drag(
        find.byType(SingleChildScrollView).first, const Offset(0, 700));
    await finishTransition(tester);
    expect(platform.playing, {1});
    await cleanUp(tester);
  });

  testWidgets('covering the banner pauses it and returning resumes it',
      (tester) async {
    await pumpBanner(tester);
    final navigator = Navigator.of(tester.element(find.byType(Banner2)));
    unawaited(navigator.push(MaterialPageRoute<void>(
      builder: (_) => const Scaffold(body: Text('Details')),
    )));
    await finishTransition(tester);
    expect(platform.playing, isEmpty);
    navigator.pop();
    await finishTransition(tester);
    expect(platform.playing, {0});
    expect(platform.sources, hasLength(1));
    await cleanUp(tester);
  });

  testWidgets('fullscreen stops in the background and resumes on return',
      (tester) async {
    await pumpBanner(tester);
    await tester.tap(find.byTooltip('Fullscreen'));
    await tester.pumpAndSettle();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(platform.playing, isEmpty);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(platform.playing, {0});
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byTooltip('Fullscreen'), findsOneWidget);
    expect(platform.playing, {0});
    await cleanUp(tester);
  });

  for (final size in [const Size(320, 568), const Size(430, 932)]) {
    testWidgets('video and controls fit a ${size.width} wide phone',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await pumpBanner(tester, count: 8);
      expect(tester.takeException(), isNull);
      final frame = tester.getRect(find.byType(PageView));
      expect(frame.left, 0);
      expect(frame.right, size.width);
      expect(
          find.descendant(
              of: find.byType(ItemVideoTile), matching: find.byType(ClipRRect)),
          findsNothing);
      expect(tester.getRect(find.byTooltip('Fullscreen')).right,
          lessThanOrEqualTo(size.width));
      expect(tester.getRect(find.byTooltip('Show video 1')).bottom,
          lessThanOrEqualTo(size.height));
      await tester.tap(find.byTooltip('Fullscreen'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(tester.getRect(find.byTooltip('Close fullscreen')).right,
          lessThanOrEqualTo(size.width));
      await tester.tap(find.byTooltip('Close fullscreen'));
      await tester.pumpAndSettle();
      await cleanUp(tester);
    });
  }

  Content linkedContent(
          {String? option, RedirectData? data, RedirectData? sectionData}) =>
      Content(
        layoutOption: option,
        redirectData: sectionData,
        layoutData: [
          LayoutDatum(
            id: 'product-1',
            image: 'https://example.com/video.mp4',
            redirectData: data,
          ),
        ],
      );

  final destinations = [
    (option: AppStrings.product, data: null, label: 'View product'),
    (option: AppStrings.category, data: null, label: 'View category'),
    (option: AppStrings.brand, data: null, label: 'View brand'),
    (
      option: AppStrings.custom,
      data: RedirectData(
          redirectType: AppStrings.reDirectProduct,
          redirectProductData: RedirectProductData(productId: 'product-2')),
      label: 'View product'
    ),
    (
      option: AppStrings.custom,
      data: RedirectData(
          redirectType: AppStrings.reDirectPage,
          redirectPageData: RedirectPageData(slug: 'offers')),
      label: 'View page'
    ),
    (
      option: AppStrings.custom,
      data: RedirectData(
          redirectType: AppStrings.reDirectOrder,
          redirectOrderData: RedirectOrderData(orderId: 'order-1')),
      label: 'View order'
    ),
    (
      option: AppStrings.custom,
      data: RedirectData(
          redirectType: AppStrings.reDirectSearch,
          redirectSearchData: RedirectSearchData(category: 'category-1')),
      label: 'View products'
    ),
    (
      option: AppStrings.custom,
      data: RedirectData(
          redirectType: AppStrings.reDirectLink,
          redirectUrlData: RedirectUrlData(url: 'https://example.com/offers')),
      label: 'Open link'
    ),
  ];
  for (final destination in destinations) {
    testWidgets(
        '${destination.label} appears only inside media for ${destination.option}/${destination.data?.redirectType}',
        (tester) async {
      await pumpBanner(tester,
          content: linkedContent(
              option: destination.option, data: destination.data));
      expect(find.text(destination.label), findsOneWidget);
      expect(
          tester
              .widget<VideoRedirectLink>(find.byType(VideoRedirectLink).first)
              .color,
          Colors.white);
      await tester.tap(find.byTooltip('Fullscreen'));
      await tester.pumpAndSettle();
      expect(find.text(destination.label), findsOneWidget);
      await tester.tap(find.byTooltip('Close fullscreen'));
      await tester.pumpAndSettle();
      await cleanUp(tester);
    });
  }

  testWidgets('no destination hides links and video taps keep playing',
      (tester) async {
    await pumpBanner(tester);
    expect(find.byType(VideoRedirectLink), findsNothing);
    await tester.tap(find.byType(VideoPlayer));
    await tester.pump();
    expect(platform.playing, {0});
    await tester.tap(find.byTooltip('Fullscreen'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(VideoPlayer));
    await tester.pump();
    expect(find.byTooltip('Close fullscreen'), findsOneWidget);
    expect(platform.playing, {0});
    await tester.tap(find.byTooltip('Close fullscreen'));
    await tester.pumpAndSettle();
    await cleanUp(tester);
  });

  testWidgets('section redirect supplies a default hyperlink label',
      (tester) async {
    await pumpBanner(tester,
        content: linkedContent(
          sectionData: RedirectData(
              redirectType: AppStrings.reDirectLink,
              redirectUrlData:
                  RedirectUrlData(url: 'https://example.com/offers')),
        ));
    expect(find.text('Open link'), findsNWidgets(2));
    await cleanUp(tester);
  });

  for (final location in ['inside', 'fullscreen']) {
    testWidgets('$location hyperlink releases playback before launching URL',
        (tester) async {
      String? launchedUrl;
      const channel = MethodChannel('plugins.flutter.io/url_launcher');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'launch') {
          expect(platform.playing, isEmpty);
          expect(platform.disposed, [0]);
          launchedUrl = (call.arguments as Map)['url'] as String;
          return true;
        }
        return null;
      });
      addTearDown(() => TestDefaultBinaryMessengerBinding
          .instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null));
      await pumpBanner(tester,
          content: linkedContent(
            option: AppStrings.custom,
            data: RedirectData(
                redirectType: AppStrings.reDirectLink,
                redirectUrlData:
                    RedirectUrlData(url: 'https://example.com/offers')),
          ));
      if (location == 'fullscreen') {
        await tester.tap(find.byTooltip('Fullscreen'));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('Open link'));
      await finishTransition(tester);
      await tester.pumpAndSettle();
      expect(launchedUrl, 'https://example.com/offers');
      expect(find.byTooltip('Close fullscreen'), findsNothing);
      await cleanUp(tester);
    });
  }
}
