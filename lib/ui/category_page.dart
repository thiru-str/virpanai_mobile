import 'package:flutter/material.dart';
import 'package:waioz/model/product_categories_response.dart';
import 'package:waioz/ui/widgets/category_views/category_views.dart';
import 'package:waioz/ui/widgets/floating_cart.dart';
import 'package:waioz/ui/widgets/no_orders_widget.dart';
import 'package:waioz/ui/widgets/screen_skeletons.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/shared_preferences_util.dart';

import '../api/api_service.dart';
import 'widgets/common_header_app_bar.dart';

class CategoryPage extends StatefulWidget {
  final bool isFromBottomNav;
  const CategoryPage({super.key, this.isFromBottomNav = false});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  // The tab is rebuilt on every visit: the last list shows at once while a
  // fresh one loads behind it, instead of a skeleton each time.
  static ProductCategoriesResponse? _last;

  ProductCategoriesResponse? productCategoriesResponse = _last;
  bool apiLoading = _last == null;

  List<ProductCategory> get _categories =>
      productCategoriesResponse?.productCategories ?? const <ProductCategory>[];

  /// Store-wide layout from admin Global Settings (theme.categoryView).
  static CategoryView _lastView = CategoryView.categoryView1;
  CategoryView _view = _lastView;

  @override
  void initState() {
    super.initState();
    _loadView();
    getCategoriesApi();
  }

  Future<void> _loadView() async {
    final v = categoryViewFrom(
        await SharedPreferencesUtil().getString('category_view'));
    _lastView = v;
    if (mounted && v != _view) setState(() => _view = v);
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
            ? const CategoryPageSkeleton()
            : _categories.isEmpty
                ? NoOrdersWidget(
                    message: AppStrings.no_categories_found,
                    buttonText: AppStrings.explore_categories,
                    iconPath: AppAssets.ic_cart_empty,
                    showExplore: widget.isFromBottomNav,
                    onButtonTap: () {},
                  )
                : categoryViewBody(_view, _categories));
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
}
