class ProductCategory {
  final int id;
  final String name;
  final String imageUrl;
  final List<Product> products;

  ProductCategory({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.products,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['category']['_id'],
      name: json['category']['category_name'],
      imageUrl: json['category']['image'],
      products: (json['products'][0] as List)
          .map((productJson) => Product.fromJson(productJson))
          .toList(),
    );
  }
}

class Product {
  final int id;
  final String name;
  final String imageUrl;
  final String price;
  int quantity = 1;
  double totalPrice = 0.0;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'],
      name: json['product_name'],
      imageUrl: json['image'],
      price: json['price'],
    );
  }
}
