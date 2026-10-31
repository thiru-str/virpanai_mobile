import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/ui/widgets/home/maison/maison_shared.dart';
import 'package:waioz/ui/widgets/home/maison/maison_viewers.dart';

// No video or image on these items, so no platform player is needed.
List<LayoutDatum> _reels(int n) => [
      for (var i = 0; i < n; i++) LayoutDatum.fromJson({'image': '', 'title': 'Film ${i + 1}'})
    ];

Future<void> _open(WidgetTester tester, int count, {int start = 0, bool still = false}) async {
  await tester.pumpWidget(MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(size: const Size(390, 844), disableAnimations: still),
      child: MaisonReelViewer(
        content: Content.fromJson({'layout_name': 'MaisonReels1', 'layout_data': []}),
        items: _reels(count),
        start: start,
        colors: const MaisonColors(Colors.white, Colors.brown, Colors.black),
      ),
    ),
  ));
  await tester.pump();
}

void main() {
  testWidgets('first reel shows the next arrow and the position only', (t) async {
    await _open(t, 3);
    expect(find.byTooltip('Next film'), findsOneWidget);
    expect(find.byTooltip('Previous film'), findsNothing);
    expect(find.text('1 / 3'), findsOneWidget);
  });

  testWidgets('arrows move between reels, and the last one has no next', (t) async {
    await _open(t, 3);
    await t.tap(find.byTooltip('Next film'));
    await t.pumpAndSettle();
    expect(find.text('2 / 3'), findsOneWidget);
    expect(find.byTooltip('Previous film'), findsOneWidget);

    await t.tap(find.byTooltip('Next film'));
    await t.pumpAndSettle();
    expect(find.text('3 / 3'), findsOneWidget);
    expect(find.byTooltip('Next film'), findsNothing);

    await t.tap(find.byTooltip('Previous film'));
    await t.pumpAndSettle();
    expect(find.text('2 / 3'), findsOneWidget);
  });

  testWidgets('a swipe updates the position too', (t) async {
    await _open(t, 3);
    await t.fling(find.text('Film 1'), const Offset(0, -500), 1500);
    await t.pumpAndSettle();
    expect(find.text('2 / 3'), findsOneWidget);
  });

  testWidgets('a lone reel has no navigation', (t) async {
    await _open(t, 1);
    expect(find.byTooltip('Next film'), findsNothing);
    expect(find.text('1 / 1'), findsNothing);
  });

  testWidgets('opens at the tapped reel', (t) async {
    await _open(t, 4, start: 2);
    expect(find.text('3 / 4'), findsOneWidget);
    expect(find.byTooltip('Previous film'), findsOneWidget);
  });

  testWidgets('the nudge ends on its own and is skipped with animations off', (t) async {
    await _open(t, 3);
    await t.pump(const Duration(seconds: 2));
    await t.pump(const Duration(seconds: 2));
    expect(t.hasRunningAnimations, isFalse);

    await _open(t, 3, still: true);
    expect(t.hasRunningAnimations, isFalse);
  });
}
