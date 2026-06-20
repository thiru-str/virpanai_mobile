import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
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
import 'package:waioz/ui/widgets/app_shimmer.dart';
import 'package:waioz/ui/widgets/common_header_app_bar.dart';
import 'package:waioz/ui/widgets/login_prompt.dart';
import 'package:waioz/ui/widgets/rating_widget.dart';
import 'package:waioz/ui/widgets/review_card.dart';
import 'package:waioz/ui/widgets/screen_skeletons.dart';
import 'package:waioz/ui/widgets/product_recommendation_section.dart';
import 'package:waioz/ui/widgets/view_cart.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_link_helper.dart';
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
import 'widgets/loyalty_earn_preview.dart';

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
  bool stockNotAvailable = false;

  bool showVariantSelection = false;

  int? cartItems;
  List<String>? cartItemImages;
  late StreamSubscription<ViewCartModel> _eventSubscription;

  bool isLoggedIn = false;

  FavouriteListConfig _favConfig = FavouriteListConfig();

  Map<String, File?>? videoThumbnails;

  final PageController _galleryController = PageController();
  int _currentGalleryIndex = 0;

  @override
  void initState() {
    super.initState();

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

  @override
  void dispose() {
    _eventSubscription
        .cancel(); // Cancel the subscription to prevent memory leaks
    _galleryController.dispose();
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
      if (mounted) {
        setState(() => apiLoading = false);
      }

      // Load non-critical sections in background after primary PDP is visible.
      unawaited(getRelatedProductsApi());
      unawaited(getUpSellingProductsApi());
      if (isLoggedIn) {
        unawaited(getReviewApi());
        unawaited(getCartApi());
      }
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
      canPop: false, // Disable default back button
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if (Navigator.of(context).canPop()) {
          Navigator.pop(context); // Normal back navigation
        } else {
          // Redirect to home when no backstack exists
          PageRouteUtils.pushAndRemoveUntil(context, BottomNavPage());
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: CommonHeaderAppBar(
            onBackTap: () {
              if (!widget.isFromLogin) {
                Navigator.pop(context);
              } else {
                PageRouteUtils.pushAndRemoveUntil(
                    context, const BottomNavPage());
              }
            },
            onShareTap: () {
              AppLinkHelper.shareProductInvite(widget.productId);
            },
            favWidget: FavouriteHeartButton(
              productId: product?.id ?? widget.productId,
              productHandle: product?.handle ?? '',
              selectedVariantId: selectedVariantId,
              variants: product?.variants?.map((v) => {'id': v.id, 'title': v.title}).toList() ?? [],
              isLoggedIn: isLoggedIn,
              config: _favConfig,
              initialSaved: isFavorite,
              size: 22,
            ),
          ),
          backgroundColor: const Color(0xFFF9F9FB),
          body: apiLoading
              ? const AppLoader()
              : SafeArea(
                  child: Stack(children: [
                    Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 12, 16, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppReveal(child: buildProductImages()),
                                  const SizedBox(height: 25),
                                  AppReveal(
                                      index: 1, child: buildProductDetails()),
                                  AppReveal(
                                      index: 2, child: buildCartSection()),
                                  const SizedBox(height: 15),
                                  AppReveal(
                                      index: 3,
                                      child: buildProductDescription()),
                                  AppReveal(
                                      index: 4, child: buildRelatedProducts()),
                                  AppReveal(
                                      index: 5,
                                      child: buildUpSellingProducts()),
                                  AppReveal(index: 6, child: buildReviews()),
                                  const SizedBox(height: 90),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    buildBottomButton()
                  ]),
                ),
        ),
      ),
    );
  }

  Widget buildProductImages() {
    final variantImages = selectedVariant?.metadata?.images ?? [];
    final variantVideos = productInfoResponse?.productVideo ?? [];

    final variantImageUrls = variantImages
        .map((e) => (e.url) ?? '')
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

    final allMedia = [...variantImageUrls, ...commonImageUrls, ...videoUrls];
    final displayUrls = allMedia.isNotEmpty
        ? allMedia
        : <String>[];

    if (displayUrls.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 400,
          width: double.infinity,
          color: AppColors.secondary,
          child: const ImageFallbackWidget(h: 400),
        ),
      );
    }

    // Clamp current index defensively when media list shrinks (e.g. variant change).
    final safeIndex = _currentGalleryIndex.clamp(0, displayUrls.length - 1);

    return Column(
      children: [
        SizedBox(
          height: 400,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(color: AppColors.secondary),
                ),
                Positioned.fill(
                  child: PageView.builder(
                    controller: _galleryController,
                    itemCount: displayUrls.length,
                    onPageChanged: (index) {
                      setState(() => _currentGalleryIndex = index);
                    },
                    itemBuilder: (context, index) {
                      final url = displayUrls[index];
                      final isVideo = url.toLowerCase().endsWith('.mp4');

                      return GestureDetector(
                        onTap: () {
                          PageRouteUtils.pushWithFade(
                            context,
                            FullscreenImageCarousel(
                              imageUrls: displayUrls,
                              initialIndex: index,
                              videoThumbnails: videoThumbnails,
                            ),
                          );
                        },
                        child: isVideo
                            ? Stack(
                                alignment: Alignment.center,
                                children: [
                                  if (videoThumbnails?[url] != null)
                                    Image.file(
                                      videoThumbnails![url]!,
                                      width: double.infinity,
                                      height: 400,
                                      fit: BoxFit.cover,
                                    )
                                  else
                                    Container(
                                      width: double.infinity,
                                      height: 400,
                                      color: Colors.black12,
                                      alignment: Alignment.center,
                                      child: const CircularProgressIndicator(),
                                    ),
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.35),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow_rounded,
                                      size: 38,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              )
                            : CachedNetworkImage(
                                imageUrl: url,
                                width: double.infinity,
                                height: 400,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) =>
                                    const ImageFallbackWidget(h: 400),
                              ),
                      );
                    },
                  ),
                ),
                // Media counter pill (e.g. "2/5")
                if (displayUrls.length > 1)
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${safeIndex + 1}/${displayUrls.length}',
                        style: FontUtils.primaryFontStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (displayUrls.length > 1) ...[
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(displayUrls.length, (index) {
              final isActive = index == safeIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 7,
                width: isActive ? 22 : 7,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary
                      : Colors.grey.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(999),
                ),
              );
            }),
          ),
        ],
      ],
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

  Widget buildProductDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product?.title ?? '',
                style: UiTypography.cardTitle(
                  color: AppColors.textColor,
                ).copyWith(
                  fontSize: 22,
                  height: 1.25,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    getDisplayedPrice(),
                    style: UiTypography.cardPrice(
                      color: AppColors.primary,
                    ).copyWith(
                      fontSize: 22,
                    ),
                  ),
                  Visibility(
                    visible: selectedVariant != null &&
                        selectedVariant!
                                .calculatedPrice?.rawCalculatedAmount?.value !=
                            selectedVariant!
                                .calculatedPrice?.rawOriginalAmount?.value,
                    child: Text(
                      CurrencyUtil.appendCurrency(selectedVariant
                              ?.calculatedPrice?.rawOriginalAmount?.value ??
                          '0'),
                      style: UiTypography.cardMeta(
                        color: Colors.grey,
                      ).copyWith(
                        fontSize: 14,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ),
                  if (getDiscountPercent() != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7F7F0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${getDiscountPercent()}% OFF',
                        style: FontUtils.primaryFontStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1FA971),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        // Loyalty earn preview — points this product earns
        if ((num.tryParse(selectedVariant
                        ?.calculatedPrice?.rawCalculatedAmount?.value ??
                    '') ??
                0) >
            0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: LoyaltyEarnPreview(
              orderTotal: num.tryParse(selectedVariant!
                      .calculatedPrice!.rawCalculatedAmount!.value!) ??
                  0,
              // PDP: let the backend short-circuit when this product isn't in
              // the merchant's earn-allowed list / category.
              productId: widget.productId,
            ),
          ),
      ],
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
        const SizedBox(height: 18),
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

    // default max = 10
    return (10 - cartQuantity).clamp(0, 10);
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
    if (reviewResponse == null ||
        (reviewResponse?.data?.productReviews ?? []).isEmpty)
      return const SizedBox();
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
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: reviewResponse?.data?.productReviews?.length ?? 0,
          itemBuilder: (context, index) {
            final review = reviewResponse?.data?.productReviews?[index];
            return ReviewCard(
              profileImageUrl: AppStrings.profileImageUrl,
              name: review?.customer?.firstName ?? '',
              reviewText: review?.description ?? "",
              rating: double.parse(review?.rating ?? ""),
              timestamp: '',
            );
          },
        ),
      ],
    );
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
                  }
                },
              ),
              SizedBox(
                width: 36,
                child: Text(
                  selectedQuantity.toString(),
                  textAlign: TextAlign.center,
                  style: FontUtils.secondaryFontStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
              ),
              _buildStepperButton(
                icon: Icons.add_rounded,
                enabled: selectedQuantity < 10,
                onTap: () {
                  if (selectedQuantity < 10) {
                    setState(() => selectedQuantity++);
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
                                  : AppStrings.add_to_cart,
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
        // Case 1: Single "default variant"
        if (product!.variants!.length == 1 &&
            product!.variants!.first.title!.toLowerCase() ==
                "default variant") {
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
        productPresentInCart = cartResponse?.cart?.items
                ?.any((item) => item.variantId == selectedVariantId) ??
            false;
        emitEvent(cartResponse!);
      });
    } catch (e) {
      print(e);
      if (!mounted) {
        return;
      }
      setState(() {
        productPresentInCart = false;
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
