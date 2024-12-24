import 'package:flutter/material.dart';

import '../../utility/app_colors.dart';

class VariantsBottomSheet extends StatelessWidget {
  final String title;
  final List<String> options;
  final String selectedOption;
  final Function(String) onOptionSelected;

  const VariantsBottomSheet({
    Key? key,
    required this.title,
    required this.options,
    required this.selectedOption,
    required this.onOptionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.close,
                  size: 24,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Options List
          Expanded(
            child: ListView.separated(
              itemCount: options.length,
              separatorBuilder: (context, index) => const Divider(
                color: Colors.grey,
                height: 0.5,
              ),
              itemBuilder: (context, index) {
                final option = options[index];
                return ListTile(
                  onTap: () => onOptionSelected(option),
                  title: Text(
                    option,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  trailing: option == selectedOption
                      ? Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 24,
                  )
                      : null,
                  leading: title == 'Color'
                      ? CircleAvatar(
                    backgroundColor: _getColor(option),
                    radius: 12,
                  )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get color for options
  Color _getColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'orange':
        return Colors.orange;
      case 'black':
        return Colors.black;
      case 'red':
        return Colors.red;
      case 'yellow':
        return Colors.yellow;
      case 'blue':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
