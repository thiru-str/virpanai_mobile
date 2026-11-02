import 'package:flutter/material.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/font_utils.dart';
import 'grocery_shared.dart';

// 10 premium mobile-app header bars. Presentational + accept brand/cartCount so
// they preview cleanly and drop into CombinedHeaderAppBar (header-9..header-18).

const _ink = Color(0xFF1A1A1A);

Widget _iconBtn(IconData icon, {int badge = 0, Color color = _ink}) => Stack(children: [
  SizedBox(height: 40, width: 40, child: Icon(icon, color: color, size: 24)),
  if (badge > 0) Positioned(right: 4, top: 4, child: Container(
    height: 16, constraints: const BoxConstraints(minWidth: 16), alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(horizontal: 4),
    decoration: BoxDecoration(color: color == Colors.white ? _ink : _ink, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(8)),
    child: Text('$badge', style: FontUtils.primaryFontStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)))),
]);

Widget _brand(String b, {Color color = _ink, double spacing = 2.5, bool serif = false}) => Text(b,
  style: FontUtils.primaryFontStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color).copyWith(letterSpacing: spacing));

Widget _searchField({String hint = 'Search', bool pill = true}) => Container(
  height: 42, padding: const EdgeInsets.symmetric(horizontal: 14),
  decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(pill ? 22 : 12)),
  child: Row(children: [
    const Icon(Icons.search, size: 20, color: AppColors.tabInActivecolor),
    const SizedBox(width: 8),
    Text(hint, style: FontUtils.primaryFontStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textColor50)),
  ]));

class AppHeaderSplit1 extends StatelessWidget {
  final String brand; final int cartCount;
  const AppHeaderSplit1({super.key, this.brand = 'AURA', this.cartCount = 2});
  @override
  Widget build(BuildContext context) => Container(height: 64, color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Row(children: [
      const Icon(Icons.menu, color: _ink, size: 24), const SizedBox(width: 8), _brand(brand),
      const Spacer(), _iconBtn(Icons.search_outlined), _iconBtn(Icons.favorite_border), _iconBtn(Icons.shopping_bag_outlined, badge: cartCount),
    ]));
}

class AppHeaderCentered1 extends StatelessWidget {
  final String brand; final int cartCount;
  const AppHeaderCentered1({super.key, this.brand = 'AURA', this.cartCount = 2});
  @override
  Widget build(BuildContext context) => Container(height: 64, color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Row(children: [
      const Icon(Icons.menu, color: _ink, size: 24),
      Expanded(child: Center(child: _brand(brand))),
      _iconBtn(Icons.shopping_bag_outlined, badge: cartCount),
    ]));
}

class AppHeaderMinimal1 extends StatelessWidget {
  final String brand; final int cartCount;
  const AppHeaderMinimal1({super.key, this.brand = 'AURA', this.cartCount = 2});
  @override
  Widget build(BuildContext context) => Container(height: 60, color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(children: [
      _brand(brand, spacing: 3), const Spacer(),
      _iconBtn(Icons.search_outlined), _iconBtn(Icons.shopping_bag_outlined, badge: cartCount),
    ]));
}

class AppHeaderSearch1 extends StatelessWidget {
  final String brand; final int cartCount;
  const AppHeaderSearch1({super.key, this.brand = 'AURA', this.cartCount = 2});
  @override
  Widget build(BuildContext context) => Container(height: 68, color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Row(children: [
      _brand(brand), const SizedBox(width: 10),
      Expanded(child: _searchField(hint: 'Search products & brands')),
      _iconBtn(Icons.shopping_bag_outlined, badge: cartCount),
    ]));
}

class AppHeaderTwoRow1 extends StatelessWidget {
  final String brand; final int cartCount;
  const AppHeaderTwoRow1({super.key, this.brand = 'AURA', this.cartCount = 2});
  @override
  Widget build(BuildContext context) => Container(height: 116, color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    child: Column(children: [
      Row(children: [
        _brand(brand), const Spacer(),
        _iconBtn(Icons.favorite_border), _iconBtn(Icons.shopping_bag_outlined, badge: cartCount),
      ]),
      const SizedBox(height: 6),
      _searchField(hint: 'Search for anything', pill: false),
    ]));
}

class AppHeaderLocation1 extends StatelessWidget {
  final String brand; final int cartCount;
  const AppHeaderLocation1({super.key, this.brand = 'AURA', this.cartCount = 2});
  @override
  Widget build(BuildContext context) => Container(height: 116, color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    child: Column(children: [
      Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            const Icon(Icons.location_on, size: 16, color: kFresh),
            const SizedBox(width: 4),
            Text('Deliver to  ·  Home', style: FontUtils.primaryFontStyle(fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textColor50)),
            const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textColor50),
          ]),
          Text('12, MG Road, Bengaluru 560001', maxLines: 1, overflow: TextOverflow.ellipsis,
            style: FontUtils.primaryFontStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textColor)),
        ]),
        const Spacer(),
        _iconBtn(Icons.shopping_bag_outlined, badge: cartCount),
      ]),
      const SizedBox(height: 6),
      _searchField(hint: 'Search groceries, food & more'),
    ]));
}

class AppHeaderPill1 extends StatelessWidget {
  final String brand; final int cartCount;
  const AppHeaderPill1({super.key, this.brand = 'AURA', this.cartCount = 2});
  @override
  Widget build(BuildContext context) => Container(height: 68, color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    child: Container(padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _ink.withOpacity(0.08)), boxShadow: [BoxShadow(color: _ink.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 4))]),
      child: Row(children: [
        _brand(brand, spacing: 2), const Spacer(),
        _iconBtn(Icons.search_outlined), _iconBtn(Icons.shopping_bag_outlined, badge: cartCount),
      ])));
}

class AppHeaderGradient1 extends StatelessWidget {
  final String brand; final int cartCount;
  const AppHeaderGradient1({super.key, this.brand = 'AURA', this.cartCount = 2});
  @override
  Widget build(BuildContext context) => Container(height: 112,
    decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1BA672), Color(0xFF0E9C95)])),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    child: Column(children: [
      Row(children: [
        _brand(brand, color: Colors.white), const Spacer(),
        _iconBtn(Icons.notifications_none, color: Colors.white), _iconBtn(Icons.shopping_bag_outlined, badge: cartCount, color: Colors.white),
      ]),
      const SizedBox(height: 8),
      Container(height: 42, padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
        child: Row(children: [
          const Icon(Icons.search, size: 20, color: AppColors.tabInActivecolor), const SizedBox(width: 8),
          Text('Search', style: FontUtils.primaryFontStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textColor50)),
        ])),
    ]));
}

class AppHeaderCategoryTabs1 extends StatelessWidget {
  final String brand; final int cartCount;
  const AppHeaderCategoryTabs1({super.key, this.brand = 'AURA', this.cartCount = 2});
  static const _cats = ['For You', 'Women', 'Men', 'Beauty', 'Home'];
  @override
  Widget build(BuildContext context) => Container(height: 104, color: Colors.white,
    child: Column(children: [
      Container(height: 60, padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [
        _brand(brand), const Spacer(), _iconBtn(Icons.search_outlined), _iconBtn(Icons.shopping_bag_outlined, badge: cartCount),
      ])),
      SizedBox(height: 42, child: ListView.separated(scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12), itemCount: _cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 18),
        itemBuilder: (context, i) => Center(child: Text(_cats[i], style: FontUtils.primaryFontStyle(
          fontSize: 14, fontWeight: i == 0 ? FontWeight.w800 : FontWeight.w500,
          color: i == 0 ? _ink : AppColors.textColor50))))),
    ]));
}

class AppHeaderLuxe1 extends StatelessWidget {
  final String brand; final int cartCount;
  const AppHeaderLuxe1({super.key, this.brand = 'MAISON', this.cartCount = 2});
  @override
  Widget build(BuildContext context) => Container(height: 60, color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Row(children: [
      _iconBtn(Icons.menu),
      Expanded(child: Center(child: Text(brand, style: FontUtils.primaryFontStyle(
        fontSize: 20, fontWeight: FontWeight.w500, color: _ink).copyWith(letterSpacing: 6)))),
      _iconBtn(Icons.shopping_bag_outlined, badge: cartCount),
    ]));
}
