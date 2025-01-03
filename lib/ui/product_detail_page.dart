import 'package:flutter/material.dart';
import 'package:waioz/model/product_detail_response.dart';
import 'package:waioz/model/product_info_response.dart';
import 'package:waioz/model/product_response.dart' as ProductResponse;
import 'package:waioz/model/review_response.dart';
import 'package:waioz/ui/cart_page.dart';
import 'package:waioz/ui/cart_response.dart';
import 'package:waioz/ui/widgets/cart_button.dart';
import 'package:waioz/ui/widgets/common_header_app_bar.dart';
import 'package:waioz/ui/widgets/product_card.dart';
import 'package:waioz/ui/widgets/quantity_selector.dart';
import 'package:waioz/ui/widgets/rating_widget.dart';
import 'package:waioz/ui/widgets/review_card.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_utils.dart';
import 'package:waioz/utility/currency_util.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';

import '../api/api_service.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({super.key,required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  ProductResponse.Product? product;
  ReviewResponse? reviewResponse;
  ProductInfoResponse? productInfoResponse;
  CartResponse? cartResponse;
  bool apiLoading = true;
  bool reviewApiLoading = true;
  bool hasVariants = false;
  String? varientId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProductsApi();
    getReviewApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CommonHeaderAppBar(
          onBackTap: (){
            Navigator.pop(context);
          },
          onFavTap: (){
            addFavourite();
          },
          isFavorite: productInfoResponse?.productOnWishlist ?? false,
        ),
        backgroundColor: Colors.white,
        body: apiLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Stack(
                  children: [SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 250,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: product!.images!.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              return Container(
                                width: 160,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(
                                      children: [
                                        Container(
                                          height: 250,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: NetworkImage(product!.images![index].url!),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 25,),
                        Text(product!.title!,style: FontUtils.gabaritoStyle(fontWeight: FontWeight.bold,fontSize: 16,color: AppColors.textColor)),
                        const SizedBox(height: 15,),
                        Text(product!.variants!.isNotEmpty? CurrencyUtil.appendCurrency(product!.variants![0].calculatedPrice!.rawCalculatedAmount!.value!):'',style: FontUtils.gabaritoStyle(fontWeight: FontWeight.bold,fontSize: 16,color: AppColors.primary)),
                        const SizedBox(height: 33,),
                      QuantitySelector(
                        initialQuantity: 1,
                        onQuantityChanged: (quantity) {
                          print('Selected Quantity: $quantity');
                          addCart(quantity, product!.variants![0].id!);
                        },
                      ),
                        const SizedBox(height: 26,),
                        Text(product!.description!,style: FontUtils.circularStdStyle(fontWeight: FontWeight.w400,fontSize: 12,color: AppColors.textColor)),
                        const SizedBox(height: 10,),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Shipping & returns',style: FontUtils.gabaritoStyle(fontWeight: FontWeight.bold,fontSize: 16,color: AppColors.textColor)),
                              const SizedBox(height: 10,),
                              Text('Free standard shipping and free 60-day returns',style: FontUtils.circularStdStyle(fontWeight: FontWeight.w400,fontSize: 12,color: AppColors.textColor))
                            ],
                          ),
                        ),
                        const SizedBox(height: 15,),
                        RatingWidget(
                          onRatingChanged: (rating) {
                            print('Rating: $rating');
                          },
                          onSubmit: () {
                            print('Review submitted!');
                          },
                        ),
                        const SizedBox(height: 15,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Reviews',style: FontUtils.gabaritoStyle(fontWeight: FontWeight.bold,fontSize: 16,color: AppColors.textColor)),
                            const SizedBox(height: 12,),
                            Text('4.5 Ratings',style: FontUtils.circularStdStyle(fontWeight: FontWeight.w700,fontSize: 12,color: AppColors.textColor)),
                            const SizedBox(height: 12,),
                            Text('213 reviews',style: FontUtils.circularStdStyle(fontWeight: FontWeight.w400,fontSize: 12,color: AppColors.textColor)),
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: reviewResponse!=null?reviewResponse!.productReviews!.length : 0,
                              itemBuilder: (context, index) {
                                final review = reviewResponse!.productReviews![index];
                                return ReviewCard(profileImageUrl: 'profileImageUrl', name: review.customer!=null?review.customer!.firstName!:'', reviewText: review.description!, rating: double.parse(review.rating!), timestamp: AppUtils.timeAgo(review.updatedAt!));
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 70,)
                      ],
                    ),
                  ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: CartButton(amount: '\$148', title: 'Add to Cart', onPressed: (){
                        PageRouteUtils.push(context, CartPage());
                      }),
                    )
                  ],
                ),
              ));
  }



  void getProductsApi() async {
    try {
      final ApiService apiService = ApiService();
      ProductDetailReponse productDetailReponse = await apiService.productDetail(context,widget.productId);
      setState(() {
        apiLoading = false;
        product = productDetailReponse.product;
        hasVariants = product!.variants!.length> 1;
        varientId = product?.variants?.first.id ?? '0';
        getProductsInfoApi();
      });
    } catch (e) {
      setState(() {
        apiLoading = false;
      });
      print(e);
    }
  }

  void getReviewApi() async {
    print("getReviewApi");
    try {
      final ApiService apiService = ApiService();
      reviewResponse = await apiService.getProductReviews(context,widget.productId);
      setState(() {
        reviewApiLoading = false;
        reviewResponse;
      });
    } catch (e) {
      setState(() {
        reviewApiLoading = false;
      });
      print(e);
    }
  }

  void getProductsInfoApi() async {
    try {
      final ApiService apiService = ApiService();
      productInfoResponse = await apiService.getProductInfo(context, widget.productId, varientId);
      setState(() {
        apiLoading = false;
      });
    } catch (e) {
      setState(() {
        apiLoading = false;
      });
      print(e);
    }
  }

  void addCart(int qty,String variantId) async {
    try {
      final ApiService apiService = ApiService();
      cartResponse = await apiService.addCart(context,qty,variantId);
      setState(() {
        reviewApiLoading = false;
        cartResponse;
      });
    } catch (e) {
      setState(() {
        reviewApiLoading = false;
      });
      print(e);
    }
  }

  void addFavourite() async {
    try {
      final ApiService apiService = ApiService();
      await apiService.addFavourite(context,widget.productId);
      setState(() {

      });
    } catch (e) {
      setState(() {
      });
      print(e);
    }
  }
}
