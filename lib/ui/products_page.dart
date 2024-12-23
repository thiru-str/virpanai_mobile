import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waioz/ui/products_page_review.dart';

import '../api/api_service.dart';
import '../model/product_model.dart';
import '../product_cart.dart';
import '../utility/AppColors.dart';
import '../utility/dotted_line.dart';
import '../utility/shared_preferences_util.dart';

class CreateOrderPage extends StatefulWidget {
  @override
  _CreateOrderPageState createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  final ApiService apiService = ApiService();
  List<ProductCategory> categories = [];
  List<Product> displayedProducts = [];
  int selectedCategoryIndex = 0;
  final ProductCart productCart = ProductCart();

  bool loadProductReview = false;
  int? branchId;
  String? token;
  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  void fetchProducts() async {

    try {
      categories =
          await apiService.getAllProducts();
      if (categories.isNotEmpty) {
        displayedProducts = categories[0].products;
      }
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  void onCategorySelected(int index) {
    setState(() {
      selectedCategoryIndex = index;
      displayedProducts = categories[index].products;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      body: loadProductReview? ProductsPageReview(productCart: productCart) :Padding(
        padding: const EdgeInsets.all(16.0),
        child: categories.isEmpty
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Categories',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 100,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: categories.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final category = categories[index];
                                    return GestureDetector(
                                      onTap: () => onCategorySelected(index),
                                      child: Container(
                                        margin: const EdgeInsets.only(right: 10),
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: selectedCategoryIndex == index
                                              ? AppColors.primary.withAlpha(5)
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                              color: selectedCategoryIndex == index
                                                  ? AppColors.primary
                                                  : AppColors.borderColor,
                                              width: 1.95),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(category.name,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500,
                                                )),
                                            Text('${category.products.length} Items',
                                                style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    color: selectedCategoryIndex == index
                                                        ? Colors.black
                                                        : Colors.grey)),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text('Most Popular',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.all(8.0),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                final product = displayedProducts[index];
                                return GestureDetector(
                                  onTap: () {
                                    productCart.addProduct(product);
                                    setState(() {
                                      productCart;
                                    });
                                  },
                                  child: SizedBox(
                                    height: 140,
                                    width: 140,
                                    child: Card(
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(8),
                                              topRight: Radius.circular(8),
                                            ),
                                            child: Container(
                                              color: Colors.white,
                                              child: Image.network(
                                                product.imageUrl,
                                                height: 140,
                                                width: double.infinity,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  product.name,
                                                  style: const TextStyle(
                                                      fontWeight: FontWeight.bold, fontSize: 12),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '₹${product.price}',
                                                  style: const TextStyle(
                                                      color: Colors.green, fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              childCount: displayedProducts.length,
                            ),
                          ),
                        ),
                      ],
                    )

                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.borderColor, width: 3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          // Scrollable ListView (occupies remaining space)
                          Expanded(
                            child: ListView.builder(
                              /*separatorBuilder: (context, index) => const Divider(
                                color: AppColors.divider, // Customize the color of the divider
                                thickness: 1,                 // Adjust the thickness of the divider
                                indent: 16,                   // Optional: Indent from left
                                endIndent: 16,                // Optional: Indent from right
                              ),*/
                              itemCount: productCart.products.length,
                              itemBuilder: (context, index) {
                                final product = productCart.products[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric( horizontal: 8.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Product Image
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10.0),
                                        child: Image.network(
                                          product.imageUrl,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Product Details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Product title row
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    product.name,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                                                  onPressed: () {
                                                    productCart.removeProduct(product);
                                                    setState(() {
                                                      productCart;
                                                    });
                                                  },
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(),
                                                ),
                                              ],
                                            ),

                                            // Reduced vertical space here
                                            const SizedBox(height: 2), // Reduced space between title and quantity fields

                                            // Quantity controls and price row
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    IconButton(
                                                      icon: Container(
                                                        decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          border: Border.all(color: AppColors.divider),
                                                          borderRadius: BorderRadius.circular(5),
                                                        ),
                                                        padding: const EdgeInsets.all(4),
                                                        child: const Icon(
                                                          Icons.remove,
                                                          color: AppColors.minusIconColor,
                                                          size: 14,
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        productCart.removeProduct(product);
                                                        setState(() {
                                                          productCart;
                                                        });
                                                      },
                                                      padding: EdgeInsets.zero,
                                                      constraints: const BoxConstraints(),
                                                    ),
                                                    const SizedBox(width: 8), // Control spacing between quantity and buttons
                                                    Text(
                                                      product.quantity.toString(),
                                                      style: const TextStyle(fontSize: 16),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    IconButton(
                                                      icon: Container(
                                                        decoration: BoxDecoration(
                                                          color: AppColors.plusBackground,
                                                          borderRadius: BorderRadius.circular(5),
                                                        ),
                                                        padding: const EdgeInsets.all(4),
                                                        child: const Icon(
                                                          Icons.add,
                                                          color: Colors.white,
                                                          size: 14,
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        productCart.addProduct(product);
                                                        setState(() {
                                                          productCart;
                                                        });
                                                      },
                                                      padding: EdgeInsets.zero,
                                                      constraints: const BoxConstraints(),
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(right: 8.0),
                                                  child: Text(
                                                    '₹${(double.parse(product.price) * product.quantity).toStringAsFixed(2)}',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                      ,
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                          // Fixed-height Grey Summary Container
                          Container(
                            color: AppColors.greyBackground,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Item", style: TextStyle(color: AppColors.cartGreyText)),
                                      Text("(${productCart.products.length}) Items",
                                          style: const TextStyle(color: AppColors.appItemText)),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Sub Total", style: TextStyle(color: AppColors.cartGreyText)),
                                      Text("₹${productCart.priceDetails!.subTotal}",
                                          style: const TextStyle(color: Colors.black)),
                                    ],
                                  ),
                                ),
                                const DottedLine(
                                  height: 1,
                                  dotWidth: 10.0,
                                  spaceWidth: 8.0,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Total Payment", style: TextStyle(fontWeight: FontWeight.bold)),
                                      Text("₹${productCart.priceDetails!.total}",
                                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                const DottedLine(
                                  height: 1,
                                  dotWidth: 10.0,
                                  spaceWidth: 8.0,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Proceed to next step
                                      setState(() {
                                        loadProductReview = true;
                                      });
                                    },
                                    child: const Center(child: Text("Next")),
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      foregroundColor: Colors.white,
                                      backgroundColor: AppColors.primary,
                                      minimumSize: const Size(double.infinity, 50),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),


                ],
              ),
      ),
    );
  }
}

