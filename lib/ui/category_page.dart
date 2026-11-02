import 'package:waioz/ui/widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:waioz/ui/tutorial/tutorial_coordinator.dart';
import 'package:waioz/ui/tutorial/tutorial_tooltip.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:waioz/model/product_categories_response.dart';
import 'package:waioz/ui/product_page.dart';
import 'package:waioz/ui/sub_category_page.dart';
import 'package:waioz/ui/widgets/category_card.dart';
import 'package:waioz/ui/widgets/floating_cart.dart';
import 'package:waioz/ui/widgets/no_orders_widget.dart';
import 'package:waioz/ui/widgets/screen_skeletons.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/page_route_utils.dart';
import 'package:waioz/utility/ui_typography.dart';

import '../api/api_service.dart';
import '../model/view_cart_model.dart';
import 'widgets/common_header_app_bar.dart';

class CategoryPage extends StatefulWidget {
  final bool isFromBottomNav;
  const CategoryPage({super.key, this.isFromBottomNav = false});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> with TutorialMixin {
  // The tab is rebuilt on every visit: the last list shows at once while a
  // fresh one loads behind it, instead of a skeleton each time.
  static ProductCategoriesResponse? _last;

  ProductCategoriesResponse? productCategoriesResponse = _last;
  bool apiLoading = _last == null;
  final GlobalKey _firstCategoryKey = GlobalKey();

  List<ProductCategory> get _categories =>
      productCategoriesResponse?.productCategories ?? const <ProductCategory>[];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCategoriesApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // the bottom-nav shell floats its own
        floatingActionButton: widget.isFromBottomNav ? null : const FloatingCart(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        appBar: CommonHeaderAppBar(
          title: AppStrings.categories,
          leading: widget.isFromBottomNav ? false : true,
          onBackTap: () {
            Navigator.pop(context, true);
          },
        ),
        backgroundColor: const Color(0xFFF9F9FB),
        body: apiLoading
            ? const AppLoader()
            : _categories.isEmpty
                ? NoOrdersWidget(
                    message: AppStrings.no_categories_found,
                    buttonText: AppStrings.explore_categories,
                    iconPath: AppAssets.ic_cart_empty,
                    showExplore: widget.isFromBottomNav,
                    onButtonTap: () {},
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: Text(AppStrings.all_category,
                              style: UiTypography.cardTitle().copyWith(
                                fontSize: 20,
                                height: 1.25,
                                letterSpacing: -0.2,
                              )),
                        ),
                        const SizedBox(
                          height: 14,
                        ),
                        Expanded(
                          child: MasonryGridView.count(
                            padding: const EdgeInsets.only(bottom: FloatingCart.clearance),
                            crossAxisCount: 2,
                            itemCount: _categories.length,
                            itemBuilder: (context, index) {
                              final productCategory = _categories[index];

                              return KeyedSubtree(
                                key: index == 0 ? _firstCategoryKey : null,
                                child: CategoryCard(
                                  imagePath: categoryCoverImage(productCategory),
                                  title: productCategory.name!,
                                  onTap: () {
                                    if (productCategory
                                        .categoryChildren!.isNotEmpty) {
                                      PageRouteUtils.pushWithFade(
                                        context,
                                        SubCategoryPage(
                                          categoryTitle: productCategory.name!,
                                          productCategory:
                                              productCategory.categoryChildren!,
                                        ),
                                      );
                                    } else {
                                      PageRouteUtils.pushWithFade(
                                        context,
                                        ProductPage(
                                            categoryId: productCategory.id!),
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ));
  }

  void getCategoriesApi() async {
    try {
      final ApiService apiService = ApiService();
      productCategoriesResponse = await apiService.productCategories(context);
      _last = productCategoriesResponse;
      if (!mounted) return;
      setState(() {
        apiLoading = false;
        productCategoriesResponse;
      });
      _maybeStartCategoryTutorial();
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        apiLoading = false;
      });
      print(e);
    }
  }

  void _maybeStartCategoryTutorial() =>
      maybeStartTutorial(TutorialPhase.categories, _showCategoryTutorial);

  void _showCategoryTutorial() {
    if (_firstCategoryKey.currentContext == null) {
      TutorialCoordinator().advanceTo(TutorialPhase.cart);
      eventBus.fire(TabSwitchEvent(2));
      return;
    }

    TutorialCoachMark(
      targets: [
        TargetFocus(
          keyTarget: _firstCategoryKey,
          shape: ShapeLightFocus.RRect,
          radius: 12,
          paddingFocus: 8,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (ctx, ctrl) => TutorialTooltip(
                title: 'Browse Categories',
                body: 'Tap any category to explore products in that section',
                controller: ctrl,
              ),
            ),
          ],
        ),
      ],
      colorShadow: Colors.black,
      opacityShadow: 0.80,
      hideSkip: true,
      onFinish: () {
        TutorialCoordinator().advanceTo(TutorialPhase.product);
        _goToProductPageForTutorial();
      },
      onSkip: () {
        TutorialCoordinator().complete();
        return true;
      },
    ).show(context: context);
  }

  void _goToProductPageForTutorial() {
    final first = _categories.firstOrNull;
    if (first == null || !mounted) {
      // fallback: skip product step, go straight to cart
      TutorialCoordinator().advanceTo(TutorialPhase.cart);
      eventBus.fire(TabSwitchEvent(2));
      return;
    }
    final categoryId = first.categoryChildren?.isNotEmpty == true
        ? first.categoryChildren!.first.id ?? ''
        : first.id ?? '';
    PageRouteUtils.pushWithFade(
      context,
      ProductPage(categoryId: categoryId),
    );
  }
}

/// The picture for a category tile: its own image, else the first image found
/// among its sub-categories (depth-first). Grouping categories (SAREES › Silk,
/// Tussar…) usually have no photo of their own, while their children do.
String categoryCoverImage(ProductCategory category) {
  final own = (category.image ?? '').trim();
  if (own.isNotEmpty) return own;
  for (final child in category.categoryChildren ?? const <ProductCategory>[]) {
    final found = categoryCoverImage(child);
    if (found.isNotEmpty) return found;
  }
  return '';
}
