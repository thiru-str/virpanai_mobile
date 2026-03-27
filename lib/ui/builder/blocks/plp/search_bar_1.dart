import 'package:flutter/material.dart';
import '../../../../model/block_config.dart';
import '../../../../utility/app_colors.dart';
import '../../../../utility/font_utils.dart';

/// SearchBar1 - Default search bar with optional voice/camera.
/// Extracted from product_page.dart search TextField section
class SearchBar1Widget extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final VoidCallback? onFilterTap;
  final bool isFilterApplied;
  final BlockConfig config;

  const SearchBar1Widget({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.config,
    this.onFilterTap,
    this.isFilterApplied = false,
  });

  @override
  Widget build(BuildContext context) {
    final placeholder = config.getString('placeholder_text', defaultValue: 'Search products...');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: FontUtils.secondaryFontStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: placeholder,
                  hintStyle: FontUtils.secondaryFontStyle(
                    fontSize: 14,
                    color: AppColors.textColor50,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            controller.clear();
                            onChanged('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),
          if (onFilterTap != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onFilterTap,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.tune,
                  color: isFilterApplied ? AppColors.primary : Colors.grey,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
