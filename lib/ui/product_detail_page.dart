import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:waioz/model/product_info_response.dart';
import 'package:waioz/model/product_response.dart' as ProductResponse;
import 'package:waioz/model/review_response.dart';
import 'package:waioz/model/view_cart_model.dart';
import 'package:waioz/ui/cart_page.dart';
import 'package:waioz/ui/cart_response.dart';
import 'package:waioz/ui/widgets/cart_button.dart';
import 'package:waioz/ui/widgets/common_header_app_bar.dart';
import 'package:waioz/ui/widgets/quantity_selector.dart';
import 'package:waioz/ui/widgets/rating_widget.dart';
import 'package:waioz/ui/widgets/review_card.dart';
import 'package:waioz/ui/widgets/view_cart.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_logger.dart';
import 'package:waioz/utility/app_utils.dart';
import 'package:waioz/utility/currency_util.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';

import '../api/api_service.dart';
import '../utility/full_screen_carousel.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage>  with SingleTickerProviderStateMixin {
  ProductResponse.Product? product;
  ReviewResponse? reviewResponse;
  ProductInfoResponse? productInfoResponse;
  CartResponse? cartResponse;

  bool apiLoading = true;
  bool quantityLoading = false;
  bool hasVariants = false;
  bool? productPresentInCart; // Changed to nullable to handle loading state
  bool isFavorite = false;

  late AnimationController _animationController;
  late Animation<Offset> _animation;

  ProductResponse.Value? selectedColor;
  ProductResponse.Value? selectedSize;

  String? selectedVariantId;
  int selectedQuantity = 1;

  bool showVariantSelection = false;

  int? cartItems;
  List<String>? cartItemImages;
  late StreamSubscription<ViewCartModel> _eventSubscription;

  @override
  void initState() {
    super.initState();
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
    _eventSubscription.cancel(); // Cancel the subscription to prevent memory leaks
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
        onBackTap: () => Navigator.pop(context),
        onFavTap: addFavourite,
        isFavorite: isFavorite, // Pass the updated favorite status here
      ),
      backgroundColor: Colors.white,
      body: apiLoading
          ?  Center(
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
                              /*buildShippingAndReturns(),
                        const SizedBox(height: 15),*/
                              buildReviews(),
                              const SizedBox(height: 70),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              buildBottomButton()
              ]
                  ),
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
              if(product!.images!.isNotEmpty) {
                PageRouteUtils.pushWithFade(context, FullscreenImageCarousel(
                  imageUrls: product!.images!,
                  initialIndex: index,
                ));
              }
            },
            child: Container(
              width: 160,
              decoration: BoxDecoration(color: AppColors.secondary),
              child: Image.network(
                product!.images![index].url!,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildProductDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product?.title ?? '',
          style: FontUtils.secondaryFontStyle1(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Text(
              product?.variants?.isNotEmpty ?? false
                  ? CurrencyUtil.appendCurrency(product!.variants!.first.calculatedPrice!.rawCalculatedAmount!.value!)
                  : '',
              style: FontUtils.secondaryFontStyle1(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 10,),
            Visibility(
              visible: product!.variants!.first.calculatedPrice!.rawCalculatedAmount!.value! != product!.variants!.first.calculatedPrice!.rawOriginalAmount!.value!,
              child: Text(
                product?.variants?.isNotEmpty ?? false
                    ? CurrencyUtil.appendCurrency(product!.variants!.first.calculatedPrice!.rawOriginalAmount!.value!)
                    : '',
                style: FontUtils.secondaryFontStyle1(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primary,
                  decoration: TextDecoration.lineThrough
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildCartSection() {
    if (product == null || product!.variants == null || product!.variants!.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),


        if (showVariantSelection) ...[
          // ✅ Separate Color and Size selections (No combined title)
          buildColorSelection(),
          const SizedBox(height: 15),
          buildSizeSelection(),
          const SizedBox(height: 15),
        ],

        // ✅ Quantity Selector is always visible
        Text(
          'Select Qty',
          style: FontUtils.secondaryFontStyle1(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        buildQuantitySelector(),
        const SizedBox(height: 10),
        // Quantity selector (Dropdown)

      ],
    );
  }

  void updateVariant() {
    if (selectedColor == null || selectedSize == null) {
      return; // Prevent clearing selection
    }

    String selectedColorValue = selectedColor?.value ?? "";
    String selectedSizeValue = selectedSize?.value ?? "";

    print("Selected Color: $selectedColorValue");
    print("Selected Size: $selectedSizeValue");

    ProductResponse.Variant? variant;
    try {
      variant = product!.variants!.firstWhere((v) {
        bool hasColor = v.options!.any((opt) =>
        opt.option?.title?.toLowerCase() == "color" && opt.value == selectedColorValue);

        bool hasSize = v.options!.any((opt) =>
        opt.option?.title?.toLowerCase() == "size" && opt.value == selectedSizeValue);

        return hasColor && hasSize;
      });
    } catch (e) {
      print("No matching variant found for Color: $selectedColorValue, Size: $selectedSizeValue");
      variant = null; // Ensure variant is null if not found
    }

    setState(() {
      if (variant != null && isVariantAvailable(variant)) {
        selectedVariantId = variant.id;
      } else {
        selectedVariantId = null; // Disable add to cart button
      }
    });

    print('Selected Variant ID: ${selectedVariantId ?? "None"}');
  }

  bool isVariantAvailable(ProductResponse.Variant? variant) {
    return variant != null && (variant.manageInventory == false ||
        variant.allowBackorder! ||
        (variant.inventoryQuantity ?? 0) > 0);
  }



  Widget buildProductDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: FontUtils.secondaryFontStyle1(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          product?.description ?? '',
          style: FontUtils.primaryFontStyle(
            fontWeight: FontWeight.w400,
            fontSize: 12,
            color: AppColors.textColor,
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
    if (reviewResponse == null || reviewResponse!.productReviews!.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reviews',
          style: FontUtils.secondaryFontStyle1(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 12),
        Text('${reviewResponse?.overallRating?.toString()} Ratings'??'',style: FontUtils.secondaryFontStyle1(fontWeight: FontWeight.w700,fontSize: 24,color: AppColors.textColor)),
        const SizedBox(height: 12,),
        Text('${reviewResponse?.count?.toString()} Reviews'??'',style: FontUtils.primaryFontStyle(fontWeight: FontWeight.w400,fontSize: 12,color: AppColors.textColor)),
        const SizedBox(height: 12,),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: reviewResponse!.productReviews!.length,
          itemBuilder: (context, index) {
            final review = reviewResponse!.productReviews![index];
            return ReviewCard(
              profileImageUrl: 'profileImageUrl',
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
      visible: cartItems!= null && cartItems != 0,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: cartItems!=null ?Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: GestureDetector(
            onTap: (){
              PageRouteUtils.pushWithSlide(context, const CartPage());
            },
            child: ViewCartWidget(
                totalItems: cartItems!,
                itemImages:  cartItemImages!
            ),
          ),
        ): const SizedBox(),
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
                style: FontUtils.secondaryFontStyle1(fontSize: 16),
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
              backgroundColor: selectedVariantId == null ? Colors.grey : AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              minimumSize: const Size(double.infinity, 50), // Ensures height remains the same
            ),
            onPressed: selectedVariantId == null
                ? null
                : () async {
              setState(() => quantityLoading = true);
              await addCart(selectedQuantity, selectedVariantId!);
              setState(() => quantityLoading = false);
            },
            child: quantityLoading
                ? CircularProgressIndicator(color: Colors.white)
                : Text(
              selectedVariantId == null ? 'Select Variant' : 'Add to Cart',
              style: FontUtils.primaryFontStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildColorSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Color: ${selectedColor?.value ?? 'Select'}",
          style: FontUtils.secondaryFontStyle1(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: product!.options!
              .firstWhere((opt) => opt.title!.toLowerCase() == "color")
              .values!
              .map((option) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedColor = option;
                  updateVariant();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: selectedColor == option ? AppColors.primary : Colors.grey,
                    width: selectedColor == option ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(option.value!, style: FontUtils.secondaryFontStyle1(fontSize: 14)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget buildSizeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Size: ${selectedSize?.value ?? 'Select'}",
          style: FontUtils.secondaryFontStyle1(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: product!.options!
              .firstWhere((opt) => opt.title!.toLowerCase() == "size")
              .values!
              .map((option) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedSize = option;
                  updateVariant();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: selectedSize == option ? AppColors.primary : Colors.grey,
                    width: selectedSize == option ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(option.value!, style: FontUtils.secondaryFontStyle1(fontSize: 14)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }




  Future<void> getProductsApi() async {
    try {
      final apiService = ApiService();
      final response = await apiService.productDetail(context, widget.productId);
      setState(() {
        product = response.product;
        apiLoading = false;
      });
      if (product != null && product!.variants != null && product!.variants!.isNotEmpty) {

        if (product!.variants!.length == 1 && product!.variants!.first.title!.toLowerCase() == "default variant") {
          setState(() {
            selectedVariantId = product!.variants!.first.id;
            showVariantSelection = false;
          });
        } else {
          setState(() {
            selectedColor = product!.options!.firstWhere((opt) => opt.title!.toLowerCase() == "color").values!.first;
            selectedSize = product!.options!.firstWhere((opt) => opt.title!.toLowerCase() == "size").values!.first;
            showVariantSelection = true; // Show variant selection
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
      await getCartApi();
      await getProductsInfoApi();
    } catch (e) {
      setState(() => apiLoading = false);
    }
  }



  Future<void> getReviewApi() async {
    try {
      final apiService = ApiService();
      final response = await apiService.getProductReviews(context, widget.productId);
      setState(() => reviewResponse = response);
    } catch (e) {
      print(e);
    }
  }

  Future<void> getProductsInfoApi() async {
    try {
      final apiService = ApiService();
      final response = await apiService.getProductInfo(context, widget.productId, selectedVariantId);
      setState(() {
        productInfoResponse = response;
        setState(() {
          isFavorite = productInfoResponse?.productOnWishlist ?? false;
        });
        apiLoading = false;
      });
      getCartApi();
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
    if (!isFavorite){
      try {
        final apiService = ApiService();
        await apiService.addFavourite(context, widget.productId);
        setState(() {
          isFavorite = true;
        });
      } catch (e) {
        print(e);
      }
    }

  }

  Future<void> goToCart() async {

  }

  Future<void> getCartApi() async {
    try {
      final apiService = ApiService();
      final response = await apiService.getCart(context);
      setState(() {
        cartResponse = response;
        productPresentInCart = cartResponse?.cart?.items?.any((item) => item.variantId == selectedVariantId) ?? false;
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
      cartItemImages = cartResponse.cart!.items!.map((item) => item.thumbnail!).toList();
    });
    eventBus.fire(ViewCartModel(cartResponse.cart!.items!.length,cartResponse.cart!.items!.map((item) => item.thumbnail!).toList()));
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
      await apiService.removeCart(context,cartItemId);
      await getCartApi();
    } catch (e) {
      setState(() {

      });
      print(e);
    }
  }

}

