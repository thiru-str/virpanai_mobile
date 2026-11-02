import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waioz/ui/account_settings_page.dart';
import 'package:waioz/utility/app_strings.dart';

Future<void> _open(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: AccountSettingsPage()));
  await tester.pump();
}

void main() {
  testWidgets('lists profile and account actions', (t) async {
    await _open(t);
    expect(find.text(AppStrings.edit_profile), findsOneWidget);
    expect(find.text(AppStrings.deleteAccount), findsOneWidget);
  });

  testWidgets('deleting asks first, and Cancel leaves everything as it was', (t) async {
    await _open(t);
    await t.tap(find.text(AppStrings.deleteAccount));
    await t.pumpAndSettle();
    expect(find.text(AppStrings.delete_account_confirmation), findsOneWidget);

    await t.tap(find.text(AppStrings.cancel));
    await t.pumpAndSettle();
    expect(find.text(AppStrings.delete_account_confirmation), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text(AppStrings.deleteAccount), findsOneWidget);
  });

  testWidgets('tapping outside the dialog does not delete', (t) async {
    await _open(t);
    await t.tap(find.text(AppStrings.deleteAccount));
    await t.pumpAndSettle();
    await t.tapAt(const Offset(5, 5));
    await t.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  test('customer-facing wording carries no platform name', () {
    expect(AppStrings.deleteAccountDescription.toLowerCase(), isNot(contains('virpanai')));
  });
}
