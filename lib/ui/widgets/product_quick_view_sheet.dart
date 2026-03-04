import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/image_fallback_widget.dart';
import '../../api/api_service.dart';
import 'package:waioz/model/product_response.dart' as ProductResponse;

import '../../model/view_cart_model.dart';
import '../../utility/app_strings.dart';
import '../../utility/currency_util.dart';

class ProductQuickViewSheet extends StatefulWidget {
  final String productId;

  const ProductQuickViewSheet({Key? key, required this.productId})
      : super(key: key);

  @override
  State<ProductQuickViewSheet> createState() => _ProductQuickViewSheetState();
}

class _ProductQuickViewSheetState extends State<ProductQuickViewSheet> {
  ProductResponse.Product? product;
  int selectedQuantity = 1;
  ProductResponse.Variant? selectedVariant;
  String? selectedVariantId;
  Map<String, ProductResponse.Value?> selectedOptions = {};

  @override
  void initState() {
    super.initState();
    fetchProduct();
  }

  Future<void> fetchProduct() async {
    final apiService = ApiService();
    final response = await apiService.productDetail(context, widget.productId);
    setState(() {
      product = response.product;
    });
    if ((product?.options ?? []).isNotEmpty) {
      for (var option in product!.options!) {
        final firstValue = (option.values != null && option.values!.isNotEmpty)
            ? option.values!.first
            : null;
        if (option.id != null) {
          selectedOptions[option.id!] = firstValue;
        }
      }
    }
    updateVariant();
  }

  // void updateVariant() {
  //   if (product == null) return;
  //   for (final variant in product!.variants!) {
  //     final variantOptionIds = variant.options!.map((opt) => opt.id).toSet();
  //     final selectedOptionIds =
  //         selectedOptions.values.map((optVal) => optVal?.id).toSet();

  //     final isMatch = selectedOptionIds.length == variantOptionIds.length &&
  //         variantOptionIds.containsAll(selectedOptionIds);

  //     if (isMatch) {
  //       setState(() {
  //         selectedVariant = variant;
  //         selectedVariantId = variant.id;
  //       });
  //       break;
  //     }
  //   }
  // }
  void updateVariant() {
    if (product?.variants == null) return;

    for (final variant in product!.variants ?? []) {
      final variantOptionIds = (variant.options ?? [])
          .map((opt) => opt.id)
          .whereType<String>()
          .toSet();

      final selectedOptionIds = selectedOptions.values
          .map((optVal) => optVal?.id)
          .whereType<String>()
          .toSet();

      final isMatch = selectedOptionIds.length == variantOptionIds.length &&
          variantOptionIds.containsAll(selectedOptionIds);

      if (isMatch) {
        setState(() {
          selectedVariant = variant;
          selectedVariantId = variant.id;
        });
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              // Remove bottom padding here since the button will overlap
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: product == null
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      controller: scrollController,
                      // Add padding at the bottom of the scrollable content
                      padding: const EdgeInsets.only(
                          bottom: 100), // Matches button height
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildImageSection(),
                          const SizedBox(height: 16),
                          Text(
                            product?.title ?? '',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          buildPrice(),
                          const SizedBox(height: 8),
                          buildVariants(),
                        ],
                      ),
                    ),
            ),
            Positioned(
              bottom: 16, // Adjust this value as needed
              left: 16,
              right: 16,
              child: Container(
                // Remove the white background container if not needed
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<int>(
                        value: selectedQuantity,
                        isExpanded: true,
                        underline: Container(),
                        onChanged: (value) =>
                            setState(() => selectedQuantity = value ?? 0),
                        items: List.generate(10, (i) => i + 1)
                            .map((qty) => DropdownMenuItem(
                                value: qty, child: Text('$qty')))
                            .toList(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: buildAddToCartButton()),
                  ],
                ),
              ),
            ),
            // Your close button remains the same
            Positioned(
              top: 8,
              right: 12,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 4)
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.close, size: 20),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildImageSection() {
    return SizedBox(
      height: 250,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: product?.images?.length ?? 0,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, index) {
          return Container(
            width: 180,
            decoration: BoxDecoration(color: Colors.grey.shade200),
            child: CachedNetworkImage(
              imageUrl: product!.images![index].url!,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => const ImageFallbackWidget(
                w: 180,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildPrice() {
    final price =
        selectedVariant?.calculatedPrice?.rawCalculatedAmount?.value ?? '0';
    return Text(
      CurrencyUtil.appendCurrency(price),
      style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.green.shade800),
    );
  }

  Widget buildVariants() {
    final options = product?.options ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: options.map((option) {
        final optionId = option.id;
        if (optionId == null) return SizedBox.shrink();

        final values = option.values ?? [];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                option.title ?? '',
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: values.map((val) {
                  final isSelected = selectedOptions[optionId]?.id == val.id;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedOptions[optionId] = val;
                        updateVariant();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: isSelected ? Colors.black : Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                        color: isSelected ? Colors.black : Colors.white,
                      ),
                      child: Text(
                        val.value ?? '',
                        style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget buildAddToCartButton() {
    return ElevatedButton(
      onPressed: selectedVariantId == null
          ? null
          : () async {
              final apiService = ApiService();
              await apiService.addCart(
                  context, selectedQuantity, selectedVariantId!);
              final cartResponse = await apiService.getCart(context);
              eventBus.fire(ViewCartModel(
                cartResponse.cart?.items?.length ?? 0,
                cartResponse.cart?.items
                    ?.map((i) => i.thumbnail ?? "")
                    .toList(),
              ));
              Navigator.pop(context);
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const Text(AppStrings.add_to_cart,
          style: TextStyle(color: Colors.white, fontSize: 16)),
    );
  }
}
