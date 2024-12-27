import 'package:flutter/material.dart';
import 'package:waioz/utility/font_utils.dart';

class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String price;
  final bool isFavorite;
  final VoidCallback onTapFavorite;
  final VoidCallback onTapCard;

  const ProductCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.price,
    this.isFavorite = false,
    required this.onTapFavorite,
    required this.onTapCard,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapCard,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
                  child: Image.network(
                    imageUrl,
                     height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // Favorite Icon
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onTapFavorite,
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
            // Product Details
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: FontUtils.circularStdStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$$price',
                    style: FontUtils.circularStdStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
