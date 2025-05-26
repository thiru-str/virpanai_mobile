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

    final Uri uri = Uri.parse(url);
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

    switch (layoutOption) {
      case AppStrings.category:
        _navigateToCategory(context, layoutData);
        break;
      case AppStrings.product:
        _navigateToProduct(context, layoutData.redirectData!);
        break;
      case AppStrings.brand:
        _navigateToBrand(context, layoutData);
        break;
      case AppStrings.custom:
        _handleCustomRedirect(context, layoutData);
        break;
      default:
        debugPrint('Unknown layout option: $layoutOption');
    }
  }



  static void _handleCustomRedirect(BuildContext context, LayoutDatum layoutData) {
    final redirectData = layoutData.redirectData;
    if (redirectData == null) return;

    switch (redirectData.redirectType) {
      case AppStrings.reDirectSearch:
        _navigateToSearch(context, redirectData);
        break;
      case AppStrings.reDirectProduct:
        _navigateToProduct(context, redirectData);
        break;
      case AppStrings.reDirectLink:
        _launchExternalLink(redirectData);
        break;
      default:
        debugPrint('Unknown redirect type: ${redirectData.redirectType}');
    }
  }

  static void _navigateToCategory(BuildContext context, LayoutDatum layoutData) {
    if (layoutData.id == null) return;
    PageRouteUtils.pushWithFade(
      context,
      ProductPage(categoryId: layoutData.id!),
    );
  }

  static void _navigateToBrand(BuildContext context, LayoutDatum layoutData) {
    if (layoutData.id == null) return;
    PageRouteUtils.pushWithSlide(
      context,
      ProductPage(categoryId: layoutData.id!, isFromBrand: true),
    );
  }

  static void _navigateToSearch(BuildContext context, RedirectData redirectData) {
    final categoryId = redirectData.redirectSearchData?.category;
    if (categoryId == null || categoryId.isEmpty) return;

    PageRouteUtils.pushWithSlide(
      context,
      ProductPage(categoryId: categoryId),
    );
  }

  static void _navigateToProduct(BuildContext context, RedirectData redirectData) {
    final productId = redirectData.redirectProductData?.productId;
    if (productId == null || productId.isEmpty) return;

    PageRouteUtils.pushWithSlide(
      context,
      ProductDetailPage(productId: productId),
    );
  }

  static Future<void> _launchExternalLink(RedirectData redirectData) async {
    final url = redirectData.redirectUrlData?.url;
    if (url == null || url.isEmpty) return;

    await launchExternalUrl(url);
  }
}