import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waioz/ui/customer_info_form.dart';
import 'package:waioz/ui/payment_input_page.dart';
import 'package:waioz/ui/payment_selection_widget.dart';

import '../api/api_service.dart';
import '../model/product_model.dart';
import '../product_cart.dart';
import '../utility/AppColors.dart';
import '../utility/dotted_line.dart';

class ProductsPageReview extends StatefulWidget {
  late ProductCart productCart;

   ProductsPageReview({super.key, required this.productCart});

  @override
  _ProductsPageReviewState createState() => _ProductsPageReviewState();
}

class _ProductsPageReviewState extends State<ProductsPageReview> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.greyBackground,
        body: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      PaymentMethodSelection(),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 45,
                        width: double.infinity,
                        child: ElevatedButton(
                          child: const Text('Reward Redemption'),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            foregroundColor: Colors.white,
                            backgroundColor: AppColors.primary,
                          ),
                          onPressed: () {},
                        ),
                      ),
                      Expanded(child: PaymentPage()),
                      // Wrap PaymentPage in Expanded
                    ],
                  ),
                ),
              ),
              Expanded(child: CustomerInfoForm()),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 50),
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
                          child: ListView.separated(
                            separatorBuilder: (context, index) => const Divider(
                              color: AppColors.divider, // Customize the color of the divider
                              thickness: 1,                 // Adjust the thickness of the divider
                              indent: 16,                   // Optional: Indent from left
                              endIndent: 16,                // Optional: Indent from right
                            ),
                            itemCount: widget.productCart.products.length,
                            itemBuilder: (context, index) {
                              final product = widget.productCart.products[index];
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
                                                  widget.productCart.removeProduct(product);
                                                  setState(() {
                                                    widget.productCart;
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
                                                      widget.productCart.removeProduct(product);
                                                      setState(() {
                                                        widget.productCart;
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
                                                      widget.productCart.addProduct(product);
                                                      setState(() {
                                                        widget.productCart;
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
                                    Text("(${widget.productCart.products.length}) Items",
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
                                    Text("₹${widget.productCart.priceDetails!.subTotal}",
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
                                    Text("₹${widget.productCart.priceDetails!.total}",
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
                                    showOrderConfirmationDialog(context);
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
              ),
            ],
          ),
        ));
  }

  void showOrderConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Container(
            width: 350,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success Icon
                  SvgPicture.asset(
                    'images/order_success_icon.svg',
                    height: 80,
                  ),
                  SizedBox(height: 16),

                  // Confirmation Message
                  Text(
                    "Order Confirmed!",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Your order has been placed successfully",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),

                  // Amount Display
                  Text(
                    "₹ 20.00",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    "Remaining Amount",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Action Buttons
                  ElevatedButton(
                    onPressed: () {
                      // Print Ticket action
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7)),
                      foregroundColor: Colors.black,
                      backgroundColor: AppColors.buttonBgColor,
                      minimumSize: Size(double.infinity, 48),
                    ),
                    child: Text("Print Ticket"),
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      // Email Receipt action
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7)),
                      foregroundColor: Colors.black,
                      elevation: 0,
                      backgroundColor: AppColors.buttonBgColor,
                      minimumSize: Size(double.infinity, 48),
                    ),
                    child: Text("Email Receipt"),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7)),
                      foregroundColor: Colors.white,
                      backgroundColor: AppColors.primary,
                      minimumSize: Size(double.infinity, 48),
                    ),
                    child: Text("Back To Order"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

}
