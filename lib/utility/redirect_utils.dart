import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:waioz/utility/page_route_utils.dart';

import '../model/home_page_response.dart';
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
    AppStrings.reDirectLink: (_, redirectData) => _launchExternalLink(redirectData),
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

    PageRouteUtils.pushWithSlide(
      context,
      ProductPage(categoryId: categoryId!,collectionId: collectionId,),
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

  static Future<void> _launchExternalLink(RedirectData redirectData) async {
    final url = redirectData.redirectUrlData?.url;
    if (url?.isEmpty ?? true) return;

    await launchExternalUrl(url!);
  }

}