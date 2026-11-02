import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:waioz/ui/custom_page.dart';
import 'package:waioz/ui/order_detail_item_page.dart';
import 'package:waioz/utility/page_route_utils.dart';

import '../api/api_service.dart';
import '../model/home_page_response.dart';
import '../model/product_categories_response.dart';
import '../ui/product_detail_page.dart';
import '../ui/product_page.dart';
import 'app_strings.dart';

class RedirectUtils {
  static Future<void> launchExternalUrl(String url) async {
    if (url.isEmpty) return;

    final uri = Uri.parse(url);
    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  static void handleContentRedirect({
    required BuildContext context,
    required String layoutOption,
    required LayoutDatum layoutData,
  }) {
    final handler = _contentRedirectHandlers[layoutOption];
    if (handler != null) {
      handler(context, layoutData);
    } else {
      debugPrint('Unknown layout option: $layoutOption');
    }
  }

  static void handleContentRedirectViewAll({
    required BuildContext context,
    required RedirectData redirectData,
  }) {
    final handler = _viewAllRedirectHandlers[redirectData.redirectType];
    if (handler != null) {
      handler(context, redirectData);
    } else {
      debugPrint('Unknown redirect type: ${redirectData.redirectType}');
    }
  }

  // Handler maps as static final constants
  static final Map<String, Function(BuildContext, LayoutDatum)> _contentRedirectHandlers = {
    AppStrings.category: _navigateToCategory,
    AppStrings.product: (context, layoutData) => _navigateToProduct(context, layoutData, true),
    AppStrings.brand: _navigateToBrand,
    AppStrings.custom: _handleCustomRedirect,
  };

  static final Map<String, Function(BuildContext, RedirectData)> _viewAllRedirectHandlers = {
    AppStrings.reDirectSearch: _navigateToSearch,
    AppStrings.reDirectProduct: (context, redirectData) => _handleProductRedirect(context, redirectData),
    AppStrings.reDirectOrder: (context, redirectData) => _handleProductOrder(context, redirectData),
    AppStrings.reDirectPage: (context, redirectData) => _handleRedirectPage(context, redirectData),
    AppStrings.reDirectLink: (context, redirectData) => _handleLink(context, redirectData),
  };

  static void _handleCustomRedirect(BuildContext context, LayoutDatum layoutData) {
    final redirectData = layoutData.redirectData;
    if (redirectData == null) return;

    handleContentRedirectViewAll(
      context: context,
      redirectData: redirectData,
    );
  }

  static void _navigateToCategory(BuildContext context, LayoutDatum layoutData) {
    final categoryId = layoutData.id;
    if (categoryId == null) return;

    PageRouteUtils.pushWithFade(
      context,
      ProductPage(categoryId: categoryId),
    );
  }

  static void _navigateToBrand(BuildContext context, LayoutDatum layoutData) {
    final brandId = layoutData.id;
    if (brandId == null) return;

    PageRouteUtils.pushWithSlide(
      context,
      ProductPage(categoryId: brandId, isFromBrand: true),
    );
  }

  static void _navigateToSearch(BuildContext context, RedirectData redirectData) {
    final categoryId = redirectData.redirectSearchData?.category;

    final collectionId = redirectData.redirectSearchData?.collection??'';

    final tagId = redirectData.redirectSearchData?.tag??'';

    PageRouteUtils.pushWithSlide(
      context,
      ProductPage(categoryId: categoryId!,collectionId: collectionId,tagId: tagId,),
    );
  }

  static void _navigateToProduct(BuildContext context, LayoutDatum layoutData, bool isDirectProduct) {
    final productId = isDirectProduct
        ? layoutData.id
        : layoutData.redirectData?.redirectProductData?.productId;

    if (productId?.isEmpty ?? true) return;

    PageRouteUtils.pushWithSlide(
      context,
      ProductDetailPage(productId: productId!),
    );
  }

  static void _handleProductRedirect(BuildContext context, RedirectData redirectData) {
    final productId = redirectData.redirectProductData?.productId;
    if (productId?.isEmpty ?? true) return;

    PageRouteUtils.pushWithSlide(
      context,
      ProductDetailPage(productId: productId!),
    );
  }

  static void _handleProductOrder(BuildContext context, RedirectData redirectData) {
    final orderId = redirectData.redirectOrderData?.orderId;
    if (orderId?.isEmpty ?? true) return;

    PageRouteUtils.pushWithSlide(
      context,
      OrderDetailItemPage(orderId: orderId),
    );
  }

  static void _handleRedirectPage(BuildContext context, RedirectData redirectData) {
    final slug = redirectData.redirectPageData?.slug;
    if (slug?.isEmpty ?? true) return;

    PageRouteUtils.pushWithSlide(
      context,
      CustomPage(slug: slug),
    );
  }

  /// A "Link" redirect may be a full web address (opened outside the app) or
  /// a storefront path the web builder wrote — categories/<handle>,
  /// results/<text>, search?q=<text> — which the app opens natively, so a
  /// section copied from the web home works the same in the app.
  static Future<void> _handleLink(BuildContext context, RedirectData redirectData) async {
    final raw = (redirectData.redirectUrlData?.url ?? '').trim();
    if (raw.isEmpty) return;
    final uri = Uri.tryParse(raw);
    if (uri != null && uri.hasScheme) {
      await _launchExternalLink(redirectData);
      return;
    }
    var segments = (uri?.pathSegments ?? raw.split('/')).where((s) => s.isNotEmpty).toList();
    // the web storefront may prefix a country code ("in/categories/…")
    if (segments.length > 1 && segments.first.length == 2) segments = segments.sublist(1);
    if (segments.isEmpty) return;
    final head = segments.first.toLowerCase();
    final rest = segments.skip(1).map(Uri.decodeComponent).join(' ').trim();

    if ((head == 'categories' || head == 'category') && segments.length > 1) {
      final id = await _categoryIdForHandle(context, segments.last);
      if (!context.mounted) return;
      PageRouteUtils.pushWithSlide(
        context,
        id != null ? ProductPage(categoryId: id) : ProductPage(initialQuery: rest.replaceAll('-', ' ')),
      );
      return;
    }
    if (head == 'results' || head == 'search') {
      final query = rest.isNotEmpty ? rest : (uri?.queryParameters['q'] ?? '');
      PageRouteUtils.pushWithSlide(context, ProductPage(initialQuery: query));
      return;
    }
    debugPrint('Unhandled storefront link: $raw');
  }

  static Future<List<ProductCategory>>? _categories;

  static Future<String?> _categoryIdForHandle(BuildContext context, String handle) async {
    try {
      _categories ??= ApiService()
          .productCategories(context)
          .then((r) => r.productCategories ?? <ProductCategory>[]);
      final all = <ProductCategory>[];
      void walk(List<ProductCategory> list) {
        for (final c in list) {
          all.add(c);
          walk(c.categoryChildren ?? const []);
        }
      }
      walk(await _categories!);
      for (final c in all) {
        if ((c.handle ?? '').toLowerCase() == handle.toLowerCase()) return c.id;
      }
    } catch (e) {
      _categories = null;
      debugPrint('Category lookup failed: $e');
    }
    return null;
  }

  static Future<void> _launchExternalLink(RedirectData redirectData) async {
    final url = redirectData.redirectUrlData?.url;
    if (url?.isEmpty ?? true) return;

    await launchExternalUrl(url!);
  }

}