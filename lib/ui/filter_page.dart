import 'package:flutter/material.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/model/collection_response.dart';
import 'package:waioz/model/product_category_response.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';

enum FilterSection {
  collections,
  categories,
  price,
  sortBy,
}

class FilterPage extends StatefulWidget {
  final String parentCategoryId;
  final List<String> preSelectedCollections;
  final List<String> preSelectedCategories;
  const FilterPage({
    super.key,
    required this.parentCategoryId,
    this.preSelectedCollections = const [],
    this.preSelectedCategories = const [],
  });

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  Set<String> selectedCollections = {};
  Set<String> selectedCategories = {};
  double minPrice = 500;
  double maxPrice = 10000;
  String sortBy = AppStrings.recommended;

  FilterSection selectedSection = FilterSection.collections;
  bool isLoadingCollections = true;
  bool isLoadingCategories = true;

  List<Collection> collectionsList = [];
  List<ProductCategory> categoryList = [];

  static const sortOptions = [
    'Recommended',
    'Newest',
    'Lowest - Highest Price',
    'Highest - Lowest Price'
  ];

  final sidebarItems = [
    {'label': AppStrings.collections, 'section': FilterSection.collections},
    {'label': AppStrings.categories, 'section': FilterSection.categories},
    {'label': AppStrings.price, 'section': FilterSection.price},
    {'label': AppStrings.sort_by, 'section': FilterSection.sortBy},
  ];

  @override
  void initState() {
    super.initState();
    selectedCollections = widget.preSelectedCollections.toSet();
    selectedCategories = widget.preSelectedCategories.toSet();
    _fetchInitialData();
  }

  void _fetchInitialData() {
    _loadCollections();
    _loadCategories();
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
        widget.parentCategoryId,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            : _buildFilterList(
                categoryList.map((e) => e.id ?? '').toList(),
                selectedCategories,
                labelMap: Map.fromEntries(categoryList
                    .where((e) => e.id != null && e.name != null)
                    .map((e) => MapEntry(e.id!, e.name!))),
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
        _buildPriceInput('Min: ', minPrice, (value) {
          setState(() => minPrice = double.tryParse(value) ?? minPrice);
        }),
        _buildPriceInput('Max: ', maxPrice, (value) {
          setState(() => maxPrice = double.tryParse(value) ?? maxPrice);
        }),
      ],
    );
  }

  Widget _buildPriceInput(
      String label, double value, ValueChanged<String> onChanged) {
    return Row(
      children: [
        Text(label),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: '₹${value.toInt()}'),
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
            Navigator.pop(context, {
              'selectedCollections': selectedCollections.toList(),
              'selectedCategories': selectedCategories.toList(),
            });
          }),
          VerticalDivider(width: 1, color: Colors.grey.shade300),
          _buildBottomButton(AppStrings.close, Colors.black, () {
            // Close action
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
      minPrice = 500;
      maxPrice = 10000;
      sortBy = sortOptions.first;
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
            Text(title, style: FontUtils.primaryFontStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
