import 'package:flutter/material.dart';
import 'package:waioz/model/product_detail_response.dart';
import 'package:waioz/model/product_response.dart';
import 'package:waioz/ui/widgets/common_header_app_bar.dart';
import 'package:waioz/ui/widgets/product_card.dart';
import 'package:waioz/ui/widgets/rating_widget.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';

import '../api/api_service.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({super.key,required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  Product? product;
  bool apiLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProductsApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CommonHeaderAppBar(
          onBackTap: (){
            Navigator.pop(context);
          },
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
                child: SingleChildScrollView(
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
                      Text(product!.variants!.isNotEmpty? '\$${product!.variants![0].calculatedPrice!.rawCalculatedAmount!.value!}':'',style: FontUtils.gabaritoStyle(fontWeight: FontWeight.bold,fontSize: 16,color: AppColors.primary)),
                      const SizedBox(height: 15,),
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
                    ],
                  ),
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
      });
    } catch (e) {
      setState(() {
        apiLoading = false;
      });
      print(e);
    }
  }
}
