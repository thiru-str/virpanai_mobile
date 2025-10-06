import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/model/collection_response.dart';
import 'package:waioz/model/product_category_response.dart';
import 'package:waioz/model/tags_response.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';

enum FilterSection {
  collections,
  categories,
  price,
  sortBy,
  tags,
}

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

  static const sortOptions = [
    'Lowest - Highest Price',
    'Highest - Lowest Price'
  ];

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
    if(widget.preMinPrice!=null) {
      minPriceController.text = '${widget.preMinPrice!.toInt()}';
    }
    if(widget.preMaxPrice!=null) {
      maxPriceController.text = '${widget.preMaxPrice!.toInt()}';
    }
    if(widget.preSortBy!=null) {
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=> FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              color: Colors.grey.shade300,
              height: 1,
            ),
          ),
          actions: [
            TextButton(
              onPressed: _clearAllFilters,
              child: Text(
                AppStrings.clear_all,
                style:
                    FontUtils.primaryFontStyle(fontSize: 16, color: Colors.red),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  _buildSidebar(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildFilterContent(),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 1,
              color: Colors.grey.shade300,
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomAppBar(),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 140,
      color: AppColors.secondary,
      child: ListView(
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
    );
  }

  Widget _buildFilterContent() {
    switch (selectedSection) {
      case FilterSection.collections:
        return isLoadingCollections
            ? const Center(child: CircularProgressIndicator())
            : _buildFilterList(
                collectionsList.map((e) => e.id ?? '').toList(),
                selectedCollections,
                labelMap: Map.fromEntries(collectionsList
                    .where((e) => e.id != null && e.title != null)
                    .map((e) => MapEntry(e.id!, e.title!))),
              );
      case FilterSection.categories:
        return isLoadingCategories
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            // 🔎 Minimal search field with underline + clear
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: TextField(
                controller: categorySearchController,
                decoration: InputDecoration(
                  hintText: "Search categories",
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  border: const UnderlineInputBorder(),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey), // light grey line
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary, width: 2), // highlight on focus
                  ),
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
                ),
                style: const TextStyle(fontSize: 14),
                onChanged: (value) {
                  setState(() {
                    categorySearchQuery = value.toLowerCase();
                  });
                },
              ),
            ),

            // Filtered list
            Expanded(
              child: _buildFilterList(
                categoryList
                    .where((e) =>
                e.name != null &&
                    e.name!.toLowerCase().contains(categorySearchQuery))
                    .map((e) => e.id ?? '')
                    .toList(),
                selectedCategories,
                labelMap: Map.fromEntries(
                  categoryList
                      .where((e) =>
                  e.id != null &&
                      e.name != null &&
                      e.name!.toLowerCase().contains(categorySearchQuery))
                      .map((e) => MapEntry(e.id!, e.name!)),
                ),
              ),
            ),
          ],
        );
      case FilterSection.tags:
        return isTagsLoading
            ? const Center(child: CircularProgressIndicator())
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

  Widget _buildFilterList(
    List<String> items,
    Set<String> selectedSet, {
    Map<String, String>? labelMap,
  }) {
    return ListView(
      children: items.map((id) {
        final isSelected = selectedSet.contains(id);
        final displayName = labelMap?[id] ?? id;
        return FilterOption(
          title: displayName,
          selected: isSelected,
          onSelected: () => setState(() {
            isSelected ? selectedSet.remove(id) : selectedSet.add(id);
          }),
        );
      }).toList(),
    );
  }

  Widget _buildPriceFilter() {
    return Column(
      children: [
        _buildPriceInput('Min: ',minPriceController, 1,minPrice, (value) {
          setState(() => minPrice = value.isEmpty ? null : double.tryParse(value));
        }),
        _buildPriceInput('Max: ',maxPriceController, 999999,maxPrice, (value) {
          setState(() => maxPrice = value.isEmpty ? null : double.tryParse(value));
        }),
      ],
    );
  }

  Widget _buildPriceInput(
      String label, TextEditingController textController,double hint,double? value, ValueChanged<String> onChanged) {
    return Row(
      children: [
        Text(label),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            keyboardType: TextInputType.number,
            controller: textController,
            decoration: InputDecoration(hintText: '₹${hint.toInt()}'),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSortByFilter() {
    return Column(
      children: sortOptions.map((option) {
        return RadioListTile<String>(
          title: Text(option, style: FontUtils.primaryFontStyle(fontSize: 16)),
          value: option,
          groupValue: sortBy,
          activeColor: AppColors.primary,
          onChanged: (value) => setState(() => sortBy = value!),
          contentPadding: const EdgeInsets.symmetric(horizontal: 5),
          visualDensity: VisualDensity.compact,
        );
      }).toList(),
    );
  }

  Widget _buildBottomAppBar() {
    return BottomAppBar(
      color: Colors.white,
      child: Row(
        children: [
          _buildBottomButton(AppStrings.apply, AppColors.primary, () {
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
          }),
          VerticalDivider(width: 1, color: Colors.grey.shade300),
          _buildBottomButton(AppStrings.close, Colors.black, () {
            // Close action
            Navigator.pop(context);
          }),
        ],
      ),
    );
  }

  Widget _buildBottomButton(String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: TextButton(
        onPressed: onTap,
        child: Text(
          label,
          style: FontUtils.primaryFontStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
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
      child: Container(
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color:
              selected ? AppColors.primary.withAlpha(50) : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: selected ? AppColors.primary : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Text(
          title,
          style: FontUtils.primaryFontStyle(fontSize: 16),
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
    return InkWell(
      onTap: onSelected,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Checkbox(
              value: selected,
              onChanged: (_) => onSelected(),
              activeColor: AppColors.primary,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 8),
            Flexible(child: Text(title, style: FontUtils.primaryFontStyle(fontSize: 16))),
          ],
        ),
      ),
    );
  }
}
