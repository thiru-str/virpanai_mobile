import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:waioz/ui/widgets/app_shimmer.dart';
import 'package:waioz/ui/widgets/combined_header_app_bar.dart';

class HomePageSkeleton extends StatelessWidget {
  const HomePageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 18, bottom: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _HomeHeroSkeleton(),
            SizedBox(height: 24),
            _HomeSectionSkeleton(),
            SizedBox(height: 24),
            _HomeSectionSkeleton(useGrid: true),
          ],
        ),
      ),
    );
  }
}

class HomeHeaderSkeleton extends StatelessWidget
    implements PreferredSizeWidget {
  final String headerType;

  const HomeHeaderSkeleton({
    super.key,
    this.headerType = 'header-4',
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(CombinedHeaderAppBar.resolveHeaderHeight(headerType));

  @override
  Widget build(BuildContext context) {
    final height = CombinedHeaderAppBar.resolveHeaderHeight(headerType);
    final hasSearch = headerType != 'header-1';
    final isCompact = headerType == 'header-1' || headerType == 'header-2';

    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: height,
      titleSpacing: 0,
      flexibleSpace: SafeArea(
        child: AppShimmer(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    ShimmerBox(
                      width: isCompact ? 54 : 108,
                      height: isCompact ? 34 : 22,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    const Spacer(),
                    const ShimmerBox(
                      width: 38,
                      height: 38,
                      borderRadius: BorderRadius.all(Radius.circular(19)),
                    ),
                  ],
                ),
                if (hasSearch) ...[
                  const SizedBox(height: 10),
                  const ShimmerBox(
                    height: 44,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProductGridSkeleton extends StatelessWidget {
  final int itemCount;

  const ProductGridSkeleton({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: GridView.builder(
        itemCount: itemCount,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.52,
        ),
        itemBuilder: (_, __) => const ProductCardSkeleton(),
      ),
    );
  }
}

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(
              height: 220,
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            SizedBox(height: 14),
            ShimmerBox(height: 14, width: 120),
            SizedBox(height: 10),
            ShimmerBox(height: 14, width: 88),
          ],
        ),
      ),
    );
  }
}

class CategoryPageSkeleton extends StatelessWidget {
  const CategoryPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: AppShimmer(
              child: ShimmerBox(height: 16, width: 108),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: AppShimmer(
              child: _CategoryGridSkeleton(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryGridSkeleton extends StatelessWidget {
  const _CategoryGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      crossAxisCount: 2,
      itemCount: 10,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => const CategoryCardSkeleton(),
    );
  }
}

class CategoryCardSkeleton extends StatelessWidget {
  const CategoryCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ShimmerBox(
                height: 140,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                ),
              ),
              SizedBox(height: 8),
              ShimmerBox(height: 14, width: 92),
            ],
          ),
        ),
      ),
    );
  }
}

class CartPageSkeleton extends StatelessWidget {
  const CartPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: const [
          _CartAddressSkeleton(),
          SizedBox(height: 18),
          CartItemSkeleton(),
          CartItemSkeleton(),
          SizedBox(height: 18),
          _CartPromoSkeleton(),
        ],
      ),
    );
  }
}

class CartFooterSkeleton extends StatelessWidget {
  const CartFooterSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, -2),
            blurRadius: 6,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: const AppShimmer(
        child: Row(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ShimmerBox(
                    width: 36,
                    height: 36,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ShimmerBox(height: 10, width: 52),
                        SizedBox(height: 6),
                        ShimmerBox(height: 12, width: 78),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ShimmerBox(
                height: 48,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartItemSkeleton extends StatelessWidget {
  const CartItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFECEEF3),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: const AppShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ShimmerBox(
                  width: 60,
                  height: 80,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ShimmerBox(height: 14, width: 126),
                      SizedBox(height: 4),
                      ShimmerBox(height: 12, width: 82),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ShimmerBox(height: 16, width: 58),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        ShimmerBox(
                          width: 24,
                          height: 24,
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        SizedBox(width: 8),
                        ShimmerBox(
                          height: 14,
                          width: 12,
                          borderRadius: BorderRadius.all(Radius.circular(7)),
                        ),
                        SizedBox(width: 8),
                        ShimmerBox(
                          width: 24,
                          height: 24,
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    ShimmerBox(height: 12, width: 62),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
              child: ShimmerBox(height: 12, width: 148),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartAddressSkeleton extends StatelessWidget {
  const _CartAddressSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFECEEF3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const AppShimmer(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(height: 16, width: 138),
                  SizedBox(height: 5),
                  ShimmerBox(height: 14, width: 230),
                  SizedBox(height: 6),
                  ShimmerBox(height: 14, width: 188),
                ],
              ),
            ),
            SizedBox(width: 10),
            ShimmerBox(
              width: 74,
              height: 36,
              borderRadius: BorderRadius.all(Radius.circular(6)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartPromoSkeleton extends StatelessWidget {
  const _CartPromoSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFECEEF3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const AppShimmer(
        child: Row(
          children: [
            ShimmerBox(
              width: 18,
              height: 18,
              borderRadius: BorderRadius.all(Radius.circular(9)),
            ),
            SizedBox(width: 8),
            Expanded(
              child: ShimmerBox(height: 12, width: 138),
            ),
            SizedBox(width: 12),
            ShimmerBox(height: 12, width: 44),
          ],
        ),
      ),
    );
  }
}

class ProductDetailSkeleton extends StatelessWidget {
  const ProductDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(
                height: 360,
                borderRadius: BorderRadius.all(Radius.circular(28))),
            SizedBox(height: 24),
            ShimmerBox(height: 22, width: 180),
            SizedBox(height: 12),
            ShimmerBox(height: 18, width: 110),
            SizedBox(height: 20),
            ShimmerBox(
                height: 58,
                borderRadius: BorderRadius.all(Radius.circular(18))),
            SizedBox(height: 16),
            ShimmerBox(
                height: 110,
                borderRadius: BorderRadius.all(Radius.circular(18))),
            SizedBox(height: 24),
            ShimmerBox(height: 18, width: 160),
            SizedBox(height: 10),
            ShimmerBox(height: 14),
            SizedBox(height: 8),
            ShimmerBox(height: 14),
            SizedBox(height: 28),
            ShimmerBox(height: 18, width: 140),
            SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: ProductCardSkeleton()),
                SizedBox(width: 16),
                Expanded(child: ProductCardSkeleton()),
              ],
            ),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class ShellSkeleton extends StatelessWidget {
  const ShellSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomePageSkeleton();
  }
}

class _HomeHeroSkeleton extends StatelessWidget {
  const _HomeHeroSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ShimmerBox(
        height: 250,
        borderRadius: BorderRadius.all(Radius.circular(28)),
      ),
    );
  }
}

class _HomeSectionSkeleton extends StatelessWidget {
  final bool useGrid;

  const _HomeSectionSkeleton({this.useGrid = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(height: 18, width: 120),
          const SizedBox(height: 16),
          if (useGrid)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.78,
              ),
              itemCount: 4,
              itemBuilder: (_, __) => const ShimmerBox(
                height: 160,
                borderRadius: BorderRadius.all(Radius.circular(22)),
              ),
            )
          else
            const SizedBox(
              height: 190,
              child: Row(
                children: [
                  Expanded(
                    child: ShimmerBox(
                      height: 190,
                      borderRadius: BorderRadius.all(Radius.circular(22)),
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: ShimmerBox(
                      height: 190,
                      borderRadius: BorderRadius.all(Radius.circular(22)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
