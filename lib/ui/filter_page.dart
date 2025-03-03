import 'package:flutter/material.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  Set<String> selectedCategories = {};
  Set<String> selectedBrands = {};
  double minPrice = 500;
  double maxPrice = 10000;
  String sortBy = 'Recommended';

  String selectedSidebar = 'Categories';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _clearAllFilters,
            child: Text(
              'Clear All',
              style:
                  FontUtils.primaryFontStyle(fontSize: 16, color: Colors.red),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar
          _buildSidebar(),
          // Filter Options
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildFilterContent(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomAppBar(),
    );
  }

  Widget _buildSidebar() {
    const sidebarItems = ['Categories', 'Brand', 'Price', 'Sort by'];
    return Container(
      width: 120,
      color: AppColors.secondary,
      child: ListView(
        children: sidebarItems.map((item) {
          return SidebarItem(
            title: item,
            selected: selectedSidebar == item,
            onTap: () => setState(() {
              selectedSidebar = item;
            }),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilterContent() {
    switch (selectedSidebar) {
      case 'Categories':
        return _buildFilterList(
          ['Eggs', 'Noodles & Pasta', 'Chips & Crisps', 'Fast Food'],
          selectedCategories,
        );
      case 'Brand':
        return _buildFilterList(
          ['Cocoa', 'Ifad', 'Kazi Farmas'],
          selectedBrands,
        );
      case 'Price':
        return _buildPriceFilter();
      case 'Sort by':
        return _buildSortByFilter();
      default:
        return const SizedBox();
    }
  }

  Widget _buildFilterList(List<String> items, Set<String> selectedSet) {
    return ListView(
      children: items.map((item) {
        return FilterOption(
          title: item,
          selected: selectedSet.contains(item),
          onSelected: () {
            setState(() {
              if (selectedSet.contains(item)) {
                selectedSet.remove(item);
              } else {
                selectedSet.add(item);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildPriceFilter() {
    return Column(
      children: [
        _buildPriceInput('Min: ', minPrice, (value) {
          setState(() {
            minPrice = double.tryParse(value) ?? minPrice;
          });
        }),
        _buildPriceInput('Max: ', maxPrice, (value) {
          setState(() {
            maxPrice = double.tryParse(value) ?? maxPrice;
          });
        }),
      ],
    );
  }

  Widget _buildPriceInput(
      String label, double value, ValueChanged<String> onChanged) {
    return Row(
      children: [
        Text(label),
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
    const sortOptions = [
      'Recommended',
      'Newest',
      'Lowest - Highest Price',
      'Highest - Lowest Price'
    ];
    return Column(
      children: sortOptions.map((option) {
        return RadioListTile<String>(
          title: Text(
            option,
            style: FontUtils.primaryFontStyle(fontSize: 16),
          ),
          value: option,
          groupValue: sortBy,
          onChanged: (value) {
            setState(() {
              sortBy = value!;
            });
          },
          contentPadding:
              EdgeInsets.symmetric(horizontal: 05), // Reduce horizontal padding
          visualDensity: VisualDensity.compact, // Reduces the space
          // dense: true, // Brings the radio button and text closer
        );
      }).toList(),
    );
  }

  Widget _buildBottomAppBar() {
    return BottomAppBar(
      color: Colors.white, // Set the background color to white
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () {
                // Apply action
              },
              child: Text(
                'Apply',
                style: FontUtils.primaryFontStyle(
                    fontSize: 17,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          VerticalDivider(width: 1, color: Colors.grey.shade300,),
          Expanded(
            child: TextButton(
              onPressed: () {
                // Close action
              },
              child: Text('Close',
                  style: FontUtils.primaryFontStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  )),
            ),
          ),
        ],
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      selectedCategories.clear();
      selectedBrands.clear();
      minPrice = 500;
      maxPrice = 10000;
      sortBy = 'Recommended';
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
        decoration: BoxDecoration(
          color:
              selected ? AppColors.primary.withAlpha(50) : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: selected ? AppColors.primary : Colors.transparent,
              width: 4, // Width of the left line
            ),
          ),
        ),
        padding: const EdgeInsets.all(15.0),
        child: Text(
          title,
          style: FontUtils.primaryFontStyle(
            fontSize: 16,
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
    return InkWell(
      onTap: onSelected,
      child: Padding(
        padding: const EdgeInsets.all(8.0), // Adjust vertical spacing
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox(
              value: selected,
              onChanged: (_) => onSelected(),
              activeColor: AppColors.primary,
              visualDensity: VisualDensity.compact, // Reduces checkbox size
              materialTapTargetSize:
                  MaterialTapTargetSize.shrinkWrap, // Reduces padding
            ),
            const SizedBox(width: 8), // Small gap between checkbox and text
            Text(
              title,
              style: FontUtils.primaryFontStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
