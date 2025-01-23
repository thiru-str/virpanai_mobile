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
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_logger.dart';
import 'package:waioz/utility/app_utils.dart';
import 'package:waioz/utility/currency_util.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';

import '../api/api_service.dart';

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
  String? variantId;
  bool? productPresentInCart; // Changed to nullable to handle loading state
  bool isFavorite = false;

  late AnimationController _animationController;
  late Animation<Offset> _animation;

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }


  Future<void> fetchInitialData() async {
    getProductsApi();
    getReviewApi();
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
          ? const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      )
          : Column(
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
                    buildShippingAndReturns(),
                    const SizedBox(height: 15),
                    buildReviews(),
                    const SizedBox(height: 70),
                  ],
                ),
              ),
            ),
          ),
          // Bottom button that sticks to the bottom
          buildBottomButton(),
        ],
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
          return Container(
            width: 160,
            decoration: BoxDecoration(color: Colors.grey[200]),
            child: Image.network(
              product!.images![index].url!,
              height: 250,
              fit: BoxFit.cover,
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
          style: FontUtils.gabaritoStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          product?.variants?.isNotEmpty ?? false
              ? CurrencyUtil.appendCurrency(product!.variants!.first.calculatedPrice!.rawCalculatedAmount!.value!)
              : '',
          style: FontUtils.gabaritoStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget buildCartSection() {
    /*if (productPresentInCart == null) {
      // Show a placeholder while determining cart state
      return apiLoading? const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }*/
    if (productPresentInCart == null || !productPresentInCart!) return const SizedBox();
    return Column(
      children: [
        const SizedBox(height: 15),
        if (quantityLoading)
          const Center(child: CircularProgressIndicator(color: AppColors.primary))
        else
          QuantitySelector(
            initialQuantity: cartResponse?.cart?.items
                ?.firstWhere((item) => item.variantId == variantId, orElse: null)
                ?.quantity ??
                1,
            onQuantityChanged: (quantity) async {
              if(quantity == 0)
                {
                  try {
                    final cartItem = cartResponse?.cart?.items?.firstWhere(
                          (item) => item.variantId == variantId,
                          orElse: null);
                    setState(() => quantityLoading = true);
                    removeCart(cartItem!.id!);
                  } catch (e) {
                    print(e);
                    setState(() => quantityLoading = false);
                  } finally {
                    //setState(() => quantityLoading = false);
                  }
                }
              else {
                await updateQuantity(quantity);
              }
            },
          ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget buildProductDescription() {
    return Text(
      product?.description ?? '',
      style: FontUtils.circularStdStyle(
        fontWeight: FontWeight.w400,
        fontSize: 12,
        color: AppColors.textColor,
      ),
    );
  }

  Widget buildShippingAndReturns() {
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
  }

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
          style: FontUtils.gabaritoStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 12),
        Text('${reviewResponse?.overallRating?.toString()} Ratings'??'',style: FontUtils.gabaritoStyle(fontWeight: FontWeight.w700,fontSize: 24,color: AppColors.textColor)),
        const SizedBox(height: 12,),
        Text('${reviewResponse?.count?.toString()} Reviews'??'',style: FontUtils.circularStdStyle(fontWeight: FontWeight.w400,fontSize: 12,color: AppColors.textColor)),
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
    if (productPresentInCart == null) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    if(!productPresentInCart!)
      // Start the animation when the widget is built
      _animationController.forward();

    return SlideTransition(
      position: _animation,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: productPresentInCart!
            ? CartButton(
          amount: CurrencyUtil.appendCurrency(
              cartResponse?.cart?.subtotal?.toStringAsFixed(2) ?? ''),
          title: 'Go to Cart',
          onPressed: navigateToCart,
        )
            : Padding(
          padding:
          const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              minimumSize: const Size(double.infinity, 56),
            ),
            onPressed: () async {
              setState(() => productPresentInCart = true);
              await addCart(1, product?.variants?.first.id ?? '');
            },
            child: Text(
              'Add to Cart',
              style: FontUtils.circularStdStyle(
                  fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }


  Future<void> getProductsApi() async {
    try {
      final apiService = ApiService();
      final response = await apiService.productDetail(context, widget.productId);
      setState(() {
        product = response.product;
        variantId = product?.variants?.first.id;
        apiLoading = false;
      });

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
      final response = await apiService.getProductInfo(context, widget.productId, variantId);
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
      await getCartApi(); // Fetch updated cart details
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

  Future<void> getCartApi() async {
    try {
      final apiService = ApiService();
      final response = await apiService.getCart(context);
      setState(() {
        cartResponse = response;
        productPresentInCart = cartResponse?.cart?.items?.any((item) => item.variantId == variantId) ?? false;
        AppLogger.print('productPresentInCart', '$productPresentInCart');
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
    eventBus.fire(ViewCartModel(cartResponse.cart!.items!.length,cartResponse.cart!.items!.map((item) => item.thumbnail!).toList()));
  }

  Future<void> navigateToCart() async {
    final result = await PageRouteUtils.pushWithSlide(context, CartPage());
    if (result == true) {
      setState(() => apiLoading = true);
      fetchInitialData();
    }
  }

  Future<void> updateQuantity(int newQuantity) async {
    try {
      if (variantId == null) return;

      final apiService = ApiService();
      setState(() => quantityLoading = true);

      // Find the current quantity of the product in the cart
      final currentQuantity = cartResponse?.cart?.items
          ?.firstWhere((item) => item.variantId == variantId, orElse: null)
          ?.quantity ??
          0;

      // Calculate the difference to adjust the quantity
      final quantityDifference = newQuantity - currentQuantity;
      await apiService.addCart(context, quantityDifference, variantId!);

      // Fetch updated cart data
      await getCartApi();
    } catch (e) {
      print(e);
    } finally {
      setState(() => quantityLoading = false);
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

