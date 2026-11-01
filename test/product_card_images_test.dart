import 'package:flutter_test/flutter_test.dart';
import 'package:waioz/model/product_response.dart';

Map<String, dynamic> _photo(String name) => {'url': 'https://cdn.example.com/$name.webp'};

Map<String, dynamic> _variant(List<String> names) => {
      'metadata': {'images': names.map(_photo).toList()},
    };

void main() {
  test('a product\'s own photos win', () {
    final product = Product.fromJson({
      'thumbnail': 'https://cdn.example.com/own.webp',
      'images': [_photo('own')],
      'variants': [_variant(['violet'])],
    });
    expect(product.cardImages.map((i) => i.url), ['https://cdn.example.com/own.webp']);
    expect(product.cardThumbnail, 'https://cdn.example.com/own.webp');
  });

  test('with no main photo, a card uses the first variant that has some', () {
    final product = Product.fromJson({
      'thumbnail': null,
      'images': [],
      'variants': [_variant([]), _variant(['violet', 'violet-2'])],
    });
    expect(product.cardImages.length, 2);
    expect(product.cardThumbnail, 'https://cdn.example.com/violet.webp');
    // the product page still treats them as the variant's, not the product's
    expect(product.images, isEmpty);
  });

  test('no photos anywhere leaves the card to its fallback', () {
    final product = Product.fromJson({'thumbnail': '', 'images': [], 'variants': []});
    expect(product.cardImages, isEmpty);
    expect(product.cardThumbnail, '');
  });
}
