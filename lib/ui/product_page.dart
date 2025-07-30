import 'dart:async';

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

  const ProductPage(
      {super.key, required this.categoryId, this.isFromBrand = false});

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

  int currentPage = 0;
  final int pageSize = 10;
  bool hasMore = true;
  bool isPaginating = false;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getProductsApi(categoryIds: widget.categoryId);
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent &&
          hasMore &&
          !isPaginating) {
        loadMoreProducts();
      }
    });
    searchController.addListener(() {
      _debounceSearch(searchController.text);
    });
  }

  void loadMoreProducts() {
    isPaginating = true;
    currentPage++;
    getProductsApi(
      categoryIds: widget.categoryId,
      collectionIds: selectedCollectionsList.join(','),
      searchString: searchController.text,
    );
  }

  Timer? _debounce;

  void _debounceSearch(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      currentPage = 0;
      filteredProducts.clear();
      getProductsApi(
        categoryIds: widget.categoryId,
        collectionIds: selectedCollectionsList.join(','),
        searchString: query,
      );
    });
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
            ?.where((product) => product.title!
            .toLowerCase()
            .contains(searchController.text.toLowerCase()))
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar + Filter icon
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: searchController,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: AppStrings.search_product,
                        border: InputBorder.none,
                        prefixIcon:
                        const Icon(Icons.search, color: Colors.grey),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                          icon:
                          const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () => searchController.clear(),
                        )
                            : null,
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16),
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
                        preSelectedCollections: selectedCollectionsList,
                        preSelectedCategories: selectedCategoriesList,
                      ),
                    );
                    if (result != null && mounted) {
                      final data = result as Map<String, dynamic>;
                      selectedCategoriesList =
                      List<String>.from(data['selectedCategories'] ?? []);
                      selectedCollectionsList =
                      List<String>.from(data['selectedCollections'] ?? []);
                      final categoryIds = selectedCategoriesList.isNotEmpty
                          ? selectedCategoriesList.join(',')
                          : widget.categoryId;
                      final collectionIds = selectedCollectionsList.join(',');
                      currentPage = 0;
                      filteredProducts.clear();
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

            // Main Content Area
            Expanded(
              child: Builder(
                builder: (_) {
                  if (apiLoading && currentPage == 0) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (filteredProducts.isEmpty) {
                    return NoOrdersWidget(
                      message: AppStrings.no_product,
                      buttonText: AppStrings.explore_categories,
                      iconPath: AppAssets.ic_cart_empty,
                      onButtonTap: () {},
                    );
                  }

                  return GridView.builder(
                    controller: scrollController,
                    padding: EdgeInsets.zero,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio:
                      (MediaQuery.of(context).size.width / 2) /
                          (265 + 16 + 16 + 32 + 24),
                    ),
                    itemCount: filteredProducts.length + (isPaginating ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == filteredProducts.length && isPaginating) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(color: AppColors.primary,),
                          ),
                        );
                      }

                      final product = filteredProducts[index];
                      return ProductCard(
                        imageUrl: product.thumbnail!,
                        title: product.title!,
                        price: product.variants!.isNotEmpty
                            ? CurrencyUtil.appendCurrency(product
                            .variants?[0]
                            .calculatedPrice
                            ?.rawCalculatedAmount
                            ?.value ??
                            '')
                            : '',
                        onTapCard: () {
                          PageRouteUtils.pushWithSlide(
                            context,
                            ProductDetailPage(productId: product.id!),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void getProductsApi({String? categoryIds, String? collectionIds, String? searchString}) async {
    if (currentPage == 0) {
      setState(() {
        apiLoading = true;
      });
    } else {
      setState(() {
        isPaginating = true;
      });
    }

    try {
      final ApiService apiService = ApiService();
      final response = await apiService.listProducts(
        context,
        categoryIds ?? '',
        collectionIds ?? '',
        searchString ?? '',
        offset: currentPage * pageSize,
        limit: pageSize,
      );

      setState(() {
        apiLoading = false;
        isPaginating = false;

        if (currentPage == 0) {
          filteredProducts = response.products ?? [];
        } else {
          filteredProducts.addAll(response.products ?? []);
        }

        hasMore = (response.products?.length ?? 0) == pageSize;
      });
    } catch (e) {
      setState(() {
        apiLoading = false;
        isPaginating = false;
      });
      print(e);
    }
  }

}
