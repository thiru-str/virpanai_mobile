import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:waioz/model/product_info_response.dart';
import 'package:waioz/model/product_response.dart' as ProductResponse;
import 'package:waioz/model/related_products_response.dart';
import 'package:waioz/model/review_response.dart';
import 'package:waioz/model/view_cart_model.dart';
import 'package:waioz/model/wishlist_reponse.dart';
import 'package:waioz/ui/cart_page.dart';
import 'package:waioz/ui/cart_response.dart';
import 'package:waioz/ui/dashboard.dart';
import 'package:waioz/ui/phone_number_page.dart';
import 'package:waioz/ui/widgets/cart_button.dart';
import 'package:waioz/ui/widgets/common_header_app_bar.dart';
import 'package:waioz/ui/widgets/product_card.dart';
import 'package:waioz/ui/widgets/quantity_selector.dart';
import 'package:waioz/ui/widgets/rating_widget.dart';
import 'package:waioz/ui/widgets/review_card.dart';
import 'package:waioz/ui/widgets/view_cart.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_logger.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/app_utils.dart';
import 'package:waioz/utility/currency_util.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';

import '../api/api_service.dart';
import '../utility/common_html.dart';
import '../utility/full_screen_carousel.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;
  final bool isFromLogin;

  const ProductDetailPage({super.key, required this.productId,this.isFromLogin = false});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage>
    with SingleTickerProviderStateMixin {
  ProductResponse.Product? product;
  ReviewResponse? reviewResponse;
  ProductInfoResponse? productInfoResponse;
  RelatedProductsResponse? relatedProductsResponse;
  CartResponse? cartResponse;

  bool apiLoading = true;
  bool quantityLoading = false;
  bool hasVariants = false;
  bool? productPresentInCart; // Changed to nullable to handle loading state
  bool isFavorite = false;
  String? wishlistId = '';

  late AnimationController _animationController;
  late Animation<Offset> _animation;

  //ProductResponse.Value? selectedColor;
  //ProductResponse.Value? selectedSize;
  Map<String, ProductResponse.Value?> selectedOptions = {};

  ProductResponse.Variant? selectedVariant;
  String? selectedVariantId;
  int selectedQuantity = 1;

  bool showVariantSelection = false;

  int? cartItems;
  List<String>? cartItemImages;
  late StreamSubscription<ViewCartModel> _eventSubscription;

  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();

    AppUtils.isLoggedIn().then((value) {
      setState(() {
        isLoggedIn = value;
      });
      fetchInitialData();

      // Initialize the animation controller
      _animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1000),
      );

      // Define the animation's starting and ending positions
      _animation = Tween<Offset>(
        begin: const Offset(0, 1), // Start just below the screen
        end: Offset.zero, // End at its natural position
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));

      // Start the animation when the widget is built
      _animationController.forward();
      listenToEvents();
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
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchInitialData() async {
    setState(() => apiLoading = true);

    try {
      await getProductsApi();
      await getReviewApi();
    } catch (e) {
      print("Error fetching initial data: $e");
    } finally {
      setState(() => apiLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHeaderAppBar(
        onBackTap: () {
          if(!widget.isFromLogin) {
            Navigator.pop(context);
          }
          else{
            PageRouteUtils.pushAndRemoveUntil(context, const Dashboard());
          }
        },
        onFavTap: addFavourite,
        isFavorite: isFavorite, // Pass the updated favorite status here
      ),
      backgroundColor: Colors.white,
      body: apiLoading
          ? Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      )
          : SafeArea(
        child: Stack(children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildProductImages(),
                        const SizedBox(height: 25),
                        buildProductDetails(),
                        buildCartSection(),
                        const SizedBox(height: 15),
                        buildProductDescription(),
                        buildRelatedProducts(),
                        /*buildShippingAndReturns(),
                        const SizedBox(height: 15),*/
                        buildReviews(),
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
    );
  }

  Widget buildProductImages() {
    return SizedBox(
      height: 250,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: product?.images?.length ?? 0,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Open fullscreen carousel
              if (product!.images!.isNotEmpty) {
                PageRouteUtils.pushWithFade(
                    context,
                    FullscreenImageCarousel(
                      imageUrls: product!.images!,
                      initialIndex: index,
                    ));
              }
            },
            child: Container(
              width: 180,
              decoration: BoxDecoration(color: AppColors.secondary),
              child: CachedNetworkImage(
                imageUrl: product!.images![index].url!,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildRelatedProducts() {

    if((relatedProductsResponse?.products?.length?? 0) == 0) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          AppStrings.related_products,
          style: FontUtils.secondaryFontStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 290,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: relatedProductsResponse?.products?.length?? 0,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final product =  relatedProductsResponse?.products![index];
              return ProductCard(
                imageUrl: product?.thumbnail??'',
                title: product?.title??'',
                price: product!.variants!.isNotEmpty
                    ? CurrencyUtil.appendCurrency(
                    product.variants![0].calculatedPrice!.rawCalculatedAmount!.value!)
                    : '',
                onTapCard: () {
                  PageRouteUtils.pushWithSlide(
                    context,
                    ProductDetailPage(productId: product.id?? ''),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildProductDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product?.title ?? '',
          style: FontUtils.secondaryFontStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Text(
              getDisplayedPrice(),
              style: FontUtils.secondaryFontStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.primary,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Visibility(
              visible: selectedVariant != null &&
                  selectedVariant!.calculatedPrice?.rawCalculatedAmount?.value !=
                      selectedVariant!.calculatedPrice?.rawOriginalAmount?.value,
              child: Text(
                CurrencyUtil.appendCurrency(
                    selectedVariant?.calculatedPrice?.rawOriginalAmount?.value ?? '0'),
                style: FontUtils.secondaryFontStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            )
          ],
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
      final prices = product!.variants!
          .map((v) => double.tryParse(v.calculatedPrice?.rawCalculatedAmount?.value ?? '9999999'))
          .whereType<double>()
          .toList();

      if (prices.isNotEmpty) {
        final lowest = prices.reduce((a, b) => a < b ? a : b);
        return "From ${CurrencyUtil.appendCurrency(lowest.toStringAsFixed(0))}";
      }
    }

    return '';
  }


  ProductResponse.Variant? getSelectedVariant() {
    if (product == null || selectedOptions.isEmpty) return null;

    for (final variant in product!.variants!) {
      final variantOptionIds = variant.options!
          .map((opt) => opt.id)
          .toSet();

      final selectedOptionIds = selectedOptions.values
          .map((optVal) => optVal?.id)
          .toSet();

      final isMatch = selectedOptionIds.length == variantOptionIds.length &&
          variantOptionIds.containsAll(selectedOptionIds);

      if (isMatch) return variant;
    }

    return null;
  }





  Widget buildCartSection() {
    if (product == null ||
        product!.variants == null ||
        product!.variants!.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        if (showVariantSelection) buildDynamicVariantSelection(),
        Text(
          AppStrings.select_qty,
          style: FontUtils.secondaryFontStyle(
              fontSize: 16, fontWeight: FontWeight.bold),
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
            "$title: ${selectedOptions[option.id!]?.value ?? 'Select'}",
            style: FontUtils.secondaryFontStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
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
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(5),
                      color: isSelected ? Colors.black : Colors.white,
                    ),
                    child: Text(
                      optionValue.value ?? '',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500,
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
    });

    print("Selected Variant ID: ${selectedVariant?.id}");
  }


  bool isVariantAvailable(ProductResponse.Variant? variant) {
    return variant != null &&
        (variant.manageInventory == false ||
            variant.allowBackorder! ||
            (variant.inventoryQuantity ?? 0) > 0);
  }

  Widget buildProductDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.description,
          style: FontUtils.secondaryFontStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 10),
        Visibility(
          visible: (product?.metadata?['additional_description'] ?? "").isNotEmpty,
          child: CommonHtmlWidget(htmlContent: product?.metadata?['additional_description'] ?? ""),
        ),
        Visibility(
          visible: product?.metadata == null,
          child: Text(
            product?.description ?? '',
            style: FontUtils.primaryFontStyle(
              fontWeight: FontWeight.w400,
              fontSize: 12,
              color: AppColors.textColor,
            ),
          ),
        ),
      ],
    );
  }

  /*Widget buildShippingAndReturns() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          'Shipping & returns',
          style: FontUtils.gabaritoStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Free standard shipping on all orders within the continental U.S. Expedited shipping options are available at an additional cost. Orders typically ship within 3-5 business days \n \n We offer a 30-day return policy. If you are not completely satisfied with your purchase, you can return the chair for a full refund or exchange, provided it is in its original condition and packaging.',
          style: FontUtils.circularStdStyle(
            fontWeight: FontWeight.w400,
            fontSize: 12,
            color: AppColors.textColor,
          ),
        ),
      ],
    );
  }*/

  Widget buildRatingSection() {
    return RatingWidget(
      onRatingChanged: (rating) => print('Rating: $rating'),
      onSubmit: () => print('Review submitted!'),
    );
  }

  Widget buildReviews() {
    if (reviewResponse == null || reviewResponse!.productReviews!.isEmpty)
      return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.reviews,
          style: FontUtils.secondaryFontStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 12),
        Text('${reviewResponse?.overallRating?.toString()} Ratings' ?? '',
            style: FontUtils.secondaryFontStyle(
                fontWeight: FontWeight.w700,
                fontSize: 24,
                color: AppColors.textColor)),
        const SizedBox(
          height: 12,
        ),
        Text('${reviewResponse?.count?.toString()} Reviews' ?? '',
            style: FontUtils.primaryFontStyle(
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: AppColors.textColor)),
        const SizedBox(
          height: 12,
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: reviewResponse!.productReviews!.length,
          itemBuilder: (context, index) {
            final review = reviewResponse!.productReviews![index];
            return ReviewCard(
              profileImageUrl: AppStrings.profileImageUrl,
              name: review.customer?.firstName ?? '',
              reviewText: review.description!,
              rating: double.parse(review.rating!),
              timestamp: AppUtils.timeAgo(review.updatedAt!),
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
          padding: const EdgeInsets.only(bottom: 20.0),
          child: GestureDetector(
            onTap: () {
              PageRouteUtils.pushWithSlide(context, const CartPage());
            },
            child: ViewCartWidget(
                totalItems: cartItems!, itemImages: cartItemImages!),
          ),
        )
            : const SizedBox(),
      ),
    );
  }

  Widget buildQuantitySelector() {
    return Row(
      children: [
        // Quantity Dropdown with a fixed width
        Container(
          width: 80, // Adjust the width as needed
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<int>(
            value: selectedQuantity,
            isExpanded: true,
            underline: Container(),
            onChanged: (newValue) {
              setState(() {
                selectedQuantity = newValue!;
              });
            },
            items: List.generate(10, (index) => index + 1)
                .map((qty) => DropdownMenuItem(
              value: qty,
              child: Text(
                qty.toString(),
                style: FontUtils.secondaryFontStyle(fontSize: 16),
              ),
            ))
                .toList(),
          ),
        ),
        const SizedBox(width: 10), // Adds spacing between dropdown and button
        // "Add to Cart" button takes more space
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
              selectedVariantId == null ? Colors.grey : AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              minimumSize: const Size(
                  double.infinity, 50), // Ensures height remains the same
            ),
            onPressed: selectedVariantId == null
                ? null
                : () async {
              setState(() => quantityLoading = true);
              if (!isLoggedIn) {
                AppUtils.showToast('Please login to Continue');
                PageRouteUtils.push(context, PhoneNumberPage(redirectPage: ProductDetailPage(productId: widget.productId,isFromLogin: true,),));
                return;
              }
              await addCart(selectedQuantity, selectedVariantId!);
              setState(() => quantityLoading = false);
            },
            child: quantityLoading
                ? CircularProgressIndicator(color: Colors.white)
                : Text(
              selectedVariantId == null
                  ? 'Select Variant'
                  : 'Add to Cart',
              style: FontUtils.primaryFontStyle(
                  fontSize: 18, color: Colors.white),
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
      setState(() {
        product = response.product;
        apiLoading = false;
      });
      if (product != null &&
          product!.variants != null &&
          product!.variants!.isNotEmpty) {
        if (product!.variants!.length == 1 &&
            product!.variants!.first.title!.toLowerCase() ==
                "default variant") {
          setState(() {
            selectedVariantId = product!.variants!.first.id;
            showVariantSelection = false;
          });
        } else {
          setState(() {
            selectedOptions = {};
            for (var option in product!.options ?? []) {
              if ((option.values?.isNotEmpty ?? false)) {
                selectedOptions[option.id!] = option.values!.first;
              }
            }
            showVariantSelection = true;
          });

          Future.delayed(Duration.zero, updateVariant);
        }
      } else {
        setState(() {
          selectedVariantId = product!.id;
          showVariantSelection = false;
        });
      }

      // Call cart API only after product API succeeds
      await getRelatedProductsApi();
      await getCartApi();
      await getProductsInfoApi();

    } catch (e) {
      setState(() => apiLoading = false);
    }
  }

  Future<void> getRelatedProductsApi() async {
    try {
      final apiService = ApiService();
      final response = await apiService.relatedProducts(context, widget.productId);
      setState(() => relatedProductsResponse = response);
    } catch (e) {
      print(e);
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
      print(e);
    }
  }

  Future<void> getProductsInfoApi() async {
    try {
      if(selectedVariantId!=null)
      {
        final apiService = ApiService();
        final response = await apiService.getProductInfo(
            context, widget.productId, selectedVariantId);
        setState(() {
          productInfoResponse = response;
          setState(() {
            isFavorite = productInfoResponse?.productOnWishlist ?? false;
            wishlistId = productInfoResponse?.productWishlistId ?? '';
          });
          apiLoading = false;
        });
        getCartApi();
      }
    } catch (e) {
      setState(() => apiLoading = false);
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

  Future<void> addFavourite() async {
    if (!isLoggedIn) {
      return;
    }

    if (!isFavorite) {
      try {
        final apiService = ApiService();
        WishlistResponse wishlistResponse = await apiService.addFavourite(context, widget.productId);
        setState(() {
          wishlistId = wishlistResponse.wishlistElement?.id;
          isFavorite = true;
        });
      } catch (e) {
        print(e);
      }
    }
    else{
      if (wishlistId != null && wishlistId!.isNotEmpty) {
        removeFavourite(widget.productId, wishlistId!);
      }
    }
  }

  void removeFavourite(String? productId, String? wishlistId) async {
    try {
      final ApiService apiService = ApiService();
      await apiService.deleteFavourite(context, productId, wishlistId);
      if (mounted) {
        setState(() {
          isFavorite = false;
        });
      }
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
      setState(() {
        productPresentInCart = false;
      });
    }
  }

  void emitEvent(CartResponse cartResponse) {
    setState(() {
      cartItems = cartResponse.cart!.items!.length;
      cartItemImages =
          cartResponse.cart!.items!.map((item) => item.thumbnail!).toList();
    });
    eventBus.fire(ViewCartModel(cartResponse.cart!.items!.length,
        cartResponse.cart!.items!.map((item) => item.thumbnail!).toList()));
  }

  Future<void> navigateToCart() async {
    final result = await PageRouteUtils.pushWithSlide(context, CartPage());
    if (result == true) {
      setState(() => apiLoading = true);
      fetchInitialData();
    }
  }

  void removeCart(String cartItemId) async {
    try {
      final ApiService apiService = ApiService();
      await apiService.removeCart(context, cartItemId);
      await getCartApi();
    } catch (e) {
      setState(() {});
      print(e);
    }
  }
}
