import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waioz/model/product_response.dart';
import 'package:waioz/ui/widgets/product_card_12.dart';

Product _product() => Product.fromJson({
      'id': 'prod_1',
      'title': 'Sakthi Fennel Powder',
      'thumbnail': '',
      'images': [],
      'variants': [
        {
          'id': 'v1',
          'calculated_price': {'calculated_amount': 17, 'original_amount': 40},
        }
      ],
    });

void main() {
  testWidgets('lays out in a sideways rail, which gives it no width', (t) async {
    await t.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            for (var i = 0; i < 3; i++) ProductCard12(product: _product(), onTapCard: () {}),
          ]),
        ),
      ),
    ));
    await t.pump();
    expect(t.takeException(), isNull);
    expect(t.getSize(find.byType(ProductCard12).first).width, 170);
  });

  testWidgets('takes the width of a grid cell', (t) async {
    await t.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(child: SizedBox(width: 160, child: ProductCard12(product: _product(), onTapCard: () {}))),
      ),
    ));
    await t.pump();
    expect(t.takeException(), isNull);
    expect(t.getSize(find.byType(ProductCard12)).width, 160);
  });
}
