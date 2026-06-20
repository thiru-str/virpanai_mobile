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

  // Inline category chip rows — main + sub
  List<ProductCategory> _mainCategories = [];
  List<ProductCategory> _allSubs = []; // flat list of all sub-categories
  String? _selectedMainId; // null = "All main"
  String? _selectedSubId; // null = "All sub"
  final GlobalKey _selectedMainKey = GlobalKey();
  final GlobalKey _selectedSubKey = GlobalKey();
  final ScrollController _mainRowCtrl = ScrollController();
  final ScrollController _subRowCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadProductViewType();
    _loadFavouriteState();
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
    _mainRowCtrl.dispose();
    _subRowCtrl.dispose();
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

  Future<void> _loadCategories() async {
    try {
      final res = await ApiService().productCategories(context);
      if (!mounted) return;
      final all = res.productCategories ?? [];
      // Mains = top-level only
      final mains = all.where((c) => (c.parentCategoryId == null || c.parentCategoryId!.isEmpty)).toList();
      // Subs come either as flat entries OR nested under categoryChildren
      final subs = <ProductCategory>[];
      for (final c in all) {
        if (c.parentCategoryId != null && c.parentCategoryId!.isNotEmpty) {
          subs.add(c);
        }
        for (final child in (c.categoryChildren ?? [])) {
          // Ensure parent linkage in case API omits it on the child
          if (child.parentCategoryId == null || child.parentCategoryId!.isEmpty) {
            child.parentCategoryId = c.id;
          }
          if (!subs.any((s) => s.id == child.id)) subs.add(child);
        }
      }
      // Pre-select from incoming widget.categoryId OR existing filter selection
      String? preMain;
      String? preSub;
      final seedIds = <String>[
        if (selectedCategoriesList.isNotEmpty) ...selectedCategoriesList,
        if (widget.categoryId.isNotEmpty) widget.categoryId,
      ];
      // Combined lookup pool: mains + subs (so we can resolve any id)
      final pool = [...mains, ...subs];
      for (final id in seedIds) {
        final match = pool.firstWhere((c) => c.id == id,
            orElse: () => ProductCategory());
        if (match.id == null) continue;
        if (match.parentCategoryId == null || match.parentCategoryId!.isEmpty) {
          preMain = match.id;
        } else {
          preSub = match.id;
          preMain = match.parentCategoryId;
        }
      }
      setState(() {
        _mainCategories = mains;
        _allSubs = subs;
        _selectedMainId = preMain;
        _selectedSubId = preSub;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _ensureSelectedVisible());
    } catch (_) {}
  }

  // Average chip widths — used only as a coarse jump-to-near-position estimate
  // before refining via Scrollable.ensureVisible. Horizontal ListView.separated
  // is lazy; offscreen items are not built, so a precise scroll requires two
  // stages: (1) jump near the target so the item is built, (2) ensureVisible
  // to fine-tune using the actual rendered widget.
  static const double _mainChipAvgWidth = 110.0;
  static const double _subChipAvgWidth = 90.0;

  void _ensureSelectedVisible({bool main = true, bool sub = true}) {
    if (!mounted) return;
    if (main) _scrollRowToSelected(_mainRowCtrl, _selectedMainKey,
        _selectedMainId, _mainCategories, _mainChipAvgWidth);
    if (sub) _scrollRowToSelected(_subRowCtrl, _selectedSubKey,
        _selectedSubId, _visibleSubs, _subChipAvgWidth);
  }

  void _scrollRowToSelected(
    ScrollController ctrl,
    GlobalKey key,
    String? selectedId,
    List<ProductCategory> items,
    double avgChipWidth,
  ) {
    if (selectedId == null || !ctrl.hasClients) return;
    final idx = items.indexWhere((c) => c.id == selectedId);
    if (idx < 0) return;

    // Stage 1 — jump near the target so the lazy ListView builds the chip.
    final screenW = MediaQuery.of(context).size.width;
    final estimated = (idx + 1) * avgChipWidth - screenW / 2;
    ctrl.jumpTo(estimated.clamp(0.0, ctrl.position.maxScrollExtent));

    // Stage 2 — wait for the chip to render, then center it precisely.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ctx = key.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(ctx,
          alignment: 0.5, duration: Duration.zero);
    });
  }

  List<ProductCategory> get _visibleSubs {
    if (_selectedMainId == null) return _allSubs;
    return _allSubs.where((c) => c.parentCategoryId == _selectedMainId).toList();
  }

  void _onMainTap(String? id) {
    setState(() {
      _selectedMainId = id;
      _selectedSubId = null; // reset sub when main changes
    });
    _refetchForChips();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => _ensureSelectedVisible(main: true, sub: false));
  }

  void _onSubTap(String? id) {
    setState(() => _selectedSubId = id);
    _refetchForChips();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => _ensureSelectedVisible(main: false, sub: true));
  }

  void _refetchForChips() {
    final ids = <String>[];
    if (_selectedSubId != null) {
      ids.add(_selectedSubId!);
    } else if (_selectedMainId != null) {
      ids.add(_selectedMainId!);
    }
    setState(() {
      selectedCategoriesList = ids;
      currentPage = 0;
      hasMore = true;
      filteredProducts.clear();
      apiLoading = true;
      isFilterApplied = ids.isNotEmpty || selectedCollectionsList.isNotEmpty || selectedTagsList.isNotEmpty;
    });
    getProductsApi(
      categoryIds: ids.isNotEmpty ? ids.join(',') : null,
      collectionIds: selectedCollectionsList.isNotEmpty ? selectedCollectionsList.join(',') : null,
      tagIds: selectedTagsList.isNotEmpty ? selectedTagsList.join(',') : null,
    );
  }

  Widget _mainChip({
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

  Widget _subChip({
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
    final subs = _visibleSubs;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main row — light grey background, soft green pill on selected
          Container(
            color: const Color(0xFFF5F5F7),
            height: 38,
            child: ListView.separated(
              controller: _mainRowCtrl,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: _mainCategories.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 0),
              itemBuilder: (_, i) {
                if (i == 0) {
                  return KeyedSubtree(
                    key: _selectedMainId == null ? _selectedMainKey : null,
                    child: _mainChip(
                      label: 'All',
                      selected: _selectedMainId == null,
                      onTap: () => _onMainTap(null),
                    ),
                  );
                }
                final c = _mainCategories[i - 1];
                return KeyedSubtree(
                  key: _selectedMainId == c.id ? _selectedMainKey : null,
                  child: _mainChip(
                    label: c.name ?? '',
                    selected: _selectedMainId == c.id,
                    onTap: () => _onMainTap(c.id),
                  ),
                );
              },
            ),
          ),
          // Sub row — white bg, only underline indicates selection
          if (subs.isNotEmpty) ...[
            Container(
              height: 1,
              color: const Color(0xFFEEEFF1),
            ),
            Container(
              color: Colors.white,
              height: 38,
              child: ListView.separated(
                controller: _subRowCtrl,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 4),
                itemCount: subs.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (_, i) {
                  if (i == 0) {
                    return KeyedSubtree(
                      key: _selectedSubId == null ? _selectedSubKey : null,
                      child: _subChip(
                        label: 'All',
                        selected: _selectedSubId == null,
                        onTap: () => _onSubTap(null),
                      ),
                    );
                  }
                  final c = subs[i - 1];
                  return KeyedSubtree(
                    key: _selectedSubId == c.id ? _selectedSubKey : null,
                    child: _subChip(
                      label: c.name ?? '',
                      selected: _selectedSubId == c.id,
                      onTap: () => _onSubTap(c.id),
                    ),
                  );
                },
              ),
            ),
            Container(height: 1, color: const Color(0xFFEEEFF1)),
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
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar + Filter icon
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
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
              ),

              // Inline category chips — full-width, sits outside horizontal padding
              _buildCategoryChipRows(),

              const SizedBox(height: 16),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                            isLoggedIn: _isLoggedIn,
                            favConfig: _favConfig,
                            isFavorite: _savedProductIds.contains(product.id ?? ''),
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
