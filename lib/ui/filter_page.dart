import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/model/collection_response.dart';
import 'package:waioz/model/product_category_response.dart';
import 'package:waioz/model/tags_response.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/ui_typography.dart';

enum FilterSection {
  collections,
  categories,
  price,
  sortBy,
  tags,
}

// ── Premium palette ──────────────────────────────────────────────
const Color _kScaffoldBg = Color(0xFFF9F9FB);
const Color _kHairline = Color(0xFFE5E7EC);

class FilterPage extends StatefulWidget {
  final String parentCategoryId;
  final List<String> preSelectedCollections;
  final List<String> preSelectedCategories;
  final List<String> preSelectedTags;
  final double? preMinPrice;
  final double? preMaxPrice;
  final String? preSortBy;
  final FilterSection preSelectedSection;
  const FilterPage({
    super.key,
    required this.parentCategoryId,
    this.preSelectedCollections = const [],
    this.preSelectedCategories = const [],
    this.preSelectedTags = const [],
    this.preMinPrice,
    this.preMaxPrice,
    this.preSortBy,
    this.preSelectedSection = FilterSection.collections,
  });

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  Set<String> selectedCollections = {};
  Set<String> selectedCategories = {};
  Set<String> selectedTags = {};
  double? minPrice;
  double? maxPrice;
  String? sortBy;

  TextEditingController categorySearchController = TextEditingController();
  String categorySearchQuery = '';

  FilterSection selectedSection = FilterSection.collections;
  bool isLoadingCollections = true;
  bool isLoadingCategories = true;
  bool isTagsLoading = true;

  TextEditingController minPriceController = TextEditingController();
  TextEditingController maxPriceController = TextEditingController();

  List<Collection> collectionsList = [];
  List<ProductCategory> categoryList = [];
  List<ProductTag> tagsList = [];

  static const sortOptions = [AppStrings.low_high, AppStrings.high_low];

  final sidebarItems = [
    {'label': AppStrings.collections, 'section': FilterSection.collections},
    {'label': AppStrings.categories, 'section': FilterSection.categories},
    {'label': AppStrings.tags, 'section': FilterSection.tags},
    {'label': AppStrings.price, 'section': FilterSection.price},
    {'label': AppStrings.sort_by, 'section': FilterSection.sortBy},
  ];

  @override
  void initState() {
    super.initState();
    selectedCollections = widget.preSelectedCollections.toSet();
    selectedCategories = widget.preSelectedCategories.toSet();
    selectedTags = widget.preSelectedTags.toSet();
    if (widget.preMinPrice != null) {
      minPriceController.text = '${widget.preMinPrice!.toInt()}';
    }
    if (widget.preMaxPrice != null) {
      maxPriceController.text = '${widget.preMaxPrice!.toInt()}';
    }
    if (widget.preSortBy != null) {
      sortBy = widget.preSortBy!;
    }
    selectedSection = widget.preSelectedSection;
    _fetchInitialData();
  }

  void _fetchInitialData() {
    _loadCollections();
    _loadCategories();
    _loadTags();
  }

  Future<void> _loadCollections() async {
    try {
      final response = await ApiService().listCollections(context);
      setState(() {
        collectionsList = response.collections ?? [];
        isLoadingCollections = false;
      });
    } catch (e) {
      print('Error loading collections: $e');
      setState(() => isLoadingCollections = false);
    }
  }

  Future<void> _loadCategories() async {
    try {
      final response = await ApiService().listCategories(
        context,
      );
      setState(() {
        categoryList = response.productCategories ?? [];
        isLoadingCategories = false;
      });
    } catch (e) {
      print('Error loading categories: $e');
      setState(() => isLoadingCategories = false);
    }
  }

  Future<void> _loadTags() async {
    try {
      final response = await ApiService().listTags(
        context,
      );
      setState(() {
        tagsList = response.productTags ?? [];
        isTagsLoading = false;
      });
    } catch (e) {
      print('Error loading categories: $e');
      setState(() => isTagsLoading = false);
    }
  }

  // Count of currently selected filters (for the "Clear all" affordance).
  int get _activeFilterCount {
    var count = selectedCollections.length +
        selectedCategories.length +
        selectedTags.length;
    if (minPriceController.text.isNotEmpty ||
        maxPriceController.text.isNotEmpty) {
      count++;
    }
    if (sortBy != null && sortBy!.isNotEmpty) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: _kScaffoldBg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleSpacing: 16,
          title: Text(
            'Filters',
            style: UiTypography.cardTitle().copyWith(
              fontSize: 20,
              height: 1.25,
              letterSpacing: -0.2,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              color: _kHairline,
              height: 1,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton(
                onPressed: _clearAllFilters,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFE5484D),
                ),
                child: Text(
                  AppStrings.clear_all,
                  style: FontUtils.primaryFontStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFE5484D),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSidebar(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: _buildFilterContent(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 148,
      color: Colors.white,
      child: Column(
        children: [
          Container(height: 8),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: sidebarItems.map((item) {
                final label = item['label'] as String;
                final section = item['section'] as FilterSection;
                return SidebarItem(
                  title: label,
                  selected: selectedSection == section,
                  onTap: () => setState(() => selectedSection = section),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterContent() {
    switch (selectedSection) {
      case FilterSection.collections:
        return isLoadingCollections
            ? Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _buildFilterList(
                collectionsList.map((e) => e.id ?? '').toList(),
                selectedCollections,
                labelMap: Map.fromEntries(collectionsList
                    .where((e) => e.id != null && e.title != null)
                    .map((e) => MapEntry(e.id!, e.title!))),
              );
      case FilterSection.categories:
        return isLoadingCategories
            ? Center(child: CircularProgressIndicator(color: AppColors.primary))
            : Column(
                children: [
                  // Search field for categories
                  _buildSearchField(),
                  const SizedBox(height: 12),

                  // Filtered list
                  Expanded(
                    child: _buildFilterList(
                      categoryList
                          .where((e) =>
                              e.name != null &&
                              e.name!
                                  .toLowerCase()
                                  .contains(categorySearchQuery))
                          .map((e) => e.id ?? '')
                          .toList(),
                      selectedCategories,
                      labelMap: Map.fromEntries(
                        categoryList
                            .where((e) =>
                                e.id != null &&
                                e.name != null &&
                                e.name!
                                    .toLowerCase()
                                    .contains(categorySearchQuery))
                            .map((e) => MapEntry(e.id!, e.name!)),
                      ),
                    ),
                  ),
                ],
              );
      case FilterSection.tags:
        return isTagsLoading
            ? Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _buildFilterList(
                tagsList.map((e) => e.id ?? '').toList(),
                selectedTags,
                labelMap: Map.fromEntries(tagsList
                    .where((e) => e.id != null && e.value != null)
                    .map((e) => MapEntry(e.id!, e.value!))),
              );
      case FilterSection.price:
        return _buildPriceFilter();
      case FilterSection.sortBy:
        return _buildSortByFilter();
    }
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kHairline),
      ),
      child: TextField(
        controller: categorySearchController,
        style: FontUtils.primaryFontStyle(
            fontSize: 14, color: AppColors.textColor),
        decoration: InputDecoration(
          hintText: AppStrings.search_categories,
          hintStyle: UiTypography.searchHint(),
          border: InputBorder.none,
          isDense: true,
          prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey.shade500),
          suffixIcon: categorySearchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                  onPressed: () {
                    categorySearchController.clear();
                    setState(() {
                      categorySearchQuery = '';
                    });
                  },
                )
              : null,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        onChanged: (value) {
          setState(() {
            categorySearchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildFilterList(
    List<String> items,
    Set<String> selectedSet, {
    Map<String, String>? labelMap,
  }) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 8),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final id = items[index];
        final isSelected = selectedSet.contains(id);
        final displayName = labelMap?[id] ?? id;
        return FilterOption(
          title: displayName,
          selected: isSelected,
          onSelected: () => setState(() {
            isSelected ? selectedSet.remove(id) : selectedSet.add(id);
          }),
        );
      },
    );
  }

  Widget _buildPriceFilter() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 8),
      children: [
        Text(
          AppStrings.price,
          style: UiTypography.cardTitle().copyWith(
            fontSize: 16,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildPriceInput(
                AppStrings.min,
                minPriceController,
                1,
                (value) {
                  setState(() =>
                      minPrice = value.isEmpty ? null : double.tryParse(value));
                },
              ),
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 36),
              child: Container(
                width: 12,
                height: 1.5,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPriceInput(
                AppStrings.max,
                maxPriceController,
                999999,
                (value) {
                  setState(() =>
                      maxPrice = value.isEmpty ? null : double.tryParse(value));
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceInput(String label, TextEditingController textController,
      double hint, ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: UiTypography.cardMeta(color: Colors.grey.shade600)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kHairline),
          ),
          child: TextField(
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            keyboardType: TextInputType.number,
            controller: textController,
            style: FontUtils.primaryFontStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textColor),
            decoration: InputDecoration(
              prefixText: '${AppStrings.rupee_symbol} ',
              prefixStyle: FontUtils.primaryFontStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor),
              hintText: '${hint.toInt()}',
              hintStyle: UiTypography.searchHint(),
              border: InputBorder.none,
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSortByFilter() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 8),
      children: [
        Text(
          AppStrings.sort_by,
          style: UiTypography.cardTitle().copyWith(
            fontSize: 16,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 14),
        ...sortOptions.map((option) {
          final isSelected = sortBy == option;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SelectableRow(
              label: option,
              selected: isSelected,
              isRadio: true,
              onTap: () => setState(() => sortBy = option),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              // Secondary: Close
              SizedBox(
                width: 120,
                height: 54,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary, width: 1.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    AppStrings.close,
                    style: FontUtils.primaryFontStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Primary CTA: Apply
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _activeFilterCount > 0
                        ? '${AppStrings.apply} ($_activeFilterCount)'
                        : AppStrings.apply,
                    style: FontUtils.primaryFontStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _applyFilters() {
    debugPrint('sort by ${sortBy}');
    if (minPrice == null && minPriceController.text.isNotEmpty) {
      minPrice = double.tryParse(minPriceController.text);
    }
    if (maxPrice == null && maxPriceController.text.isNotEmpty) {
      maxPrice = double.tryParse(maxPriceController.text);
    }
    Navigator.pop(context, {
      'selectedCollections': selectedCollections.toList(),
      'selectedCategories': selectedCategories.toList(),
      'selectedTags': selectedTags.toList(),
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'sortBy': sortBy,
      'selectedSection': selectedSection,
    });
  }

  void _clearAllFilters() {
    setState(() {
      selectedCategories.clear();
      selectedCollections.clear();
      selectedTags.clear();
      minPrice = null;
      maxPrice = null;
      maxPriceController.text = '';
      minPriceController.text = '';
      sortBy = '';
    });
  }
}

class SidebarItem extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const SidebarItem({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? _kScaffoldBg : Colors.white,
          border: Border(
            left: BorderSide(
              color: selected ? AppColors.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          title,
          style: FontUtils.primaryFontStyle(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.primary : AppColors.textColor,
          ),
        ),
      ),
    );
  }
}

class FilterOption extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onSelected;

  const FilterOption({
    required this.title,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return _SelectableRow(
      label: title,
      selected: selected,
      isRadio: false,
      onTap: onSelected,
    );
  }
}

/// A clean selectable row with an obvious selected state — used for filter
/// options (checkbox style) and sort options (radio style).
class _SelectableRow extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isRadio;
  final VoidCallback onTap;

  const _SelectableRow({
    required this.label,
    required this.selected,
    required this.isRadio,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : _kHairline,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: FontUtils.primaryFontStyle(
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color:
                      selected ? AppColors.primary : AppColors.textColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _indicator(),
          ],
        ),
      ),
    );
  }

  Widget _indicator() {
    if (isRadio) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade400,
            width: 2,
          ),
        ),
        child: selected
            ? Center(
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                ),
              )
            : null,
      );
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: selected ? AppColors.primary : Colors.grey.shade400,
          width: 1.5,
        ),
      ),
      child: selected
          ? const Icon(Icons.check, size: 15, color: Colors.white)
          : null,
    );
  }
}
