import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:waioz/model/add_on_products_response.dart';
import 'package:waioz/model/product_info_response.dart';
import 'package:waioz/model/product_response.dart' as ProductResponse;
import 'package:waioz/model/related_products_response.dart';
import 'package:waioz/model/review_response.dart';
import 'package:waioz/model/up_sell_products_response.dart';
import 'package:waioz/model/view_cart_model.dart';
import 'package:waioz/model/wishlist_reponse.dart';
import 'package:waioz/ui/cart_page.dart';
import 'package:waioz/ui/cart_response.dart';
import 'package:waioz/ui/phone_number_page.dart';
import 'package:waioz/ui/widgets/add_on_product_card.dart';
import 'package:waioz/ui/widgets/app_loader.dart';
import 'package:waioz/ui/widgets/login_prompt.dart';
import 'package:waioz/ui/widgets/rating_widget.dart';
import 'package:waioz/ui/widgets/review_card.dart';
import 'package:waioz/ui/widgets/product_recommendation_section.dart';
import 'package:waioz/ui/widgets/view_cart.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/app_utils.dart';
import 'package:waioz/utility/currency_util.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/image_fallback_widget.dart';
import 'package:waioz/utility/page_route_utils.dart';
import 'package:waioz/utility/ui_typography.dart';

import '../api/api_service.dart';
import '../model/product_response.dart' hide Image;
import '../utility/common_html.dart';
import '../utility/full_screen_carousel.dart';
import 'bottom_nav_page.dart';
import 'widgets/favourite_heart_button.dart';
import 'favourite_list_detail_page.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;
  final bool isFromLogin;

  const ProductDetailPage(
      {super.key, required this.productId, this.isFromLogin = false});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  ProductResponse.Product? product;
  ReviewResponse? reviewResponse;
  ProductInfoResponse? productInfoResponse;
  RelatedProductsResponse? relatedProductsResponse;
  UpSellProductsResponse? upSellProductsResponse;
  AddOnProductsResponse? addOnProductsResponse;
  CartResponse? cartResponse;

  bool apiLoading = true;
  bool quantityLoading = false;
  bool hasVariants = false;
  bool? productPresentInCart; // Changed to nullable to handle loading state
  bool isFavorite = false;
  String? wishlistId = '';
  bool favouriteListEnabled = false;
  String favouriteListName = 'Favourite List';
  int? addOnProductsCount = 0;

  //ProductResponse.Value? selectedColor;
  //ProductResponse.Value? selectedSize;
  Map<String, ProductResponse.Value?> selectedOptions = {};

  ProductResponse.Variant? selectedVariant;
  String? selectedVariantId;
  int selectedQuantity = 1;
  final TextEditingController _quantityController = TextEditingController();
  bool stockNotAvailable = false;

  int _cartLineItemQty = 0;
  String? _cartLineItemId;

  bool showVariantSelection = false;

  int? cartItems;
  List<String>? cartItemImages;
  late StreamSubscription<ViewCartModel> _eventSubscription;

  bool isLoggedIn = false;

  FavouriteListConfig _favConfig = FavouriteListConfig();

  Map<String, File?>? videoThumbnails;

  final PageController _galleryController = PageController();
  int _currentGalleryIndex = 0;

  final ScrollController _scrollController = ScrollController();
  bool _showStickyHeader = false;

  @override
  void initState() {
    super.initState();

    _quantityController.text = selectedQuantity.toString();
    _scrollController.addListener(_onScroll);

    AppUtils.isLoggedIn().then((value) {
      setState(() {
        isLoggedIn = value;
      });
      fetchInitialData();
      listenToEvents();
      if (value) _loadFavouriteState();
    });
  }

  void listenToEvents() {
    _eventSubscription = eventBus.on<ViewCartModel>().listen((event) {
      if (mounted) {
        setState(() {
          cartItems = event.totalItems;
          cartItemImages = event.itemImages;
        });
      }
    });
  }

  void _onScroll() {
    if (!mounted) return;
    final shouldShow = _scrollController.offset > 30;
    if (shouldShow != _showStickyHeader) setState(() => _showStickyHeader = shouldShow);
  }

  @override
  void dispose() {
    _eventSubscription.cancel();
    _quantityController.dispose();
    _galleryController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadFavouriteState() async {
    try {
      final api = ApiService();
      final results = await Future.wait([
        api.getFavouriteListConfig(context),
        api.getSavedItems(context),
      ]);
      final config = results[0] as FavouriteListConfig;
      final saved = results[1] as SavedItemsResponse;
      if (!mounted) return;
      final productId = product?.id ?? widget.productId;
      setState(() {
        _favConfig = config;
        isFavorite = saved.items.any((i) => i.productId == productId);
      });
    } catch (_) {}
  }

  Future<void> fetchInitialData() async {
    setState(() => apiLoading = true);

    try {
      await getProductsApi();
      // Await cart so qty is ready before the loader hides — avoids the
      // flash of 0→N qty after the product is visible.
      if (isLoggedIn) await getCartApi();
      if (mounted) {
        setState(() => apiLoading = false);
      }

      // Load non-critical sections in background after primary PDP is visible.
      unawaited(getRelatedProductsApi());
      unawaited(getUpSellingProductsApi());
      if (isLoggedIn) unawaited(getReviewApi());
      unawaited(getProductsInfoApi());
    } catch (e) {
      print("Error fetching initial data: $e");
      if (mounted) {
        setState(() => apiLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if (Navigator.of(context).canPop()) {
          Navigator.pop(context);
        } else {
          PageRouteUtils.pushAndRemoveUntil(context, BottomNavPage());
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.white,
          body: apiLoading
              ? const AppLoader()
              : Stack(
                  children: [
                    MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildImageSection(context),
                          _buildContentCard(context),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: IgnorePointer(
                        ignoring: !_showStickyHeader,
                        child: AnimatedOpacity(
                          opacity: _showStickyHeader ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOut,
                          child: AnimatedSlide(
                            offset: _showStickyHeader
                                ? Offset.zero
                                : const Offset(0, -1),
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                            child: _buildStickyHeader(context),
                          ),
                        ),
                      ),
                    ),
                    buildBottomButton(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final topPad = MediaQuery.of(context).padding.top;
    // Add topPad so the visible area *below* the status bar is exactly 50% of screen height
    final imageH = screenH * 0.50 + topPad;

    final variantImages = selectedVariant?.metadata?.images ?? [];
    final variantVideos = productInfoResponse?.productVideo ?? [];

    final variantImageUrls = variantImages
        .map((e) => e.url ?? '')
        .where((url) => url.isNotEmpty)
        .toList();

    final videoUrls = variantVideos
        .map((v) => v.url ?? '')
        .where((url) => url.toLowerCase().endsWith('.mp4'))
        .toList();

    final commonImageUrls = (product?.images ?? [])
        .map((img) => img.url ?? '')
        .where((url) => url.isNotEmpty && !variantImageUrls.contains(url))
        .toList();

    final displayUrls = [...variantImageUrls, ...commonImageUrls, ...videoUrls];
    final safeIndex = displayUrls.isEmpty
        ? 0
        : _currentGalleryIndex.clamp(0, displayUrls.length - 1);

    return SizedBox(
      height: imageH,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(child: Container(color: Colors.white)),

          if (displayUrls.isNotEmpty)
            Positioned.fill(
              child: PageView.builder(
                controller: _galleryController,
                itemCount: displayUrls.length,
                onPageChanged: (i) => setState(() => _currentGalleryIndex = i),
                itemBuilder: (context, index) {
                  final url = displayUrls[index];
                  final isVideo = url.toLowerCase().endsWith('.mp4');
                  return GestureDetector(
                    onTap: () => PageRouteUtils.pushWithFade(
                      context,
                      FullscreenImageCarousel(
                        imageUrls: displayUrls,
                        initialIndex: index,
                        videoThumbnails: videoThumbnails,
                      ),
                    ),
                    child: isVideo
                        ? Stack(
                            alignment: Alignment.center,
                            children: [
                              if (videoThumbnails?[url] != null)
                                Image.file(videoThumbnails![url]!,
                                    width: double.infinity,
                                    height: imageH,
                                    fit: BoxFit.cover,
                                    alignment: Alignment.topCenter)
                              else
                                Container(
                                    width: double.infinity,
                                    height: imageH,
                                    color: Colors.black12,
                                    child: const Center(
                                        child: CircularProgressIndicator())),
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.35),
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.play_arrow_rounded,
                                    size: 38, color: Colors.white),
                              ),
                            ],
                          )
                        : CachedNetworkImage(
                            imageUrl: url,
                            width: double.infinity,
                            height: imageH,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            errorWidget: (_, __, ___) =>
                                ImageFallbackWidget(h: imageH),
                          ),
                  );
                },
              ),
            )
          else
            Positioned.fill(child: ImageFallbackWidget(h: imageH)),

          // Bottom gradient: semi-opaque white → transparent white
          // Avoids the gray-midpoint artifact and is softer on dark images
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 72,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xBBFFFFFF), Color(0x00FFFFFF)],
                ),
              ),
            ),
          ),

          // Page dots
          if (displayUrls.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(displayUrls.length, (i) {
                  final active = i == safeIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 6,
                    width: active ? 18 : 6,
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.primary
                          : Colors.grey.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  );
                }),
              ),
            ),

          // Back button
          Positioned(
            top: topPad + 8,
            left: 12,
            child: _overlayCircleButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () {
                if (!widget.isFromLogin) {
                  Navigator.pop(context);
                } else {
                  PageRouteUtils.pushAndRemoveUntil(
                      context, const BottomNavPage());
                }
              },
            ),
          ),

          // Favourite button (top-right, same row as back button)
          Positioned(
            top: topPad + 8,
            right: 12,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3))
                ],
              ),
              alignment: Alignment.center,
              child: FavouriteHeartButton(
                productId: product?.id ?? widget.productId,
                productHandle: product?.handle ?? '',
                selectedVariantId: selectedVariantId,
                variants: product?.variants
                        ?.map((v) => {
                              'id': v.id,
                              'title': v.title,
                              'options': v.options
                                      ?.map((o) => o.value ?? '')
                                      .where((s) => s.isNotEmpty)
                                      .toList() ??
                                  [],
                            })
                        .toList() ??
                    [],
                isLoggedIn: isLoggedIn,
                config: _favConfig,
                initialSaved: isFavorite,
                size: 22,
                onViewList: (listId, listName) => PageRouteUtils.pushWithSlide(
                  context,
                  FavouriteListDetailPage(
                    listId: listId,
                    listName: listName,
                    config: _favConfig,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _overlayCircleButton(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: Icon(icon, size: 18, color: AppColors.textColor),
      ),
    );
  }

  Widget _buildStickyHeader(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final variantImageUrls = (selectedVariant?.metadata?.images ?? [])
        .map((e) => e.url ?? '')
        .where((url) => url.isNotEmpty)
        .toList();
    final allImages = [
      ...variantImageUrls,
      ...(product?.images ?? [])
          .map((img) => img.url ?? '')
          .where((url) => url.isNotEmpty)
    ];
    final thumbnailUrl = allImages.isNotEmpty ? allImages.first : null;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(top: topPad),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                if (!widget.isFromLogin) {
                  Navigator.pop(context);
                } else {
                  PageRouteUtils.pushAndRemoveUntil(
                      context, const BottomNavPage());
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    size: 20, color: AppColors.textColor),
              ),
            ),
            if (thumbnailUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: thumbnailUrl,
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    width: 44,
                    height: 44,
                    color: AppColors.secondary,
                    child: const ImageFallbackWidget(h: 44),
                  ),
                ),
              ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product?.title ?? '',
                    style: FontUtils.primaryFontStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Text(
                        getDisplayedPrice(),
                        style: FontUtils.primaryFontStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary),
                      ),
                      if (getDiscountPercent() != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          '${getDiscountPercent()}% OFF',
                          style: FontUtils.primaryFontStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1FA971)),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            FavouriteHeartButton(
              productId: product?.id ?? widget.productId,
              productHandle: product?.handle ?? '',
              selectedVariantId: selectedVariantId,
              variants: product?.variants
                      ?.map((v) => {
                            'id': v.id,
                            'title': v.title,
                            'options': v.options
                                    ?.map((o) => o.value ?? '')
                                    .where((s) => s.isNotEmpty)
                                    .toList() ??
                                [],
                          })
                      .toList() ??
                  [],
              isLoggedIn: isLoggedIn,
              config: _favConfig,
              initialSaved: isFavorite,
              size: 20,
              onViewList: (listId, listName) => PageRouteUtils.pushWithSlide(
                context,
                FavouriteListDetailPage(
                  listId: listId,
                  listName: listName,
                  config: _favConfig,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRatingRow(),
                Text(
                  product?.title ?? '',
                  style: FontUtils.primaryFontStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColor,
                  ),
                ),
                if ((product?.subtitle ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    product!.subtitle!,
                    style: FontUtils.primaryFontStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade600),
                  ),
                ],
                const SizedBox(height: 14),
                _buildPriceRow(),
                if (product?.collection?.title?.isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  _buildCollectionRow(),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
          if (!(product?.variants?.isEmpty ?? true))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: buildCartSection(),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: buildProductDescription(),
          ),
          buildRelatedProducts(),
          buildUpSellingProducts(),
          if (reviewResponse != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: buildReviews(),
            ),
        ],
      ),
    );
  }

  Widget _buildRatingRow() {
    final reviews = reviewResponse?.data?.productReviews ?? [];
    if (reviews.isEmpty) return const SizedBox.shrink();

    final ratings = reviews
        .map((r) => double.tryParse(r.rating ?? '') ?? 0.0)
        .where((r) => r > 0)
        .toList();
    if (ratings.isEmpty) return const SizedBox(height: 8);

    final avg = ratings.reduce((a, b) => a + b) / ratings.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, color: Color(0xFF1FA971), size: 15),
          const SizedBox(width: 4),
          Text(
            avg.toStringAsFixed(1),
            style: FontUtils.primaryFontStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1FA971)),
          ),
          Text(
            ' (${reviews.length} reviews)',
            style: FontUtils.primaryFontStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow() {
    final price = getDisplayedPrice();
    final hasDiscount = selectedVariant != null &&
        selectedVariant!.calculatedPrice?.rawCalculatedAmount?.value !=
            selectedVariant!.calculatedPrice?.rawOriginalAmount?.value;
    final originalPrice = CurrencyUtil.appendCurrency(
        selectedVariant?.calculatedPrice?.rawOriginalAmount?.value ?? '0');
    final discountPct = getDiscountPercent();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                price,
                style: FontUtils.primaryFontStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            if (discountPct != null) ...[
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F7F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$discountPct% OFF',
                  style: FontUtils.primaryFontStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1FA971)),
                ),
              ),
            ],
          ],
        ),
        if (hasDiscount) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                'MRP ',
                style: FontUtils.primaryFontStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade500),
              ),
              Text(
                originalPrice,
                style: FontUtils.primaryFontStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade500,
                ).copyWith(decoration: TextDecoration.lineThrough),
              ),
              Text(
                ' (incl. of all taxes)',
                style: FontUtils.primaryFontStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade400),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildCollectionRow() {
    final collection = product?.collection;
    if (collection == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {},
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.store_outlined, color: AppColors.primary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'View all ${collection.title ?? ''} products',
                style: FontUtils.primaryFontStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textColor),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.grey.shade500, size: 20),
          ],
        ),
      ),
    );
  }


  Widget buildRelatedProducts() {
    return ProductRecommendationSection(
      title: relatedProductsResponse?.label ?? AppStrings.related_products,
      products: relatedProductsResponse?.products ?? const [],
    );
  }

  Widget buildUpSellingProducts() {
    return ProductRecommendationSection(
      title: upSellProductsResponse?.label ?? 'Up Selling Products',
      products: upSellProductsResponse?.products ?? const [],
    );
  }


  String getDisplayedPrice() {
    if (selectedVariant != null) {
      return CurrencyUtil.appendCurrency(
          selectedVariant!.calculatedPrice?.rawCalculatedAmount?.value ?? '0');
    }

    // fallback: show lowest variant price if product is loaded
    if (product?.variants?.isNotEmpty ?? false) {
      final prices = product?.variants
              ?.map((v) => double.tryParse(
                  v.calculatedPrice?.rawCalculatedAmount?.value ?? '9999999'))
              .whereType<double>()
              .toList() ??
          [];

      if (prices.isNotEmpty) {
        final lowest = prices.reduce((a, b) => a < b ? a : b);
        return "${AppStrings.from} ${CurrencyUtil.appendCurrency(lowest.toStringAsFixed(0))}";
      }
    }

    return '';
  }

  /// Returns the discount percentage when the variant's original amount is
  /// greater than the calculated amount, otherwise null.
  int? getDiscountPercent() {
    final calculated = double.tryParse(
        selectedVariant?.calculatedPrice?.rawCalculatedAmount?.value ?? '');
    final original = double.tryParse(
        selectedVariant?.calculatedPrice?.rawOriginalAmount?.value ?? '');

    if (calculated == null || original == null) return null;
    if (original <= calculated || original <= 0) return null;

    final percent = ((original - calculated) / original * 100).round();
    return percent > 0 ? percent : null;
  }

  ProductResponse.Variant? getSelectedVariant() {
    if (product == null || selectedOptions.isEmpty) return null;

    for (final variant in product?.variants ?? []) {
      final variantOptionIds = variant.options!.map((opt) => opt.id).toSet();

      final selectedOptionIds =
          selectedOptions.values.map((optVal) => optVal?.id).toSet();

      final isMatch = selectedOptionIds.length == variantOptionIds.length &&
          variantOptionIds.containsAll(selectedOptionIds);

      if (isMatch) return variant;
    }

    return null;
  }

  Widget buildCartSection() {
    if (product?.variants?.isEmpty ?? true) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        if (showVariantSelection) buildDynamicVariantSelection(),
        Text(
          AppStrings.select_qty,
          style: UiTypography.cardTitle().copyWith(fontSize: 16),
        ),
        const SizedBox(height: 10),
        buildQuantitySelector(),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget buildDynamicVariantSelection() {
    if (product?.options == null) return const SizedBox();

    List<Widget> sections = [];

    for (var option in product!.options!) {
      final title = option.title ?? '';

      sections.add(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: ${selectedOptions[option.id!]?.value ?? AppStrings.select}",
            style: UiTypography.cardTitle().copyWith(fontSize: 16),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: option.values!.map((optionValue) {
                final isSelected =
                    selectedOptions[option.id!]?.id == optionValue.id;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedOptions[option.id!] = optionValue;
                      updateVariant();
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 11),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey.shade300,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(999),
                      color: isSelected ? AppColors.primary : Colors.white,
                    ),
                    child: Text(
                      optionValue.value ?? '',
                      style: UiTypography.cardAction(
                        color: isSelected ? Colors.white : AppColors.textColor,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 15),
        ],
      ));
    }

    return Column(children: sections);
  }

  // Syncs cart state for the currently selected variant.
  // Must be called inside setState.
  void _syncCartStateForVariant() {
    if (selectedVariantId == null || cartResponse?.cart?.items == null) {
      productPresentInCart = false;
      _cartLineItemQty = 0;
      _cartLineItemId = null;
      return;
    }
    final items = cartResponse!.cart!.items!;
    final Item? match = items.cast<Item?>().firstWhere(
      (item) => item?.variantId == selectedVariantId,
      orElse: () => null,
    );
    _cartLineItemQty = match?.quantity ?? 0;
    _cartLineItemId = match?.id;
    productPresentInCart = _cartLineItemQty > 0;
    if (_cartLineItemQty > 0) {
      selectedQuantity = _cartLineItemQty;
    }
    // Always sync the controller — switching variants must clear the previous
    // variant's qty even when the new variant has nothing in the cart.
    _quantityController.text = (_cartLineItemQty > 0 ? _cartLineItemQty : selectedQuantity).toString();
  }

  void updateVariant() {
    if (selectedOptions.values.any((v) => v == null)) {
      setState(() => selectedVariant = null);
      return;
    }

    final matchedVariant = getSelectedVariant();

    setState(() {
      selectedVariant = matchedVariant;
      selectedVariantId = matchedVariant?.id;
      stockNotAvailable = !isStockAvailable(selectedVariant);
      selectedQuantity = 1;
      _syncCartStateForVariant();
    });

    print("Selected Variant ID: ${selectedVariant?.id}");
    print("Stock not available: ${!isStockAvailable(selectedVariant)}");
  }

  bool isStockAvailable(ProductResponse.Variant? variant) {
    if (variant == null) return false;

    // If we don't manage inventory
    if (variant.manageInventory == false) {
      return true;
    }

    // If we allow backorders
    if (variant.allowBackorder == true) {
      return true;
    }

    // If inventory is not managed, always in stock
    if (variant.manageInventory != true) {
      return true;
    }

    // If inventory is managed, check quantity > 0
    if ((variant.inventoryQuantity ?? 0) > 0) {
      return true;
    }

    // Managed inventory with 0 quantity = out of stock
    return false;
  }

  int getMaxQuantity(ProductResponse.Variant? variant, List<Item> cartItems) {
    if (variant == null) return 10;

    // how many of this variant already in cart
    final cartQuantity = cartItems.fold<int>(0, (sum, item) {
      if (item.variantId == variant.id) {
        return sum + item.quantity!;
      }
      return sum;
    });

    // if variant has inventory_quantity
    if (variant.inventoryQuantity != null) {
      return (variant.inventoryQuantity! - cartQuantity).clamp(0, 9999);
    }

    // no inventory tracking — allow up to 99
    return (99 - cartQuantity).clamp(0, 99);
  }

  Widget buildProductDescription() {
    final variantDesc = selectedVariant?.metadata?.description ?? '';
    final productDesc =
        product?.metadata?.additionalDescription ?? product?.description ?? '';

    final descriptionToShow =
        (variantDesc?.isNotEmpty == true) ? variantDesc : productDesc;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.description,
          style: UiTypography.cardTitle().copyWith(fontSize: 18),
        ),
        const SizedBox(height: 10),
        CommonHtmlWidget(htmlContent: descriptionToShow ?? ''),
      ],
    );
  }

  Widget buildRatingSection() {
    return RatingWidget(
      onRatingChanged: (rating) => print('Rating: $rating'),
      onSubmit: () => print('Review submitted!'),
    );
  }

  Widget buildReviews() {
    final customerReview = reviewResponse?.data?.customerReview;
    final productReviews = reviewResponse?.data?.productReviews ?? [];
    final hasCustomerReview = (customerReview?.id ?? '').isNotEmpty;

    if (reviewResponse == null ||
        (!hasCustomerReview && productReviews.isEmpty)) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.reviews,
          style: UiTypography.cardTitle().copyWith(fontSize: 18),
        ),
        const SizedBox(height: 12),
        // Text((product?.metadata?['review_summ'] ?? "").isNotEmpty?,
        //     style: FontUtils.secondaryFontStyle(
        //         fontWeight: FontWeight.w700,
        //         fontSize: 24,
        //         color: AppColors.textColor)),
        const SizedBox(
          height: 12,
        ),
        // Text('${reviewResponse?.count?.toString()} Reviews' ?? '',
        //     style: FontUtils.primaryFontStyle(
        //         fontWeight: FontWeight.w400,
        //         fontSize: 12,
        //         color: AppColors.textColor)),
        const SizedBox(
          height: 12,
        ),
        if (hasCustomerReview)
          ReviewCard(
            profileImageUrl: AppStrings.profileImageUrl,
            name: _reviewerName(
              customerReview?.customer?.firstName,
              customerReview?.customer?.lastName,
              fallback: 'You',
            ),
            reviewText: customerReview?.description ?? "",
            rating: double.tryParse(customerReview?.rating ?? "") ?? 0,
            timestamp: _formatReviewDate(customerReview?.updatedAt),
          ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: productReviews.length,
          itemBuilder: (context, index) {
            final review = productReviews[index];
            return ReviewCard(
              profileImageUrl: AppStrings.profileImageUrl,
              name: _reviewerName(
                review.customer?.firstName,
                review.customer?.lastName,
              ),
              reviewText: review.description ?? "",
              rating: double.tryParse(review.rating ?? "") ?? 0,
              timestamp: _formatReviewDate(review.updatedAt),
            );
          },
        ),
      ],
    );
  }

  String _reviewerName(String? firstName, String? lastName,
      {String fallback = 'Customer'}) {
    final name = [firstName, lastName]
        .where((part) => (part ?? '').trim().isNotEmpty)
        .map((part) => part!.trim())
        .join(' ');
    return name.isNotEmpty ? name : fallback;
  }

  String _formatReviewDate(DateTime? date) {
    if (date == null) return '';
    final localDate = date.toLocal();
    return 'Reviewed on ${localDate.day.toString().padLeft(2, '0')}/'
        '${localDate.month.toString().padLeft(2, '0')}/'
        '${localDate.year}';
  }

  Widget buildBottomButton() {
    return Visibility(
      visible: cartItems != null && cartItems != 0,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: cartItems != null
            ? Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 16,
                ),
                child: GestureDetector(
                  onTap: () {
                    PageRouteUtils.pushWithSlide(context, const CartPage());
                  },
                  child: ViewCartWidget(
                      totalItems: cartItems ?? 0, itemImages: cartItemImages),
                ),
              )
            : const SizedBox(),
      ),
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 44,
        height: 48,
        child: Icon(
          icon,
          size: 20,
          color: enabled ? AppColors.textColor : Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget buildQuantitySelector() {
    final int _stepperMax = (productPresentInCart == true)
        ? (selectedVariant?.inventoryQuantity ?? 99)
        : getMaxQuantity(selectedVariant, cartResponse?.cart?.items ?? []);

    return Row(
      children: [
        // Quantity stepper (− / value / +)
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStepperButton(
                icon: Icons.remove_rounded,
                enabled: selectedQuantity > 1,
                onTap: () {
                  if (selectedQuantity > 1) {
                    setState(() => selectedQuantity--);
                    _quantityController.text = selectedQuantity.toString();
                  }
                },
              ),
              SizedBox(
                width: 48,
                child: TextField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(3),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Qty',
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: FontUtils.secondaryFontStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                  onChanged: (value) {
                    final parsed = int.tryParse(value);
                    if (parsed != null && parsed > 0) {
                      setState(() => selectedQuantity = parsed);
                    }
                  },
                ),
              ),
              _buildStepperButton(
                icon: Icons.add_rounded,
                enabled: selectedQuantity < _stepperMax,
                onTap: () {
                  if (selectedQuantity < _stepperMax) {
                    setState(() => selectedQuantity++);
                    _quantityController.text = selectedQuantity.toString();
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 10), // Adds spacing between stepper and button
        // "Add to Cart" button takes more space
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedVariantId == null && stockNotAvailable
                  ? Colors.grey
                  : AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              minimumSize: const Size(double.infinity, 54),
              elevation: 0,
            ),
            onPressed: selectedVariantId == null || stockNotAvailable
                ? null
                : () async {
                    if (_quantityController.text.trim().isEmpty) {
                      AppUtils.showToast(AppStrings.please_enter_quantity);
                      return;
                    }
                    final parsedQty =
                        int.tryParse(_quantityController.text.trim());
                    if (parsedQty == null || parsedQty <= 0) {
                      AppUtils.showToast(
                          AppStrings.please_enter_valid_quantity);
                      return;
                    }
                    selectedQuantity = parsedQty;
                    final enteredQty = selectedQuantity;
                    final maxQty = getMaxQuantity(
                        selectedVariant, cartResponse?.cart?.items ?? []);

                    if (maxQty <= 0) {
                      AppUtils.showToast(AppStrings.max_items_stock_reached);
                      return;
                    }

                    final safeQty = (enteredQty.clamp(1, maxQty)).toInt();

                    if (safeQty < enteredQty) {
                      AppUtils.showToast(
                          '${AppStrings.can_add_upto_prefix} $maxQty ${AppStrings.items_suffix}');
                      return;
                    }

                    if (!isLoggedIn) {
                      showDialog(
                        context: context,
                        builder: (_) => Dialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: LoginPrompt(
                            showClose: true,
                            onClosePressed: () {
                              Navigator.pop(context);
                            },
                            onButtonPressed: () {
                              Navigator.pop(context);
                              PageRouteUtils.push(
                                  context,
                                  PhoneNumberPage(
                                    redirectPage: ProductDetailPage(
                                      productId: widget.productId,
                                      isFromLogin: true,
                                    ),
                                  ));
                            },
                          ),
                        ),
                      );
                      return;
                    }
                    if (productPresentInCart == true && _cartLineItemId != null) {
                      // Update existing cart item to new total qty
                      setState(() => quantityLoading = true);
                      try {
                        await ApiService().updateCart(
                            context, selectedQuantity, _cartLineItemId!);
                        await getCartApi();
                      } catch (_) {}
                      if (mounted) setState(() => quantityLoading = false);
                      return;
                    }
                    if ((addOnProductsCount ?? 0) > 0) {
                      final selectedAddOns = await showAddOnBottomSheet(
                        context,
                        addOnProductsResponse?.products ?? [],
                      );

                      if (selectedAddOns != null) {
                        await addProductWithAddOnsToCart(
                          mainQty: selectedQuantity,
                          mainVariantId: selectedVariantId!,
                          addOns: selectedAddOns,
                        );
                      }
                    } else {
                      await addProductWithAddOnsToCart(
                        mainQty: selectedQuantity,
                        mainVariantId: selectedVariantId!,
                        addOns: [],
                      );
                    }
                  },
            child: quantityLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (selectedVariantId != null && !stockNotAvailable) ...[
                        const Icon(
                          Icons.shopping_bag_outlined,
                          size: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Text(
                          selectedVariantId == null
                              ? AppStrings.select_variant
                              : stockNotAvailable
                                  ? AppStrings.out_of_stock
                                  : (productPresentInCart == true
                                      ? AppStrings.update_cart
                                      : AppStrings.add_to_cart),
                          style: FontUtils.primaryFontStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> getProductsApi() async {
    try {
      final apiService = ApiService();
      final response =
          await apiService.productDetail(context, widget.productId);
      if (!mounted) return;
      setState(() {
        product = response.product;
      });
      if (product != null &&
          product!.variants != null &&
          product!.variants!.isNotEmpty) {
        // Case 1: Single variant — nothing meaningful to select
        if (product!.variants!.length == 1) {
          setState(() {
            selectedVariantId = product!.variants!.first.id;
            selectedVariant = product!.variants!.first;
            showVariantSelection = false;
            stockNotAvailable = !isStockAvailable(product!.variants!.first);
          });
        } else {
          final cheapestAvailable = getCheapestAvailableVariant(product!);

          if (cheapestAvailable != null) {
            setState(() {
              selectedVariant = cheapestAvailable;
              selectedVariantId = cheapestAvailable.id;
              stockNotAvailable = !isStockAvailable(cheapestAvailable);

              // fill selectedOptions for UI highlighting
              selectedOptions = {};
              for (final opt in cheapestAvailable.options ?? []) {
                final productOption = product!.options
                    ?.where((po) => po.id == opt.optionId)
                    .cast<ProductOption?>()
                    .firstOrNull;

                if (productOption == null) continue;

                final matchedValue = productOption.values
                    ?.where((v) => v.id == opt.id)
                    .cast<Value?>()
                    .firstOrNull;

                if (matchedValue != null) {
                  selectedOptions[productOption.id!] = matchedValue;
                }
              }

              showVariantSelection = true;
            });
          }
        }
      } else {
        setState(() {
          selectedVariantId = product?.id;
          showVariantSelection = false;
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  ProductResponse.Variant? getCheapestAvailableVariant(
      ProductResponse.Product product) {
    if (product.variants == null || product.variants!.isEmpty) return null;

    // sort variants by price ascending
    final sortedVariants = product.variants!
      ..sort((a, b) {
        final priceA = double.tryParse(
                a.calculatedPrice?.rawCalculatedAmount?.value ?? '9999999') ??
            double.infinity;
        final priceB = double.tryParse(
                b.calculatedPrice?.rawCalculatedAmount?.value ?? '9999999') ??
            double.infinity;
        return priceA.compareTo(priceB);
      });

    // return first variant that has stock
    for (final variant in sortedVariants) {
      if (isStockAvailable(variant)) {
        return variant;
      }
    }

    // if nothing available → return the absolute cheapest anyway
    return sortedVariants.first;
  }

  Future<void> getRelatedProductsApi() async {
    try {
      if ((productInfoResponse?.relatedProductCount ?? 1) == 0) {
        return;
      }
      final apiService = ApiService();
      final response =
          await apiService.relatedProducts(context, widget.productId);
      if (!mounted) return;
      setState(() => relatedProductsResponse = response);
    } catch (e) {
      print(e);
    }
  }

  Future<void> getUpSellingProductsApi() async {
    try {
      if ((productInfoResponse?.upSellingProductCount ?? 1) == 0) {
        return;
      }
      final apiService = ApiService();
      final response =
          await apiService.upSellingProducts(context, widget.productId);
      if (!mounted) return;
      setState(() => upSellProductsResponse = response);
    } catch (e) {
      debugPrint('up selling error: $e');
    }
  }

  Future<void> getReviewApi() async {
    try {
      if (!isLoggedIn) {
        return;
      }
      final apiService = ApiService();
      final response =
          await apiService.getProductReviews(context, widget.productId);
      setState(() => reviewResponse = response);
    } catch (e) {
      debugPrint('exception $e');
    }
  }

  Future<void> getProductsInfoApi() async {
    try {
      final variantId = selectedVariantId;
      if (variantId == null) return;

      final apiService = ApiService();
      final response =
          await apiService.getProductInfo(context, widget.productId, variantId);

      // Ignore stale responses when selected variant changed during request.
      if (!mounted || variantId != selectedVariantId) return;

      setState(() {
        productInfoResponse = response;
        wishlistId = productInfoResponse?.productWishlistId ?? '';
        favouriteListEnabled =
            productInfoResponse?.favouriteListEnabled ?? false;
        favouriteListName = productInfoResponse?.displayName?.isNotEmpty == true
            ? productInfoResponse!.displayName!
            : 'Favourite List';
        addOnProductsCount = productInfoResponse?.addOnProductCount ?? 0;
        // isFavorite and _favConfig are set by _loadFavouriteState() which uses
        // the real config API + saved-items. Only fall back to productInfo if
        // _loadFavouriteState hasn't completed yet.
        if (!_favConfig.enabled && (productInfoResponse?.favouriteListEnabled ?? false)) {
          _favConfig = FavouriteListConfig(
            enabled: productInfoResponse?.favouriteListEnabled ?? false,
            displayName: productInfoResponse?.displayName?.isNotEmpty == true
                ? productInfoResponse!.displayName!
                : 'Favourite List',
          );
        }
      });

      // Load non-critical media/add-ons after essential UI is painted.
      final productVideos = response.productVideo ?? [];
      if (productVideos.isNotEmpty) {
        final videoUrls = productVideos
            .map((v) => v.url ?? '')
            .where((url) => url.toLowerCase().endsWith('.mp4'))
            .toList();
        if (videoUrls.isNotEmpty) {
          unawaited(_loadVideoThumbnails(videoUrls, variantId));
        }
      }

      if ((response.addOnProductCount ?? 0) > 0) {
        unawaited(_loadAddOnProducts(variantId));
      }
      if ((response.relatedProductCount ?? 0) > 0 &&
          (relatedProductsResponse?.products?.isEmpty ?? true)) {
        unawaited(getRelatedProductsApi());
      }
      if ((response.upSellingProductCount ?? 0) > 0 &&
          (upSellProductsResponse?.products?.isEmpty ?? true)) {
        unawaited(getUpSellingProductsApi());
      }
    } catch (e) {
      debugPrint('product info error: $e');
    }
  }

  Future<void> _loadVideoThumbnails(
      List<String> videoUrls, String requestVariantId) async {
    final thumbnails = await generateVideoThumbnails(videoUrls);
    if (!mounted || selectedVariantId != requestVariantId) return;

    setState(() {
      videoThumbnails = thumbnails;
    });
  }

  Future<void> _loadAddOnProducts(String requestVariantId) async {
    try {
      final apiService = ApiService();
      final response =
          await apiService.addOnProducts(context, widget.productId);
      if (!mounted || selectedVariantId != requestVariantId) return;
      final products = response.products ?? [];
      setState(() {
        addOnProductsResponse = response;
        // All addon products are out of stock — skip the popup
        if (products.isEmpty) addOnProductsCount = 0;
      });
    } catch (e) {
      // Add-on load is non-blocking for primary PDP render.
      if (mounted) setState(() => addOnProductsCount = 0);
    }
  }

  Future<void> addCart(int qty, String variantId) async {
    try {
      final apiService = ApiService();
      setState(() => quantityLoading = true);

      await apiService.addCart(context, qty, variantId);
      await getCartApi(); // Refresh cart

      setState(() => quantityLoading = false);
    } catch (e) {
      setState(() => quantityLoading = false);
      print(e);
    }
  }

  Future<void> addProductWithAddOnsToCart({
    required int mainQty,
    required String mainVariantId,
    required List<ProductResponse.Product> addOns,
  }) async {
    try {
      final apiService = ApiService();
      setState(() => quantityLoading = true);

      // Add main product
      await apiService.addCart(context, mainQty, mainVariantId);

      // Add each add-on (with default quantity 1)
      for (final product in addOns) {
        if ((product.variants?.isNotEmpty ?? false)) {
          final variantId = product.variants?.first.id ?? null;
          if (variantId != null) {
            await apiService.addCart(context, mainQty, variantId);
          }
        }
      }

      await getCartApi(); // Refresh cart
    } catch (e) {
      print(e);
    } finally {
      setState(() => quantityLoading = false);
    }
  }

  Future<void> addFavourite() async {
    if (!isLoggedIn) {
      return;
    }

    if (!isFavorite) {
      if (favouriteListEnabled) {
        showFavouriteListPicker();
        return;
      }
      try {
        final apiService = ApiService();
        WishlistResponse wishlistResponse =
            await apiService.addFavourite(context, widget.productId);
        setState(() {
          wishlistId = wishlistResponse.wishlistElement?.id;
          isFavorite = true;
        });
      } catch (e) {
        print(e);
      }
    } else {
      if (favouriteListEnabled) {
        removeFavourite(widget.productId, null);
      } else if (wishlistId != null && wishlistId!.isNotEmpty) {
        removeFavourite(widget.productId, wishlistId);
      }
    }
  }

  void removeFavourite(String? productId, String? wishlistId) async {
    try {
      final ApiService apiService = ApiService();
      if (favouriteListEnabled) {
        await apiService.deleteProductFromFavouriteList(
          context,
          productId: productId ?? '',
          variantId: selectedVariantId,
        );
      } else {
        await apiService.deleteFavourite(context, productId, wishlistId);
      }
      if (mounted) {
        setState(() {
          isFavorite = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void showFavouriteListPicker() {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return GestureDetector(
          onTap: () => FocusScope.of(sheetContext).unfocus(),
          child: SafeArea(
            top: false,
            child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 20,
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
            ),
          child: FutureBuilder<WishlistResponse>(
            future: ApiService().getFavouriteLists(context),
            builder: (context, snapshot) {
              final lists = snapshot.data?.customerWishlistGroup ?? [];
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add to $favouriteListName',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => FocusScope.of(context).unfocus(),
                          decoration: const InputDecoration(
                            hintText: 'New list name',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final name = controller.text.trim();
                          if (name.isEmpty) {
                            AppUtils.showToast('Please enter a list name');
                            return;
                          }
                          await addProductToFavouriteList(listName: name);
                          if (mounted) Navigator.pop(sheetContext);
                        },
                        child: const Text('Create'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  else if (lists.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text('No ${favouriteListName.toLowerCase()} yet'),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: lists.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final list = lists[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.favorite_border,
                                color: AppColors.primary),
                            title: Text(
                                list.wishlistGroupName ?? favouriteListName),
                            onTap: () async {
                              await addProductToFavouriteList(listId: list.id);
                              if (mounted) Navigator.pop(sheetContext);
                            },
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        )));
      },
    );
  }

  Future<void> addProductToFavouriteList({
    String? listId,
    String? listName,
  }) async {
    try {
      await ApiService().addProductToFavouriteList(
        context,
        productId: widget.productId,
        listId: listId,
        listName: listName,
        variantId: selectedVariantId,
        quantity: selectedQuantity,
      );
      if (mounted) {
        setState(() {
          isFavorite = true;
        });
      }
      AppUtils.showToast('Added to $favouriteListName');
    } catch (e) {
      print(e);
    }
  }

  Future<void> getCartApi() async {
    try {
      if (!isLoggedIn) {
        return;
      }
      final apiService = ApiService();
      final response = await apiService.getCart(context);
      setState(() {
        cartResponse = response;
        _syncCartStateForVariant();
        emitEvent(cartResponse!);
      });
    } catch (e) {
      print(e);
      if (!mounted) {
        return;
      }
      setState(() {
        productPresentInCart = false;
        _cartLineItemQty = 0;
        _cartLineItemId = null;
      });
    }
  }

  Future<List<ProductResponse.Product>?> showAddOnBottomSheet(
    BuildContext context,
    List<ProductResponse.Product>? productList,
  ) async {
    return await showModalBottomSheet<List<ProductResponse.Product>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                AppStrings.add_ons,
                                style: FontUtils.primaryFontStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 1),

                    // Product List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: productList?.length ?? 0,
                        itemBuilder: (context, index) {
                          final product = productList?[index];
                          return AddOnProductCard(
                            product: product,
                            onToggle: () {
                              setState(() {
                                product?.isSelected = !product.isSelected;
                              });
                            },
                          );
                        },
                      ),
                    ),

                    // Sticky Button
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(16),
                      child: ElevatedButton(
                        onPressed: () {
                          final selected =
                              productList?.where((p) => p.isSelected).toList();
                          Navigator.of(context).pop(selected);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          AppStrings.add_to_cart,
                          style: FontUtils.primaryFontStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void emitEvent(CartResponse cartResponse) {
    setState(() {
      cartItems =
          cartResponse.cart?.items?.where((item) => !item.isPlatformFee).length;
      cartItemImages = cartResponse.cart?.items
          ?.where((item) => !item.isPlatformFee)
          .map((item) => item.thumbnail ?? "")
          .toList();
    });
    if ((cartResponse.cart?.items
                ?.where((item) => !item.isPlatformFee)
                .length ??
            0) >
        0) {
      final qtyMap = <String, int>{};
      for (var item in cartResponse.cart?.items ?? []) {
        qtyMap[item.variantId] = item.quantity;
      }
      eventBus.fire(ViewCartModel(cartItems, cartItemImages, qtyMap));
    }
  }

  Future<Map<String, File?>> generateVideoThumbnails(
      List<String> videoUrls) async {
    final cacheDir = await getTemporaryDirectory();
    final Map<String, File?> thumbnailMap = {};

    for (final url in videoUrls) {
      final fileName =
          Uri.parse(url).pathSegments.last.replaceAll('.mp4', '.jpg');
      final cachedFile = File('${cacheDir.path}/$fileName');

      if (await cachedFile.exists()) {
        thumbnailMap[url] = cachedFile;
        continue;
      }

      try {
        final uint8list = await VideoThumbnail.thumbnailData(
          video: url,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 320,
          quality: 75,
        );

        if (uint8list != null) {
          await cachedFile.writeAsBytes(uint8list);
          thumbnailMap[url] = cachedFile;
        }
      } catch (e) {
        print('Thumbnail generation failed for $url: $e');
        thumbnailMap[url] = null;
      }
    }

    return thumbnailMap;
  }
}
