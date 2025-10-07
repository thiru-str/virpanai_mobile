import 'package:flutter/material.dart';
import 'package:waioz/utility/app_colors.dart';

class OrderTabSwitcher extends StatefulWidget {
  final int initialIndex;
  final ValueChanged<int> onTabChanged;

  const OrderTabSwitcher({
    Key? key,
    this.initialIndex = 0,
    required this.onTabChanged,
  }) : super(key: key);

  @override
  State<OrderTabSwitcher> createState() => _OrderTabSwitcherState();
}

class _OrderTabSwitcherState extends State<OrderTabSwitcher> {
  late int _selectedIndex;
  final _tabKeys = [GlobalKey(), GlobalKey()];
  double _indicatorWidth = 0;
  double _indicatorPosition = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateIndicator());
  }

  void _onTabTap(int index) {
    setState(() => _selectedIndex = index);
    widget.onTabChanged(index);
    _updateIndicator();
  }

  void _updateIndicator() {
    final RenderBox? box =
    _tabKeys[_selectedIndex].currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      final offset = box.localToGlobal(Offset.zero);
      setState(() {
        _indicatorWidth = box.size.width;
        _indicatorPosition = offset.dx;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = ["Delivered Orders", "Return Orders"];

    return Stack(
      children: [
        // 🔹 Full-width bottom divider
        Container(
          height: 2,
          color: Colors.grey.shade300,
          margin: const EdgeInsets.only(top: 40), // aligns with bottom of text
        ),

        // 🔹 Tab content
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(tabs.length, (index) {
              final isSelected = _selectedIndex == index;
              return GestureDetector(
                key: _tabKeys[index],
                onTap: () => _onTabTap(index),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color:
                    isSelected ? AppColors.primary : Colors.grey[600],
                  ),
                ),
              );
            }),
          ),
        ),

        // 🔹 Animated underline matching text width
        AnimatedPositioned(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          left: _indicatorPosition - 20, // match horizontal padding offset
          bottom: 0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 2,
            width: _indicatorWidth,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
