import 'package:flutter/material.dart';

class OrderToggleSelector extends StatefulWidget {
  final ValueChanged<int> onSelected;
  final int initialIndex;

  const OrderToggleSelector({
    Key? key,
    required this.onSelected,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<OrderToggleSelector> createState() => _OrderToggleSelectorState();
}

class _OrderToggleSelectorState extends State<OrderToggleSelector> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final List<String> options = ['Today Order', 'Overall Order'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: List.generate(options.length, (index) {
          final isSelected = selectedIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => selectedIndex = index);
                widget.onSelected(index);
              },
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF005B65) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  options[index],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
