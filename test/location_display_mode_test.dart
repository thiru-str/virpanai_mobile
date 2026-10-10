import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waioz/model/public_detail_model.dart';
import 'package:waioz/ui/widgets/location_coming_soon.dart';

void main() {
  test('outside coverage follows the admin location display mode', () {
    final comingSoon = PublicDetailsResponse.fromJson({
      'serviceable': false,
      'location_display_mode': 'coming_soon',
      'show_coming_soon': true,
    });
    expect(comingSoon.isLocationComingSoon, isTrue);
    final showProducts = PublicDetailsResponse.fromJson({
      'serviceable': false,
      'location_display_mode': 'show_products',
      'show_coming_soon': false,
      'store_id': 'common-store',
    });
    expect(showProducts.isLocationComingSoon, isFalse);
    expect(showProducts.storeId, 'common-store');
    expect(PublicDetailsResponse.fromJson(showProducts.toJson()).isLocationComingSoon, isFalse);
  });

  test('covered locations and legacy responses remain compatible', () {
    expect(PublicDetailsResponse.fromJson({'serviceable': true}).isLocationComingSoon, isFalse);
    expect(PublicDetailsResponse.fromJson({'serviceable': false}).isLocationComingSoon, isTrue);
    expect(PublicDetailsResponse.fromJson({}).isLocationComingSoon, isFalse);
  });

  testWidgets('coming soon fits a phone and allows changing location', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var changes = 0;
    await tester.pumpWidget(MaterialApp(home: Scaffold(
      body: SingleChildScrollView(child: LocationComingSoon(onChangeLocation: () => changes++)),
    )));
    expect(find.text('coming soon.'), findsOneWidget);
    await tester.ensureVisible(find.text('Change location'));
    await tester.tap(find.text('Change location'));
    expect(changes, 1);
    expect(tester.takeException(), isNull);
  });
}
