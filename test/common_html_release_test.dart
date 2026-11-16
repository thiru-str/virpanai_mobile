import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waioz/utility/common_html.dart';

void main() {
  testWidgets('product HTML renders after the deferred first frame', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: CommonHtmlWidget(
          htmlContent: '<div><p style="color:red">Fresh groceries</p>'
              '<ul><li>Daily essentials</li></ul></div>',
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.textContaining('Fresh groceries', findRichText: true), findsWidgets);
    expect(find.textContaining('Daily essentials', findRichText: true), findsWidgets);
  });
}
