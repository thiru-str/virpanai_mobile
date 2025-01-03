import 'package:flutter/material.dart';
import 'package:waioz/model/product_response.dart';
import 'package:waioz/ui/product_detail_page.dart';
import 'package:waioz/ui/widgets/product_card.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';

import '../api/api_service.dart';
import '../utility/currency_util.dart';
import 'widgets/common_header_app_bar.dart';

class ProductPage extends StatefulWidget {
  final String categoryId;
  final bool isFromBrand;
  const ProductPage({super.key,required this.categoryId,this.isFromBrand = false});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  ProductsResponse? productsResponse;
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
        appBar:
        CommonHeaderAppBar(
          title: "Products",
          onBackTap: () {
            Navigator.of(context).pop();
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('All products',
                            style: FontUtils.circularStdStyle(
                                fontSize: 16, color: AppColors.textColor)),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Number of columns
                          crossAxisSpacing: 16, // Space between columns
                          mainAxisSpacing: 16, // Space between rows
                          childAspectRatio:
                              0.55, // Adjust this for proper card proportions
                        ),
                        itemCount: productsResponse!.products!.length,
                        itemBuilder: (context, index) {
                          final product = productsResponse!.products![index];
                          return ProductCard(imageUrl: product.thumbnail!, title: product.title!, price: product!.variants!.isNotEmpty? CurrencyUtil.appendCurrency(product!.variants![0].calculatedPrice!.rawCalculatedAmount!.value!):'', onTapCard: (){
                            PageRouteUtils.pushWithSlide(context, ProductDetailPage(productId: product.id!));
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ));
  }

  void getProductsApi() async {
    try {
      final ApiService apiService = ApiService();

      productsResponse = widget.isFromBrand ? await apiService.listBrands(context,widget.categoryId):await apiService.listProducts(context,widget.categoryId);
      setState(() {
        apiLoading = false;
        productsResponse;
      });
    } catch (e) {
      setState(() {
        apiLoading = false;
      });
      print(e);
    }
  }
}
