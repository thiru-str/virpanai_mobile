import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waioz/ui/minipos/minipos_vendor_form_fields.dart';
import 'package:waioz/ui/minipos/minipos_widgets.dart';
import 'package:waioz/utility/app_colors.dart';

void main() {
  const businesses = [
    'Grocery',
    'Jewellery',
    'Miscellaneous',
    'E-commerce',
    'B2B',
    'Retail and Shopping',
    'Travel and Hospitality',
    'Professional Services (Doctors, Lawyers, Architects, CAs, and other Professionals)',
  ];

  Future<void> render(WidgetTester tester, Widget child,
      {Size size = const Size(360, 720),
      double scale = 1,
      double keyboard = 0}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      // Deliberately different outer theme: the sheet must use Gowelmart colors
      // even when Navigator renders it outside the MiniPOS subtree.
      theme: ThemeData(colorSchemeSeed: Colors.purple),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(scale),
          viewInsets: EdgeInsets.only(bottom: keyboard),
        ),
        child: child!,
      ),
      home: MiniPosScaffold(
        appBar: AppBar(title: const Text('Connect Vendor')),
        body: Form(
            child:
                ListView(padding: const EdgeInsets.all(16), children: [child])),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('text entry never forces capitalization or changes typed case',
      (tester) async {
    final controller = TextEditingController(text: 'visvam mobile');
    addTearDown(controller.dispose);
    await render(tester,
        MiniPosVendorTextField(controller: controller, label: 'Vendor name'));
    final field = tester.widget<TextFormField>(find.byType(TextFormField));
    // TextFormField forwards configuration to the editable TextField.
    final text = tester.widget<TextField>(find.byType(TextField));
    expect(text.textCapitalization, TextCapitalization.none);
    expect(text.autocorrect, isFalse);
    expect(field.controller!.text, 'visvam mobile');
    await tester.enterText(find.byType(TextFormField), 'my Shop abc');
    expect(controller.text, 'my Shop abc');
    expect(tester.takeException(), isNull);
  });

  testWidgets('account picker uses branded sheet and preserves canonical value',
      (tester) async {
    String? chosen;
    await render(
        tester,
        MiniPosVendorSelectField(
          label: 'Account type',
          value: 'BUSINESS',
          items: const ['BUSINESS', 'INDIVIDUAL'],
          onChanged: (value) => chosen = value,
        ));
    expect(find.byType(DropdownButtonFormField<String>), findsNothing);
    expect(find.text('Business'), findsOneWidget);
    await tester.tap(find.text('Business'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('Search account type'), findsNothing);
    final item = find.widgetWithText(ListTile, 'Individual');
    expect(
        Theme.of(tester.element(item)).colorScheme.primary, AppColors.primary);
    await tester.tap(item);
    await tester.pumpAndSettle();
    expect(chosen, 'INDIVIDUAL');
    expect(find.text('Individual'), findsOneWidget);
  });

  testWidgets(
      'business search is case insensitive and retains provider spelling',
      (tester) async {
    String? chosen;
    await render(
        tester,
        MiniPosVendorSelectField(
          label: 'Business type',
          value: 'Grocery',
          items: businesses,
          onChanged: (value) => chosen = value,
        ));
    await tester.tap(find.text('Grocery'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'RETAIL');
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsOneWidget);
    await tester.tap(find.widgetWithText(ListTile, 'Retail and Shopping'));
    await tester.pumpAndSettle();
    expect(chosen, 'Retail and Shopping');
  });

  testWidgets('locked selector cannot open or change its value',
      (tester) async {
    var changed = false;
    await render(
        tester,
        MiniPosVendorSelectField(
          label: 'Account type',
          value: 'BUSINESS',
          enabled: false,
          items: const ['BUSINESS', 'INDIVIDUAL'],
          onChanged: (_) => changed = true,
        ));
    await tester.tap(find.text('Business'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
    expect(changed, isFalse);
  });

  testWidgets('closing sheet keeps the original selection', (tester) async {
    var changed = false;
    await render(
        tester,
        MiniPosVendorSelectField(
          label: 'Business type',
          value: 'Grocery',
          items: businesses,
          onChanged: (_) => changed = true,
        ));
    await tester.tap(find.text('Grocery'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Grocery'), findsOneWidget);
    expect(changed, isFalse);
  });

  testWidgets('missing selection participates in form validation',
      (tester) async {
    await render(
        tester,
        MiniPosVendorSelectField(
          label: 'Business type',
          value: null,
          items: businesses,
          onChanged: (_) {},
        ));
    final form = tester.state<FormState>(find.byType(Form));
    expect(form.validate(), isFalse);
    await tester.pump();
    expect(find.text('Select business type'), findsOneWidget);
  });

  testWidgets('external vendor reload refreshes the selected value',
      (tester) async {
    String? value = 'BUSINESS';
    late StateSetter update;
    await render(tester, StatefulBuilder(builder: (context, setState) {
      update = setState;
      return MiniPosVendorSelectField(
        label: 'Account type',
        value: value,
        items: const ['BUSINESS', 'INDIVIDUAL'],
        onChanged: (_) {},
      );
    }));
    update(() => value = 'INDIVIDUAL');
    await tester.pumpAndSettle();
    expect(find.text('Individual'), findsOneWidget);
    expect(find.text('Business'), findsNothing);
  });

  for (final size in [
    const Size(320, 568),
    const Size(393, 852),
    const Size(800, 360)
  ]) {
    for (final scale in [1.0, 1.3, 2.0]) {
      for (final keyboard in [0.0, 180.0]) {
        testWidgets(
            'long business option ${size.width}x${size.height} text=$scale keyboard=$keyboard',
            (tester) async {
          String? chosen;
          final longOption = businesses.last;
          await render(
              tester,
              MiniPosVendorSelectField(
                label: 'Business type',
                value: longOption,
                items: businesses,
                onChanged: (value) => chosen = value,
              ),
              size: size,
              scale: scale,
              keyboard: keyboard);
          expect(tester.takeException(), isNull);
          await tester.tap(find.text(longOption));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final search = find.byType(TextField);
          await tester.ensureVisible(search);
          await tester.pumpAndSettle();
          await tester.enterText(search, 'professional');
          await tester.pumpAndSettle();
          final item = find.widgetWithText(ListTile, longOption);
          await tester.ensureVisible(item);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          // A wrapped accessibility label can be taller than the keyboard-
          // reduced viewport. Tap its visible portion, as a user would.
          final visible = tester
              .getRect(item)
              .intersect(tester.getRect(find.byType(CustomScrollView)));
          expect(visible.height, greaterThan(0));
          await tester.tapAt(visible.center);
          await tester.pumpAndSettle();
          expect(chosen, longOption);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
