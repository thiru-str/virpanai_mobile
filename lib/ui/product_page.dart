import 'package:flutter/material.dart';
import 'package:waioz/model/product_response.dart';
import 'package:waioz/ui/filter_page.dart';
import 'package:waioz/ui/product_detail_page.dart';
import 'package:waioz/ui/widgets/no_orders_widget.dart';
import 'package:waioz/ui/widgets/product_card.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';

import '../api/api_service.dart';
import '../utility/app_assets.dart';
import '../utility/currency_util.dart';
import 'widgets/common_header_app_bar.dart';

class ProductPage extends StatefulWidget {
  final String categoryId;
  final bool isFromBrand;
  const ProductPage({super.key, required this.categoryId, this.isFromBrand = false});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  ProductsResponse? productsResponse;
  bool apiLoading = true;
  TextEditingController searchController = TextEditingController();
  List<Product> filteredProducts = [];
  List<String> selectedCollectionsList = [];
  List<String> selectedCategoriesList = [];

  @override
  void initState() {
    super.initState();
    getProductsApi(categoryIds: widget.categoryId);
    searchController.addListener(onSearchChanged);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void onSearchChanged() {
    setState(() {
      if (searchController.text.isEmpty) {
        filteredProducts = productsResponse?.products ?? [];
      } else {
        filteredProducts = productsResponse?.products
            ?.where((product) =>
            product.title!.toLowerCase().contains(searchController.text.toLowerCase()))
            .toList() ??
            [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHeaderAppBar(
        title: AppStrings.product,
        onBackTap: () {
          Navigator.of(context).pop();
        },
      ),
      backgroundColor: Colors.white,
      body: apiLoading
          ?  Center(
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
              // Search bar with filter icon
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color:AppColors.secondary,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: searchController,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          hintText: AppStrings.search_product,
                          border: InputBorder.none,
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          suffixIcon: searchController.text.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              searchController.clear();
                            },
                          )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      final result = await PageRouteUtils.push(
                        context,
                        FilterPage(
                          parentCategoryId: widget.categoryId,
                          preSelectedCollections: selectedCollectionsList, // ← from your state
                          preSelectedCategories: selectedCategoriesList,   // ← from your state
                        ),
                      );
                      if (result != null && mounted) {
                          print(result);
                          final data = result as Map<String, dynamic>;
                          selectedCategoriesList = List<String>.from(data['selectedCategories'] ?? []);
                          selectedCollectionsList = List<String>.from(data['selectedCollections'] ?? []);
                          final categoryIds = selectedCategoriesList.isNotEmpty
                              ? selectedCategoriesList.join(',')
                              : widget.categoryId;

                          final collectionIds = selectedCollectionsList.join(',');
                          getProductsApi(
                            categoryIds: categoryIds,
                            collectionIds: collectionIds,
                          );
                      }
                    },
                    child: Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(Icons.filter_list, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                 AppStrings.all_product,
                  style: FontUtils.primaryFontStyle(
                    fontSize: 16,
                    color: AppColors.textColor,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Product Grid or Empty View
              filteredProducts.isNotEmpty
                  ? GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Number of columns
                  crossAxisSpacing: 16, // Space between columns
                  mainAxisSpacing: 16, // Space between rows
                  childAspectRatio:
                  (MediaQuery.of(context).size.width / 2) /
                      (265 + 16 + 16 + 32 + 24), // Dynamically calculate aspect ratio
                ),
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];
                  return ProductCard(
                    imageUrl: product.thumbnail!,
                    title: product.title!,
                    price: product.variants!.isNotEmpty
                        ? CurrencyUtil.appendCurrency(
                        product.variants?[0].calculatedPrice?.rawCalculatedAmount?.value?? '')
                        : '',
                    onTapCard: () {
                      PageRouteUtils.pushWithSlide(
                        context,
                        ProductDetailPage(productId: product.id!),
                      );
                    },
                  );
                },
              )
                  : Center(
                child: NoOrdersWidget(
                  message: AppStrings.no_product,
                  buttonText: AppStrings.explore_categories,
                  iconPath: AppAssets.ic_cart_empty,
                  onButtonTap: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void getProductsApi({ String? categoryIds, String? collectionIds,}) async {
    try {
      final ApiService apiService = ApiService();
      productsResponse = widget.isFromBrand
          ? await apiService.listBrands(context, widget.categoryId)
          : await apiService.listProducts(context, categoryIds ?? "", collectionIds ?? "");
      setState(() {
        apiLoading = false;
        filteredProducts = productsResponse?.products ?? [];
      });
    } catch (e) {
      setState(() {
        apiLoading = false;
      });
      print(e);
    }
  }
}
