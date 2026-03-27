import 'package:flutter/material.dart';
import '../../../../model/block_config.dart';
import '../../../../utility/app_colors.dart';
import '../../../../utility/font_utils.dart';

/// VariantSelector1 - Chip-based option selection.
/// Extracted from product_detail_page.dart buildDynamicVariantSelection()
class VariantSelector1Widget extends StatelessWidget {
  final List<Map<String, dynamic>> options; // [{title, values: [{id, value}]}]
  final Map<String, String?> selectedOptions; // optionTitle → valueId
  final Function(String optionTitle, String valueId) onOptionSelected;
  final BlockConfig config;

  const VariantSelector1Widget({
    super.key,
    required this.options,
    required this.selectedOptions,
    required this.onOptionSelected,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: options.map((option) {
          final title = option['title'] as String? ?? '';
          final values = (option['values'] as List<dynamic>?) ?? [];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: FontUtils.primaryFontStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: values.map<Widget>((val) {
                    final valueId = val['id'] as String? ?? '';
                    final valueLabel = val['value'] as String? ?? '';
                    final isSelected = selectedOptions[title] == valueId;

                    return GestureDetector(
                      onTap: () => onOptionSelected(title, valueId),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey[300]!,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          valueLabel,
                          style: FontUtils.secondaryFontStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.textColor,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
