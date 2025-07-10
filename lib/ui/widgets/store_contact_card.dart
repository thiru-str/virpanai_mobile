import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class StoreContactCard extends StatelessWidget {
  final String imageUrl;
  final String storeName;
  final String address;
  final String phoneNumber;
  final String email;

  const StoreContactCard({
    Key? key,
    required this.imageUrl,
    required this.storeName,
    required this.address,
    required this.phoneNumber,
    required this.email,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔶 Logo + Store Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      Container(color: Colors.grey.shade200),
                  errorWidget: (_, __, ___) =>
                  const Icon(Icons.store, size: 40),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      storeName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),

          const SizedBox(height: 12),

          // 📱 Contact Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Phone Number',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      phoneNumber,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.grey.shade300,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Email ID',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
