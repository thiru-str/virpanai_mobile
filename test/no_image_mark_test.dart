import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waioz/ui/widgets/home/basket/basket_shared.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_config.dart';
import 'package:waioz/utility/image_fallback_widget.dart';

void main() {
  tearDown(() => NoImageMark.debugGeneric = false);

  testWidgets('shows the bundled logo when the branch sets one, else the generic mark', (t) async {
    await t.pumpWidget(const MaterialApp(home: ImageFallbackWidget(w: 140, h: 140)));
    if (AppConfig.placeholderLogo.isEmpty) {
      expect(find.byType(SvgPicture), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    } else {
      final image = t.widget<Image>(find.byType(Image));
      expect((image.image as AssetImage).assetName, AppConfig.placeholderLogo);
      expect(image.fit, BoxFit.contain);
      expect(image.width, closeTo(84, 0.01));
    }
  });

  testWidgets('copes with no size or an infinite width', (t) async {
    await t.pumpWidget(const MaterialApp(
      home: Column(children: [
        SizedBox(width: 90, height: 90, child: ImageFallbackWidget()),
        SizedBox(width: 90, height: 60, child: ImageFallbackWidget(w: double.infinity, h: 60)),
      ]),
    ));
    expect(t.takeException(), isNull);
  });

  testWidgets('previews stay neutral', (t) async {
    NoImageMark.debugGeneric = true;
    await t.pumpWidget(const MaterialApp(home: SizedBox(width: 90, height: 90, child: BasketImage(url: ''))));
    expect(find.byType(Image), findsNothing);
    expect(find.byType(ColoredBox), findsWidgets);
    expect(AppAssets.ic_no_image, isNotEmpty);
  });
}
