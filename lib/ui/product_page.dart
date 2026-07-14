import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:waioz/model/product_categories_response.dart';
import 'package:waioz/model/product_response.dart';
import 'package:waioz/ui/filter_page.dart';
import 'package:waioz/ui/product_detail_page.dart';
import 'package:waioz/ui/widgets/no_orders_widget.dart';
import 'package:waioz/ui/widgets/app_shimmer.dart';
import 'package:waioz/ui/widgets/product_view.dart';
import 'package:waioz/ui/widgets/screen_skeletons.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';
import 'package:waioz/utility/ui_typography.dart';

import '../api/api_service.dart';
import '../utility/app_assets.dart';
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
  FilterSection selectedSection = FilterSection.price;

  int currentPage = 0;
  final int pageSize = 20;
  bool hasMore = true;
  bool isPaginating = false;
  bool isFilterApplied = false;
  ScrollController scrollController = ScrollController();
  String? productViewType = ProductCardType.productView1.name;

  List<ProductCategory> _mainCategories = [];
  List<ProductCategory> _allSubs = [];
  String? _selectedMainId;
  String? _selectedSubId;
  bool _chipSelectionControlsCategory = false;
  final GlobalKey _selectedMainKey = GlobalKey();
  final GlobalKey _selectedSubKey = GlobalKey();
  final ScrollController _mainRowController = ScrollController();
  final ScrollController _subRowController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadProductViewType();
    _loadCategories();
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
    setState(() {
      productViewType = type;
    });
  }

  void loadMoreProducts() {
    isPaginating = true;
    currentPage++;
    getProductsApi(
      categoryIds: _effectiveCategoryIds(),
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
        categoryIds: _effectiveCategoryIds(),
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
    _mainRowController.dispose();
    _subRowController.dispose();
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

  double? _extractAddressCoordinate(
    Map<String, dynamic>? address,
    String key,
  ) {
    final metadata = address?['metadata'];
    if (metadata is! Map) return null;
    return double.tryParse(metadata[key]?.toString() ?? '');
  }

  Future<void> _loadCategories() async {
    try {
      final response = await ApiService().productCategories(context);
      if (!mounted) return;

      final allCategories = response.productCategories ?? [];
      final mainCategories = allCategories
          .where((category) =>
              category.parentCategoryId == null ||
              category.parentCategoryId!.isEmpty)
          .toList();
      final subCategories = <ProductCategory>[];

      for (final category in allCategories) {
        if (category.parentCategoryId != null &&
            category.parentCategoryId!.isNotEmpty) {
          subCategories.add(category);
        }

        for (final child in category.categoryChildren ?? <ProductCategory>[]) {
          child.parentCategoryId ??= category.id;
          if (child.parentCategoryId!.isEmpty) {
            child.parentCategoryId = category.id;
          }
          if (!subCategories.any((sub) => sub.id == child.id)) {
            subCategories.add(child);
          }
        }
      }

      String? selectedMainId;
      String? selectedSubId;
      final seedIds = <String>[
        if (selectedCategoriesList.isNotEmpty) ...selectedCategoriesList,
        if (widget.categoryId.isNotEmpty) widget.categoryId,
      ];
      final lookupPool = [...mainCategories, ...subCategories];

      for (final id in seedIds) {
        final match = lookupPool.where((category) => category.id == id);
        if (match.isEmpty) continue;

        final category = match.first;
        if (category.parentCategoryId == null ||
            category.parentCategoryId!.isEmpty) {
          selectedMainId = category.id;
        } else {
          selectedSubId = category.id;
          selectedMainId = category.parentCategoryId;
        }
      }

      setState(() {
        _mainCategories = mainCategories;
        _allSubs = subCategories;
        _selectedMainId = selectedMainId;
        _selectedSubId = selectedSubId;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _ensureSelectedChipVisible();
      });
    } catch (_) {}
  }

  List<ProductCategory> get _visibleSubCategories {
    if (_selectedMainId == null) return _allSubs;
    return _allSubs
        .where((category) => category.parentCategoryId == _selectedMainId)
        .toList();
  }

  String _effectiveCategoryIds() {
    if (selectedCategoriesList.isNotEmpty) {
      return selectedCategoriesList.join(',');
    }
    return _chipSelectionControlsCategory ? '' : widget.categoryId;
  }

  void _ensureSelectedChipVisible({bool main = true, bool sub = true}) {
    if (!mounted) return;

    if (main) {
      _scrollRowToSelected(
        controller: _mainRowController,
        selectedKey: _selectedMainKey,
        selectedId: _selectedMainId,
        items: _mainCategories,
        averageChipWidth: 110,
      );
    }

    if (sub) {
      _scrollRowToSelected(
        controller: _subRowController,
        selectedKey: _selectedSubKey,
        selectedId: _selectedSubId,
        items: _visibleSubCategories,
        averageChipWidth: 90,
      );
    }
  }

  void _scrollRowToSelected({
    required ScrollController controller,
    required GlobalKey selectedKey,
    required String? selectedId,
    required List<ProductCategory> items,
    required double averageChipWidth,
  }) {
    if (selectedId == null || !controller.hasClients) return;

    final index = items.indexWhere((category) => category.id == selectedId);
    if (index < 0) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final estimatedOffset = (index + 1) * averageChipWidth - screenWidth / 2;
    controller.jumpTo(
      estimatedOffset.clamp(0.0, controller.position.maxScrollExtent),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final selectedContext = selectedKey.currentContext;
      if (selectedContext == null) return;
      Scrollable.ensureVisible(
        selectedContext,
        alignment: 0.5,
        duration: Duration.zero,
      );
    });
  }

  void _onMainCategoryTap(String? id) {
    setState(() {
      _selectedMainId = id;
      _selectedSubId = null;
    });
    _refetchForSelectedChip();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureSelectedChipVisible(main: true, sub: false);
    });
  }

  void _onSubCategoryTap(String? id) {
    setState(() {
      _selectedSubId = id;
    });
    _refetchForSelectedChip();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureSelectedChipVisible(main: false, sub: true);
    });
  }

  void _refetchForSelectedChip() {
    final categoryIds = <String>[];
    if (_selectedSubId != null) {
      categoryIds.add(_selectedSubId!);
    } else if (_selectedMainId != null) {
      categoryIds.add(_selectedMainId!);
    }

    setState(() {
      selectedCategoriesList = categoryIds;
      _chipSelectionControlsCategory = true;
      currentPage = 0;
      hasMore = true;
      filteredProducts.clear();
      apiLoading = true;
      isFilterApplied = categoryIds.isNotEmpty ||
          selectedCollectionsList.isNotEmpty ||
          selectedTagsList.isNotEmpty ||
          minPrice != null ||
          maxPrice != null ||
          sortBy != null;
    });

    getProductsApi(
      categoryIds: categoryIds.isNotEmpty ? categoryIds.join(',') : null,
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

  Widget _mainCategoryChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: Alignment.center,
        color: selected ? const Color(0xFFD5E5C5) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Text(
          label,
          style: FontUtils.primaryFontStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: AppColors.textColor,
          ),
        ),
      ),
    );
  }

  Widget _subCategoryChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: IntrinsicWidth(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: FontUtils.primaryFontStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textColor,
                  ),
                ),
              ),
              Container(
                height: 3,
                color: selected ? AppColors.primary : Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChipRows() {
    if (_mainCategories.isEmpty) return const SizedBox.shrink();

    final subCategories = _visibleSubCategories;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: const Color(0xFFF5F5F7),
            height: 38,
            child: ListView.separated(
              controller: _mainRowController,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: _mainCategories.length + 1,
              separatorBuilder: (_, __) => const SizedBox.shrink(),
              itemBuilder: (_, index) {
                if (index == 0) {
                  return KeyedSubtree(
                    key: _selectedMainId == null ? _selectedMainKey : null,
                    child: _mainCategoryChip(
                      label: 'All',
                      selected: _selectedMainId == null,
                      onTap: () => _onMainCategoryTap(null),
                    ),
                  );
                }

                final category = _mainCategories[index - 1];
                return KeyedSubtree(
                  key: _selectedMainId == category.id ? _selectedMainKey : null,
                  child: _mainCategoryChip(
                    label: category.name ?? '',
                    selected: _selectedMainId == category.id,
                    onTap: () => _onMainCategoryTap(category.id),
                  ),
                );
              },
            ),
          ),
          if (subCategories.isNotEmpty) ...[
            Container(
              height: 1,
              color: const Color(0xFFEEEFF1),
            ),
            Container(
              color: Colors.white,
              height: 38,
              child: ListView.separated(
                controller: _subRowController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 4),
                itemCount: subCategories.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (_, index) {
                  if (index == 0) {
                    return KeyedSubtree(
                      key: _selectedSubId == null ? _selectedSubKey : null,
                      child: _subCategoryChip(
                        label: 'All',
                        selected: _selectedSubId == null,
                        onTap: () => _onSubCategoryTap(null),
                      ),
                    );
                  }

                  final category = subCategories[index - 1];
                  return KeyedSubtree(
                    key: _selectedSubId == category.id ? _selectedSubKey : null,
                    child: _subCategoryChip(
                      label: category.name ?? '',
                      selected: _selectedSubId == category.id,
                      onTap: () => _onSubCategoryTap(category.id),
                    ),
                  );
                },
              ),
            ),
            Container(
              height: 1,
              color: const Color(0xFFEEEFF1),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9FB),
        appBar: CommonHeaderAppBar(
          title: AppStrings.product,
          onBackTap: () {
            Navigator.of(context).pop();
          },
        ),
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
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EC)),
                      ),
                      child: TextField(
                        controller: searchController,
                        textAlignVertical: TextAlignVertical.center,
                        style: FontUtils.primaryFontStyle(
                            fontSize: 14, color: AppColors.textColor),
                        decoration: InputDecoration(
                          hintText: AppStrings.search_product,
                          hintStyle: UiTypography.searchHint(),
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search,
                              color: Colors.grey.shade500, size: 22),
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
                  const SizedBox(width: 12),
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
                        final categoryIds = _effectiveCategoryIds();
                        final collectionIds = selectedCollectionsList.join(',');
                        final tagIds = selectedTagsList.isNotEmpty
                            ? selectedTagsList.join(',')
                            : widget.tagId;
                        currentPage = 0;
                        filteredProducts.clear();
                        getProductsApi(
                          categoryIds: categoryIds,
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
                              (sortBy != null && sortBy!.isNotEmpty);
                        });
                      }
                    },
                    child: Container(
                      height: 52,
                      width: 52,
                      decoration: BoxDecoration(
                        color:
                            isFilterApplied ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isFilterApplied
                              ? AppColors.primary
                              : const Color(0xFFE5E7EC),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.filter_list,
                              color: isFilterApplied
                                  ? Colors.white
                                  : Colors.grey.shade600),
                          // Active-filter indicator dot
                          if (isFilterApplied)
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFE5484D),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              _buildCategoryChipRows(),
              const SizedBox(height: 20),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: Text(
                  AppStrings.all_product,
                  style: UiTypography.cardTitle().copyWith(
                    fontSize: 20,
                    height: 1.25,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Main Content Area — MasonryGridView is ALWAYS mounted so its
              // scroll position is preserved across state changes (filter, search,
              // refresh). Skeleton + empty states overlay on top instead of
              // swapping widget types.
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
                          child: ProductView(
                            product: product,
                            type: productViewType,
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
                    // Skeleton overlay during initial load
                    if (apiLoading && currentPage == 0)
                      Positioned.fill(
                        child: Container(
                          color: const Color(0xFFF9F9FB),
                          child: const ProductGridSkeleton(),
                        ),
                      ),
                    // Empty-state overlay (only after load completes)
                    if (!apiLoading && filteredProducts.isEmpty)
                      Positioned.fill(
                        child: Container(
                          color: const Color(0xFFF9F9FB),
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
      final selectedAddress =
          await SharedPreferencesUtil().getMap('selected_address');
      final latitude = _extractAddressCoordinate(selectedAddress, 'latitude');
      final longitude = _extractAddressCoordinate(selectedAddress, 'longitude');
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
        latitude: latitude,
        longitude: longitude,
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
