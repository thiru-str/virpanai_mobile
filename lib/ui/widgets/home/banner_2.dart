import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/ui/widgets/item_video_tile.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/app_strings.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/image_fallback_widget.dart';
import '../../../utility/redirect_utils.dart';

class Banner2 extends StatefulWidget {
  final Content content;

  const Banner2({super.key, required this.content});

  @override
  State<Banner2> createState() => _Banner2State();
}

class _Banner2State extends State<Banner2> with WidgetsBindingObserver {
  final PageController _pageController = PageController();
  final Map<int, GlobalKey<ItemVideoTileState>> _videoKeys = {};
  final Key _visibilityKey = UniqueKey();
  Timer? _autoScrollTimer;
  Animation<double>? _routeAnimation;
  int _currentPage = 0;
  bool _isVisible = false;
  bool _isMuted = false;
  bool _fullscreen = false;
  bool _navigating = false;
  bool _routeCurrent = true;
  bool _appActive = true;

  List<LayoutDatum> get _items => widget.content.layoutData ?? [];
  bool get _canPlay =>
      _isVisible &&
      _appActive &&
      !_navigating &&
      (_routeCurrent || _fullscreen);

  bool _isVideo(String url) =>
      Uri.tryParse(url.trim())?.path.toLowerCase().endsWith('.mp4') ?? false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (_routeAnimation != route?.secondaryAnimation) {
      _routeAnimation?.removeListener(_scheduleRouteCheck);
      _routeAnimation = route?.secondaryAnimation;
      _routeAnimation?.addListener(_scheduleRouteCheck);
    }
    _routeCurrent = route?.isCurrent ?? true;
    _startAutoScroll();
  }

  void _scheduleRouteCheck() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final isCurrent = ModalRoute.of(context)?.isCurrent ?? true;
      if (isCurrent != _routeCurrent || (isCurrent && _navigating)) {
        setState(() {
          _routeCurrent = isCurrent;
          if (isCurrent) _navigating = false;
        });
        _startAutoScroll();
      }
    });
  }

  @override
  void didUpdateWidget(covariant Banner2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_currentPage >= _items.length) {
      _currentPage = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageController.hasClients) {
          _pageController.jumpToPage(0);
        }
      });
    }
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    if (!_canPlay || _fullscreen || _items.length < 2) return;
    if (_isVideo(_items[_currentPage].image ?? '')) return;
    final interval = double.tryParse(
          widget.content.layoutSlideTimeInterval ?? '5',
        ) ??
        5;
    _autoScrollTimer = Timer(
      Duration(
          milliseconds:
              (interval.isFinite && interval > 0 ? interval * 1000 : 5000)
                  .round()),
      _nextPage,
    );
  }

  void _nextPage() {
    if (!_canPlay || _fullscreen || _items.isEmpty) return;
    if (_items.length == 1) {
      // Remount a single video to replay it after completion.
      setState(() => _videoKeys.clear());
      return;
    }
    unawaited(_showPage((_currentPage + 1) % _items.length));
  }

  Future<void> _showPage(int index) async {
    if (!_pageController.hasClients || _fullscreen || index == _currentPage) {
      return;
    }
    _autoScrollTimer?.cancel();
    await _videoKeys[_currentPage]?.currentState?.pauseAndRelease();
    if (!mounted || !_pageController.hasClients) return;
    await _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _openDestination(VoidCallback redirect) async {
    if (_navigating) return;
    setState(() => _navigating = true);
    _autoScrollTimer?.cancel();
    await Future.wait([
      for (final key in _videoKeys.values)
        if (key.currentState != null) key.currentState!.pauseAndRelease(),
    ]);
    if (!mounted) return;
    redirect();
    _scheduleRouteCheck();
  }

  String? _redirectLabel(RedirectData? data) {
    if (data == null) return null;
    switch (data.redirectType) {
      case AppStrings.reDirectProduct:
        return (data.redirectProductData?.productId?.isNotEmpty ?? false)
            ? 'View product'
            : null;
      case AppStrings.reDirectSearch:
        return (data.redirectSearchData?.category?.isNotEmpty ?? false)
            ? 'View products'
            : null;
      case AppStrings.reDirectPage:
        return (data.redirectPageData?.slug?.isNotEmpty ?? false)
            ? 'View page'
            : null;
      case AppStrings.reDirectOrder:
        return (data.redirectOrderData?.orderId?.isNotEmpty ?? false)
            ? 'View order'
            : null;
      case AppStrings.reDirectLink:
        final uri = Uri.tryParse(data.redirectUrlData?.url ?? '');
        return uri != null && uri.hasScheme ? 'Open link' : null;
      default:
        return null;
    }
  }

  ({String label, VoidCallback redirect})? _itemDestination(LayoutDatum item) {
    final option = widget.content.layoutOption;
    final label = switch (option) {
      AppStrings.product => 'View product',
      AppStrings.category => 'View category',
      AppStrings.brand => 'View brand',
      _ => null,
    };
    if (label != null && (item.id?.isNotEmpty ?? false)) {
      return (
        label: label,
        redirect: () => RedirectUtils.handleContentRedirect(
              context: context,
              layoutOption: option!,
              layoutData: item,
            ),
      );
    }
    // Custom media can have its own destination or inherit the section link.
    final data = _redirectLabel(item.redirectData) != null
        ? item.redirectData
        : widget.content.redirectData;
    final redirectLabel = _redirectLabel(data);
    if (redirectLabel == null) return null;
    return (
      label: redirectLabel,
      redirect: () => RedirectUtils.handleContentRedirectViewAll(
            context: context,
            redirectData: data!,
          ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() => _appActive = state == AppLifecycleState.resumed);
    _startAutoScroll();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _routeAnimation?.removeListener(_scheduleRouteCheck);
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) return const SizedBox.shrink();
    final content = widget.content;
    final hasHeading = content.layoutTitle?.isNotEmpty ?? false;
    final sectionLinkLabel = _redirectLabel(content.redirectData);
    final hasViewAll = sectionLinkLabel != null;
    final currentItem = _items[_currentPage];
    final mediaHeight =
        (MediaQuery.sizeOf(context).height * 0.55).clamp(380.0, 480.0);

    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: VisibilityDetector(
        key: _visibilityKey,
        onVisibilityChanged: (info) {
          if (!mounted) return;
          final visible = info.visibleFraction > 0.3;
          if (visible == _isVisible) return;
          setState(() => _isVisible = visible);
          _startAutoScroll();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasHeading || hasViewAll) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        content.layoutTitle ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: FontUtils.secondaryFontStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                    ),
                    if (hasViewAll)
                      Flexible(
                        child: VideoRedirectLink(
                          label:
                              (content.layoutRedirectTitle?.isNotEmpty ?? false)
                                  ? content.layoutRedirectTitle!
                                  : sectionLinkLabel,
                          color: AppColors.primary,
                          onTap: () => _openDestination(() {
                            RedirectUtils.handleContentRedirectViewAll(
                              context: context,
                              redirectData: content.redirectData!,
                            );
                          }),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              height: mediaHeight,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _items.length,
                onPageChanged: (index) {
                  unawaited(_videoKeys[_currentPage]
                      ?.currentState
                      ?.pauseAndRelease());
                  setState(() => _currentPage = index);
                  _startAutoScroll();
                },
                itemBuilder: (context, index) {
                  final item = _items[index];
                  final url = item.image ?? '';
                  final destination = _itemDestination(item);
                  final VoidCallback? open = destination == null
                      ? null
                      : () => unawaited(_openDestination(destination.redirect));
                  return _isVideo(url)
                      ? ItemVideoTile(
                          key: _videoKeys.putIfAbsent(
                              index, () => GlobalKey<ItemVideoTileState>()),
                          videoUrl: url,
                          title: item.title ?? '',
                          isActive: _canPlay && index == _currentPage,
                          isMuted: _isMuted,
                          onMute: () => setState(() => _isMuted = !_isMuted),
                          onTap: open,
                          redirectLabel: destination?.label,
                          onCompleted: _nextPage,
                          onFullscreenChanged: (fullscreen) {
                            setState(() => _fullscreen = fullscreen);
                            _startAutoScroll();
                          },
                        )
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            GestureDetector(
                              onTap: open,
                              child: CachedNetworkImage(
                                imageUrl: url,
                                fit: BoxFit.contain,
                                errorWidget: (_, __, ___) =>
                                    const ImageFallbackWidget(),
                              ),
                            ),
                            if (destination != null)
                              Positioned(
                                left: 16,
                                right: 16,
                                bottom: 12,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Material(
                                    color: Colors.black54,
                                    child: VideoRedirectLink(
                                      label: destination.label,
                                      color: Colors.white,
                                      onTap: open!,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                },
              ),
            ),
            if ((currentItem.title?.isNotEmpty ?? false))
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Text(
                  currentItem.title!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: FontUtils.primaryFontStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
              ),
            if (_items.length > 1)
              SizedBox(
                height: 44,
                child: Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var index = 0; index < _items.length; index++)
                          Semantics(
                            selected: index == _currentPage,
                            child: IconButton(
                              tooltip: 'Show video ${index + 1}',
                              onPressed: () => _showPage(index),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.standard,
                              style: IconButton.styleFrom(
                                minimumSize: const Size(16, 44),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              constraints: const BoxConstraints.tightFor(
                                  width: 16, height: 44),
                              icon: Icon(
                                index == _currentPage
                                    ? Icons.circle
                                    : Icons.circle_outlined,
                                size: 10,
                                color: index == _currentPage
                                    ? AppColors.primary
                                    : AppColors.tabInActivecolor,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
