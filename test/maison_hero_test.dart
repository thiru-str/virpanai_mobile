import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/ui/widgets/home/maison/maison_sections.dart';
import 'package:waioz/ui/widgets/home/maison/maison_shared.dart';

Future<void> _open(WidgetTester tester, Map<String, dynamic> slide) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: MaisonHero1(
        content: Content.fromJson({
          'layout_name': 'MaisonHero1',
          'layout_data': [
            {'image': '', ...slide}
          ],
        }),
      ),
    ),
  ));
  await tester.pump();
}

double _zoomEnd(WidgetTester t) => t.widget<TweenAnimationBuilder<double>>(find.byType(TweenAnimationBuilder<double>)).tween.end!;

bool _bottomScrim(WidgetTester t) => t.widgetList<DecoratedBox>(find.byType(DecoratedBox)).any((b) {
      final d = b.decoration;
      return d is BoxDecoration && d.gradient is LinearGradient && (d.gradient as LinearGradient).begin == Alignment.bottomCenter;
    });

void main() {
  testWidgets('a slide with its own words keeps the headline, zoom and scrim', (t) async {
    await _open(t, {'title': 'Grace in', 'feature_text': 'every drape.', 'button_text': 'Shop silk sarees'});
    expect(find.text('Grace in'), findsOneWidget);
    expect(find.byType(MaisonPill), findsOneWidget);
    expect(_zoomEnd(t), 1.08);
    expect(_bottomScrim(t), isTrue);
  });

  testWidgets('finished artwork shows clean', (t) async {
    await _open(t, {'title': '', 'sub_title': '  '});
    expect(find.byType(MaisonPill), findsNothing);
    expect(_zoomEnd(t), 1.0);
    expect(_bottomScrim(t), isFalse);
  });

  testWidgets('a button alone is not finished artwork', (t) async {
    await _open(t, {'button_text': 'Shop now'});
    expect(find.byType(MaisonPill), findsOneWidget);
    expect(_bottomScrim(t), isTrue);
  });
}
