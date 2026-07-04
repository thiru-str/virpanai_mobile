import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:waioz/model/product_response.dart';
import 'package:waioz/ui/filter_page.dart';
import 'package:waioz/ui/product_detail_page.dart';
import 'package:waioz/ui/widgets/no_orders_widget.dart';
import 'package:waioz/ui/widgets/app_shimmer.dart';
import 'package:waioz/ui/widgets/product_card_4.dart';
import 'package:waioz/ui/widgets/product_view.dart';
import 'package:waioz/ui/widgets/screen_skeletons.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';

import '../api/api_service.dart';
import '../model/wishlist_reponse.dart';
import '../utility/app_assets.dart';
import '../utility/app_utils.dart';
import '../utility/shared_preferences_util.dart';
import 'widgets/common_header_app_bar.dart';

class ProductPage extends StatefulWidget {
  final String categoryId;
  final String collectionId;
  final String tagId;
  final bool isFromBrand;

  const ProductPage(
      {super.key,
      this.categoryId = '',
      this.isFromBrand = false,
      this.collectionId = '',
      this.tagId = ''});

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
  List<String> selectedTagsList = [];
  double? minPrice;
  double? maxPrice;
  String? sortBy;
  FilterSection selectedSection = FilterSection.collections;

  int currentPage = 0;
  final int pageSize = 20;
  bool hasMore = true;
  bool isPaginating = false;
  bool isFilterApplied = false;
  ScrollController scrollController = ScrollController();
  String? productViewType = ProductCardType.productView1.name;
  bool _isLoggedIn = false;
  FavouriteListConfig? _favConfig;
  Set<String> _savedProductIds = {};

  @override
  void initState() {
    super.initState();
    _loadProductViewType();
    _loadFavouriteState();
    getProductsApi(
        categoryIds: widget.categoryId,
        collectionIds: widget.collectionId,
        tagIds: widget.tagId);
    scrollController.addListener(() {
      if (!scrollController.hasClients) return;

      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 200 &&
          hasMore &&
          !isPaginating &&
          !apiLoading) {
        loadMoreProducts();
      }
    });
    searchController.addListener(() {
      _debounceSearch(searchController.text);
    });
  }

  Future<void> _loadProductViewType() async {
    final type = await SharedPreferencesUtil().getString('product_view');
    if (!mounted) return;
    setState(() => productViewType = type);
  }

  Future<void> _loadFavouriteState() async {
    final loggedIn = await AppUtils.isLoggedIn();
    if (!mounted) return;
    setState(() => _isLoggedIn = loggedIn);
    if (!loggedIn) return;
    final api = ApiService();
    try {
      final results = await Future.wait([
        api.getFavouriteListConfig(context),
        api.getSavedItems(context),
      ]);
      final config = results[0] as FavouriteListConfig;
      final saved = results[1] as SavedItemsResponse;
      if (!mounted) return;
      setState(() {
        _favConfig = config;
        _savedProductIds = saved.items.map((i) => i.productId).toSet();
      });
    } catch (_) {}
  }

  void loadMoreProducts() {
    isPaginating = true;
    currentPage++;
    getProductsApi(
      categoryIds: selectedCategoriesList.isNotEmpty
          ? selectedCategoriesList.join(',')
          : widget.categoryId,
      collectionIds: selectedCollectionsList.isNotEmpty
          ? selectedCollectionsList.join(',')
          : widget.collectionId,
      tagIds: selectedTagsList.isNotEmpty
          ? selectedTagsList.join(',')
          : widget.tagId,
      searchString: searchController.text,
      minPrice: minPrice,
      maxPrice: maxPrice,
      sortBy: sortBy,
    );
  }

  String _previousSearchText = '';
  Timer? _debounce;
  int _searchToken = 0;

  void _debounceSearch(String query) {
    final newQuery = query.trim();

    if (newQuery == _previousSearchText) return;

    _previousSearchText = newQuery;

    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      currentPage = 0;
      filteredProducts.clear();

      // Increment the token for each new search
      final currentToken = ++_searchToken;

      getProductsApi(
        categoryIds: selectedCategoriesList.isNotEmpty
            ? selectedCategoriesList.join(',')
            : widget.categoryId,
        tagIds: selectedTagsList.isNotEmpty
            ? selectedTagsList.join(',')
            : widget.tagId,
        collectionIds: selectedCollectionsList.isNotEmpty
            ? selectedCollectionsList.join(',')
            : widget.collectionId,
        searchString: newQuery,
        searchToken: currentToken, // Pass the token to the API call
      );
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    scrollController.dispose();
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CommonHeaderAppBar(
          title: AppStrings.product,
          onBackTap: () {
            Navigator.of(context).pop();
          },
        ),
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.linearGradient),
          child: Padding(
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
                                  icon: const Icon(Icons.clear,
                                      color: Colors.grey),
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
                      debugPrint('min price filter ${minPrice}');
                      debugPrint('max Price filter ${maxPrice}');
                      final result = await PageRouteUtils.push(
                        context,
                        FilterPage(
                          parentCategoryId: widget.categoryId,
                          preSelectedCollections: selectedCollectionsList,
                          preSelectedCategories: selectedCategoriesList,
                          preSelectedTags: selectedTagsList,
                          preMinPrice: minPrice,
                          preMaxPrice: maxPrice,
                          preSortBy: sortBy,
                          preSelectedSection: selectedSection,
                        ),
                      );
                      if (result != null && mounted) {
                        final data = result as Map<String, dynamic>;
                        selectedCategoriesList =
                            List<String>.from(data['selectedCategories'] ?? []);
                        selectedCollectionsList = List<String>.from(
                            data['selectedCollections'] ?? []);
                        selectedTagsList =
                            List<String>.from(data['selectedTags'] ?? []);
                        minPrice = data['minPrice'];
                        maxPrice = data['maxPrice'];
                        sortBy = data['sortBy'];
                        debugPrint('min price product ${minPrice}');
                        debugPrint('max Price product ${maxPrice}');
                        selectedSection =
                            data['selectedSection'] ?? selectedSection;
                        final categoryIds = selectedCategoriesList.isNotEmpty
                            ? selectedCategoriesList.join(',')
                            : widget.categoryId;
                        final collectionIds = selectedCollectionsList.join(',');
                        final tagIds = selectedTagsList.isNotEmpty
                            ? selectedTagsList.join(',')
                            : widget.tagId;
                        currentPage = 0;
                        filteredProducts.clear();
                        getProductsApi(
                          categoryIds: categoryIds.isNotEmpty
                              ? categoryIds
                              : widget.categoryId,
                          collectionIds: collectionIds.isNotEmpty
                              ? collectionIds
                              : widget.collectionId,
                          tagIds: tagIds.isNotEmpty ? tagIds : widget.tagId,
                          searchString: searchController.text,
                          minPrice: minPrice,
                          maxPrice: maxPrice,
                          sortBy: sortBy,
                        );
                        setState(() {
                          isFilterApplied = selectedCategoriesList.isNotEmpty ||
                              selectedCollectionsList.isNotEmpty ||
                              selectedTagsList.isNotEmpty ||
                              (minPrice != null || maxPrice != null) ||
                              sortBy != AppStrings.low_high;
                        });
                      }
                    },
                    child: Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Icon(Icons.filter_list,
                          color: isFilterApplied
                              ? AppColors.primary
                              : Colors.grey),
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
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    MasonryGridView.count(
                      controller: scrollController,
                      padding: EdgeInsets.zero,
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      itemCount:
                          filteredProducts.length + (isPaginating ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == filteredProducts.length && isPaginating) {
                          return const ProductCardSkeleton();
                        }
                        final product = filteredProducts[index];
                        return AppReveal(
                          index: index % 10,
                          child: ProductCard4(
                            product: product,
                            isLoggedIn: _isLoggedIn,
                            favConfig: _favConfig,
                            isFavorite:
                                _savedProductIds.contains(product.id ?? ''),
                            onTapCard: () {
                              PageRouteUtils.pushWithSlide(
                                context,
                                ProductDetailPage(productId: product.id!),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    if (apiLoading && currentPage == 0)
                      Positioned.fill(
                        child: Container(
                          color: Colors.white,
                          child: const ProductGridSkeleton(),
                        ),
                      ),
                    if (!apiLoading && filteredProducts.isEmpty)
                      Positioned.fill(
                        child: Container(
                          color: Colors.white,
                          child: NoOrdersWidget(
                            message: AppStrings.no_product,
                            buttonText: AppStrings.explore_categories,
                            iconPath: AppAssets.ic_cart_empty,
                            onButtonTap: () {},
                            showExplore: false,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  void getProductsApi({
    String? categoryIds,
    String? collectionIds,
    String? tagIds,
    String? searchString,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    int? searchToken, // Add this parameter
  }) async {
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
        tagIds ?? '',
        minPrice,
        maxPrice,
        sortBy,
        searchString ?? '',
        offset: currentPage * pageSize,
        limit: pageSize,
      );

      // Check if this is the most recent search request
      if (searchToken != null && searchToken != _searchToken) {
        // This is an outdated search result, ignore it
        return;
      }

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
      // Only update state if this is the most recent request
      if (searchToken == null || searchToken == _searchToken) {
        if (currentPage > 0) {
          currentPage--;
        }
        setState(() {
          apiLoading = false;
          isPaginating = false;
        });
      }
      print(e);
    }
  }
}
