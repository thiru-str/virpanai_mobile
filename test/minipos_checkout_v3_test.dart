import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waioz/ui/minipos/minipos_checkout_page.dart';
import 'package:waioz/ui/minipos/minipos_widgets.dart';

const _imei = '123456789012345';

Map<String, dynamic> _offer(
  String profile,
  String type,
  int? months,
) =>
    {
      'offer_id': '$profile:${months ?? 'card'}',
      'card_profile': profile,
      'plan_type': type,
      'tenure_months': months,
      'provider_plan_label': months == null ? null : '$months month estimate',
      'annual_interest_bps': months == null ? null : 1700,
      'card_amount_paise': 4299900,
      'monthly_emi_paise': months == null ? null : 1433300,
      'cashback_paise': profile == 'personal' ? 50000 : 0,
      'dealer_cashback_paise': 0,
      'quoted_dealer_payout_paise': 3977500,
      'final_dealer_payout_paise': 3992200,
      'leftover_paise': 29400,
      'dealer_surplus_share_paise': 14700,
      'total_gpf_paise': 257700,
      'gowelmart_margin_paise': 38300,
      'gst_payable_paise': 5800,
      'net_profit_paise': 32500,
      'dealer_profit_paise': 197300,
      'dealer_profit_margin_bps': 525,
      'selectable': true,
    };

Map<String, dynamic> _quote() => {
      'quote_token': 'quote-token',
      'product': {
        'product_title': 'Test phone with a responsive long product name',
        'variant_title': '128 GB',
        'mop_paise': 4999900,
      },
      'd_quote_paise': 3992200,
      'dealer_payout_paise': 3992200,
      'dealer_cashback_paise': 0,
      'maximum_dealer_cashback_paise': 3992199,
      'dealer_profit_paise': 197300,
      'profiles': {
        'corporate': {
          'offers': [
            _offer('corporate', 'CARD', null),
            _offer('corporate', 'NO_COST', 3),
            _offer('corporate', 'LOW_COST', 18),
            _offer('corporate', 'LOW_COST', 24),
          ],
        },
        'personal': {
          'offers': [
            _offer('personal', 'CARD', null),
            _offer('personal', 'NO_COST', 12),
            _offer('personal', 'LOW_COST', 18),
            _offer('personal', 'BANK_EMI', 18),
            _offer('personal', 'NO_COST', 24),
          ],
        },
      },
    };

Map<String, dynamic> _bankOffer(
  String bankId,
  String bankName,
  int months,
  int annualInterestBps,
) =>
    {
      ..._offer('corporate', months <= 6 ? 'NO_COST' : 'LOW_COST', months),
      'offer_id': 'corporate:$bankId:$months',
      'provider_bank_id': bankId,
      'bank_code': bankId.toUpperCase(),
      'provider_bank_name': bankName,
      'provider_plan_label': '$bankName - EMI',
      'annual_interest_bps': annualInterestBps,
    };

Future<void> _reveal(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 20 && finder.evaluate().isEmpty; i++) {
    await tester.drag(find.byKey(const ValueKey('minipos-checkout-list')),
        const Offset(0, -180));
    await tester.pump();
  }
  expect(finder, findsWidgets);
  await tester.ensureVisible(finder.first);
  await tester.pumpAndSettle();
}

Future<void> _revealUp(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 20 && finder.evaluate().isEmpty; i++) {
    await tester.drag(find.byKey(const ValueKey('minipos-checkout-list')),
        const Offset(0, 180));
    await tester.pump();
  }
  expect(finder, findsWidgets);
  await tester.ensureVisible(finder.first);
  await tester.pumpAndSettle();
}

Future<void> _fillCustomer(WidgetTester tester) async {
  await _revealUp(tester, find.byKey(const ValueKey('customer-name')));
  await tester.enterText(
      find.byKey(const ValueKey('customer-name')), 'Test Customer');
  await _reveal(tester, find.byKey(const ValueKey('customer-phone')));
  await tester.enterText(
      find.byKey(const ValueKey('customer-phone')), '9876543210');
}

Future<void> _verifyProfitPin(WidgetTester tester) async {
  expect(find.text('Enter PIN'), findsWidgets);
  expect(find.text('Enter your 4-digit PIN to view profit details.'),
      findsOneWidget);
  await tester.enterText(
      find.byKey(const ValueKey('profit-pin-input')), '1234');
  await tester.tap(find.byKey(const ValueKey('profit-pin-submit')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
      'uses server profiles, freezes intent and safely retries hosted checkout',
      (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final posts = <String>[];
    final launches = <String>[];
    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const TextScaler.linear(1.35)),
        child: child!,
      ),
      home: MiniPosCheckoutPage(
        total: 1,
        items: const [
          {'imei': _imei, 'unit_price': 1},
        ],
        checkoutToken: 'checkout_token_123456789012345',
        requestGet: (_) async => {'paid': false, 'payment_status': 'pending'},
        requestPost: (path, body) async {
          posts.add(path);
          if (path == 'minipos/emi/quotes/start') {
            expect(body['imei'], _imei);
            expect(body, isNot(contains('unit_price')));
            return _quote();
          }
          if (path == 'minipos/owner-pin/verify') {
            expect(body, {'pin': '1234'});
            return {'verified': true};
          }
          if (path == 'minipos/emi/quotes/select') {
            expect(body['card_profile'], 'corporate');
            expect(body['offer_id'], 'corporate:18');
            return {
              'quote_token': 'frozen-token',
              'frozen': true,
              'selected_offer': _offer('corporate', 'LOW_COST', 18),
              'dealer_action_required': false,
            };
          }
          if (path == 'minipos/checkout') {
            expect(body['quote_token'], 'frozen-token');
            expect(body['offer_id'], 'corporate:18');
            expect(body['card_profile'], 'corporate');
            expect(body['name'], 'Test Customer');
            expect(body['phone'], '9876543210');
            expect(body, isNot(contains('items')));
            expect(body, isNot(contains('expected_total')));
            for (final removed in [
              'email',
              'address_line_1',
              'address_line_2',
              'city',
              'state',
              'pincode',
              'customer',
            ]) {
              expect(body, isNot(contains(removed)));
            }
            return {
              'order': {'id': 'mp-order-1'},
              'payment': {
                'cashfree_order_id': 'cf-order-1',
                'payment_session_id': 'session-1',
                'environment': 'sandbox',
              },
            };
          }
          if (path.endsWith('/cancel')) {
            return {'paid': false, 'payment_status': 'cancelled'};
          }
          fail('Unexpected POST $path');
        },
        cashfreeLauncher: (order, session, environment) async {
          launches.add('$order/$session/$environment');
        },
      ),
    ));

    await tester.pumpAndSettle();
    expect(find.text('Review payment'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.text('Review payment')))
          .appBarTheme
          .titleTextStyle
          ?.fontSize,
      17,
    );
    expect(find.byKey(const ValueKey('customer-name')), findsNothing);
    expect(find.text('Email (optional)'), findsNothing);
    expect(find.text('Address'), findsNothing);
    expect(find.text('City'), findsNothing);
    expect(find.text('State'), findsNothing);
    expect(find.text('Pincode'), findsNothing);
    expect(posts, contains('minipos/emi/quotes/start'));
    expect(find.byKey(const ValueKey('card-profile-selector')), findsNothing);
    await _reveal(tester, find.byKey(const ValueKey('payment-mode-selector')));
    expect(find.text('Card'), findsOneWidget);
    expect(find.text('Cost EMI'), findsOneWidget);
    expect(find.text('No Cost EMI'), findsOneWidget);
    expect(find.byKey(const ValueKey('offer-corporate:card')), findsOneWidget);
    expect(find.byKey(const ValueKey('offer-personal:card')), findsNothing);
    expect(find.byKey(const ValueKey('offer-corporate:18')), findsNothing);
    final marginVisibility =
        find.byKey(const ValueKey('dealer-margin-visibility'));
    expect(marginVisibility, findsOneWidget);
    await tester.tap(marginVisibility);
    await tester.pumpAndSettle();
    expect(find.text('Shopkeeper profit margin'), findsNothing);
    await _verifyProfitPin(tester);
    expect(find.text('Shopkeeper profit margin'), findsOneWidget);
    expect(find.text('₹1,973.00 (5.25%)'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('dealer-profit-highlight-corporate:card')),
      findsOneWidget,
    );
    await tester.tap(marginVisibility);
    await tester.pump();
    expect(find.text('Shopkeeper profit margin'), findsNothing);

    await tester.tap(find.text('Cost EMI'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('offer-corporate:3')), findsNothing);
    await _reveal(tester, find.text('18-month estimate'));
    expect(find.text('18-month estimate'), findsOneWidget);
    expect(find.text('18 month estimate'), findsNothing);
    expect(find.text('17.00% p.a.'), findsWidgets);
    expect(find.byKey(const ValueKey('interest-badge-corporate:18')),
        findsOneWidget);
    await _reveal(tester, find.text('24-month estimate'));
    expect(find.text('24-month estimate'), findsOneWidget);
    expect(find.textContaining('Card number'), findsNothing);
    expect(tester.takeException(), isNull);
    // The hidden Personal projection and unsupported rows are not mixed into
    // the conservative Corporate estimate shown to the shopkeeper.
    expect(find.byKey(const ValueKey('offer-personal:18')), findsNothing);
    expect(find.textContaining('estimate · Low Cost EMI'), findsNothing);
    expect(find.textContaining('estimate · No Cost EMI'), findsNothing);
    expect(find.textContaining('estimate · Bank EMI'), findsNothing);

    await _reveal(tester, find.byKey(const ValueKey('offer-corporate:18')));
    expect(find.text('Final payout'), findsNothing);
    expect(find.text('Convenience fee'), findsNothing);
    expect(find.text('Platform fee'), findsNothing);
    expect(find.text('Gowelmart margin'), findsNothing);
    expect(find.text('Shopkeeper profit margin'), findsNothing);

    await _reveal(
        tester, find.byKey(const ValueKey('offer-info-corporate:18')));
    await tester.tap(find.byKey(const ValueKey('offer-info-corporate:18')));
    await tester.pumpAndSettle();
    expect(
        find.byKey(const ValueKey('charge-breakdown-drawer')), findsOneWidget);
    expect(
      find.ancestor(
        of: find.byKey(const ValueKey('charge-breakdown-drawer')),
        matching: find.byType(MiniPosTheme),
      ),
      findsOneWidget,
    );
    expect(find.text('Base shopkeeper payout'), findsNothing);
    expect(find.text('Additional payout'), findsNothing);
    expect(find.text('Purchase cost'), findsOneWidget);
    expect(find.text('Final payout'), findsOneWidget);
    expect(find.text('Your profit'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('charge-breakdown-drawer')),
        matching: find.text('Cashback'),
      ),
      findsOneWidget,
    );
    final purchaseCostValue =
        find.byKey(const ValueKey('purchase-cost-value-corporate:18'));
    expect(purchaseCostValue, findsOneWidget);
    expect(tester.widget<Text>(purchaseCostValue).data, '••••');
    expect(find.text('₹37,949.00'), findsNothing);
    expect(find.text('₹39,922.00'), findsOneWidget);
    expect(find.text('••••'), findsNWidgets(2));
    expect(find.text('₹1,973.00 (5.25%)'), findsNothing);
    expect(
      find.byKey(
          const ValueKey('dealer-profit-highlight-breakdown-corporate:18')),
      findsOneWidget,
    );
    final breakdownProfitEye = find.byKey(
        const ValueKey('dealer-profit-visibility-breakdown-corporate:18'));
    expect(breakdownProfitEye, findsOneWidget);
    await tester.ensureVisible(breakdownProfitEye);
    await tester.pumpAndSettle();
    await tester.tap(breakdownProfitEye);
    await tester.pumpAndSettle();
    await _verifyProfitPin(tester);
    expect(tester.widget<Text>(purchaseCostValue).data, '₹37,949.00');
    expect(find.text('₹1,973.00 (5.25%)'), findsOneWidget);
    expect(find.text('••••'), findsNothing);
    expect(find.text('₹39,775.00'), findsNothing);
    expect(find.text('₹147.00'), findsNothing);
    expect(find.text('Convenience fee'), findsOneWidget);
    expect(find.text('Platform fee (GST inclusive)'), findsOneWidget);
    expect(find.text('GST included in platform fee'), findsNothing);
    expect(find.text('Gowelmart margin'), findsNothing);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    await _reveal(
        tester, find.byKey(const ValueKey('dealer-margin-visibility')));
    expect(find.byKey(const ValueKey('margin-eye-corporate:18')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('dealer-margin-visibility')));
    await tester.pumpAndSettle();
    await _verifyProfitPin(tester);
    expect(find.text('Shopkeeper profit margin'), findsNWidgets(2));
    expect(find.text('₹1,973.00 (5.25%)'), findsNWidgets(2));
    await tester.tap(find.byKey(const ValueKey('dealer-margin-visibility')));
    await tester.pump();
    expect(find.text('Shopkeeper profit margin'), findsNothing);

    await _revealUp(tester, find.text('No Cost EMI'));
    await tester.tap(find.text('No Cost EMI'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('offer-corporate:3')), findsOneWidget);
    expect(find.byKey(const ValueKey('offer-corporate:18')), findsNothing);
    expect(
      find.text(
          'The customer understands that No Cost EMI eligibility and the final plan will be confirmed in the gateway.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Cost EMI'));
    await tester.pumpAndSettle();

    await _reveal(
        tester, find.byKey(const ValueKey('use-estimate-corporate:18')));
    await tester.tap(find.byKey(const ValueKey('use-estimate-corporate:18')));
    await _reveal(tester, find.byKey(const ValueKey('plan-terms')));
    await tester.tap(find.byKey(const ValueKey('plan-terms')));
    await _reveal(tester, find.byKey(const ValueKey('confirm-plan')));
    expect(find.text('Continue'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('confirm-plan')));
    await tester.pumpAndSettle();

    expect(find.text('Customer info'), findsOneWidget);
    expect(find.byKey(const ValueKey('dealer-cashback-action')), findsNothing);
    expect(
        find.byKey(const ValueKey('dealer-margin-visibility')), findsNothing);
    expect(find.byKey(const ValueKey('financial-review')), findsNothing);
    expect(find.byKey(const ValueKey('customer-name')), findsOneWidget);
    expect(find.text('Final payout'), findsNothing);
    expect(find.text('Convenience fee'), findsNothing);
    expect(find.text('Platform fee'), findsNothing);
    expect(find.text('Gowelmart margin'), findsNothing);
    expect(find.text('Shopkeeper profit margin'), findsNothing);
    expect(tester.takeException(), isNull);

    expect(launches, isEmpty);
    expect(posts.where((path) => path == 'minipos/checkout'), isEmpty);

    await _fillCustomer(tester);
    await _reveal(tester, find.byKey(const ValueKey('pay-now')));
    expect(find.text('Continue to Payment'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('pay-now')));
    await tester.pumpAndSettle();

    expect(launches, ['cf-order-1/session-1/sandbox']);
    expect(posts.where((path) => path == 'minipos/checkout'), hasLength(1));

    await _reveal(tester, find.byKey(const ValueKey('pay-now')));
    await tester.tap(find.byKey(const ValueKey('pay-now')));
    await tester.pumpAndSettle();
    expect(launches, hasLength(2));
    expect(posts.where((path) => path == 'minipos/checkout'), hasLength(1));

    await _reveal(tester, find.byKey(const ValueKey('cancel-payment-attempt')));
    await tester.tap(find.byKey(const ValueKey('cancel-payment-attempt')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel attempt'));
    await tester.pumpAndSettle();
    expect(posts.where((path) => path.endsWith('/cancel')), hasLength(1));
    expect(tester.takeException(), isNull);
  });

  for (final required in [1, 2]) {
    testWidgets(
        '$required owner confirmation(s) complete before plan selection',
        (tester) async {
      var completed = 0;
      final confirmations = <Map<String, dynamic>>[];
      await tester.pumpWidget(MaterialApp(
        home: MiniPosCheckoutPage(
          total: 1,
          items: const [
            {'imei': _imei, 'unit_price': 1},
          ],
          checkoutToken: 'checkout_token_123456789012345',
          requestPost: (path, body) async {
            if (path == 'minipos/emi/quotes/start') {
              return {
                ..._quote(),
                'dealer_action_required': true,
                'confirmations_required': required,
                'confirmations_completed': 0,
              };
            }
            if (path == 'minipos/emi/quotes/review') {
              return {
                'quote_token': 'review-$completed',
                'dealer_review': {
                  'next_confirmation': completed == 0 ? 'margin' : 'loss',
                  'dealer_cost_paise': 4000000,
                  'proposed_payout_paise': 3992200,
                  'proposed_margin_paise': -7800,
                  'below_cost': completed > 0,
                  'reason_required': completed > 0,
                  'default_reason_tag': 'ageing_stock',
                  'reason_tags': const [
                    {'value': 'ageing_stock', 'label': 'Ageing stock'},
                    {'value': 'clearance', 'label': 'Clearance'},
                  ],
                },
              };
            }
            if (path == 'minipos/emi/quotes/confirm') {
              confirmations.add(Map<String, dynamic>.from(body));
              completed++;
              return {
                ..._quote(),
                'quote_token': 'confirmed-$completed',
                'dealer_action_required': completed < required,
                'confirmations_required': required,
                'confirmations_completed': completed,
              };
            }
            fail('Unexpected POST $path');
          },
        ),
      ));
      await tester.pumpAndSettle();

      for (var round = 0; round < required; round++) {
        await _reveal(tester, find.byKey(const ValueKey('inline-owner-pin')));
        await tester.enterText(
            find.byKey(const ValueKey('inline-owner-pin')), '1234');
        await _reveal(
            tester, find.byKey(const ValueKey('review-owner-decision')));
        await tester.tap(find.byKey(const ValueKey('review-owner-decision')));
        await tester.pumpAndSettle();
        if (round == 1) {
          expect(find.byKey(const ValueKey('loss-reason')), findsOneWidget);
        }
        await _reveal(
            tester, find.byKey(const ValueKey('confirm-owner-decision')));
        await tester.tap(find.byKey(const ValueKey('confirm-owner-decision')));
        await tester.pumpAndSettle();
      }

      expect(confirmations, hasLength(required));
      expect(confirmations.first['confirmation'], 'margin');
      if (required == 2) {
        expect(confirmations.last['confirmation'], 'loss');
        expect(confirmations.last['reason_tag'], 'ageing_stock');
      }
      expect(find.byKey(const ValueKey('owner-approval')), findsNothing);
      await _revealUp(tester,
          find.byKey(const ValueKey('estimate-selected-corporate:card')));
      expect(find.text('Selected plan'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Card review continues through customer info to gateway',
      (tester) async {
    final posts = <String>[];
    final launches = <String>[];
    await tester.pumpWidget(MaterialApp(
      home: MiniPosCheckoutPage(
        total: 1,
        items: const [
          {'imei': _imei, 'unit_price': 1},
        ],
        checkoutToken: 'checkout_token_123456789012345',
        requestPost: (path, body) async {
          posts.add(path);
          if (path == 'minipos/emi/quotes/start') return _quote();
          if (path == 'minipos/emi/quotes/select') {
            expect(body['offer_id'], 'corporate:card');
            expect(body['card_profile'], 'corporate');
            return {
              'quote_token': 'card-frozen-token',
              'frozen': true,
              'selected_offer': _offer('corporate', 'CARD', null),
              'dealer_action_required': false,
            };
          }
          if (path == 'minipos/checkout') {
            expect(body['offer_id'], 'corporate:card');
            expect(body['card_profile'], 'corporate');
            expect(body['name'], 'Test Customer');
            expect(body['phone'], '9876543210');
            return {
              'order': {'id': 'mp-card-order'},
              'payment': {
                'cashfree_order_id': 'cf-card-order',
                'payment_session_id': 'card-session',
                'environment': 'sandbox',
              },
            };
          }
          fail('Unexpected POST $path');
        },
        cashfreeLauncher: (order, session, environment) async {
          launches.add('$order/$session/$environment');
        },
      ),
    ));

    await tester.pumpAndSettle();
    expect(find.text('Review the card payment amount before continuing.'),
        findsOneWidget);
    await _reveal(
        tester, find.byKey(const ValueKey('estimate-selected-corporate:card')));
    expect(find.text('Selected plan'), findsOneWidget);
    expect(find.text('Select Plan'), findsNothing);
    await _reveal(tester, find.byKey(const ValueKey('plan-terms')));
    expect(
      find.text(
          'The customer confirms the card payment amount and will complete payment in the gateway.'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('plan-terms')));
    await _reveal(tester, find.byKey(const ValueKey('confirm-plan')));
    await tester.tap(find.byKey(const ValueKey('confirm-plan')));
    await tester.pumpAndSettle();

    expect(find.text('Customer info'), findsOneWidget);
    expect(launches, isEmpty);
    await _fillCustomer(tester);
    await _reveal(tester, find.byKey(const ValueKey('pay-now')));
    await tester.tap(find.byKey(const ValueKey('pay-now')));
    await tester.pumpAndSettle();

    expect(launches, ['cf-card-order/card-session/sandbox']);
    expect(posts.where((path) => path == 'minipos/checkout'), hasLength(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows a clear production EMI capability message',
      (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: MiniPosCheckoutPage(
            total: 1,
            items: const [
              {'imei': _imei, 'unit_price': 1},
            ],
            checkoutToken: 'checkout_token_123456789012345',
            requestPost: (path, body) async {
              expect(path, 'minipos/emi/quotes/start');
              final quote = _quote();
              quote['hosted_emi_binding_available'] = false;
              for (final profile in (quote['profiles'] as Map).values) {
                for (final offer in (profile as Map)['offers'] as List) {
                  if (offer['plan_type'] != 'CARD') offer['selectable'] = false;
                }
              }
              return quote;
            }),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('hosted-emi-unavailable')), findsNothing);
    await tester.tap(find.text('Cost EMI'));
    await tester.pumpAndSettle();
    await _reveal(
        tester, find.byKey(const ValueKey('interest-bearing-emi-empty')));
    expect(
      find.text(
          'No interest-bearing EMI estimate is available right now. Try Card or No Cost EMI.'),
      findsOneWidget,
    );
    final discountAction = find.byKey(const ValueKey('dealer-cashback-action'));
    expect(discountAction, findsOneWidget);
    final disabledDiscountButton = tester.widget<IconButton>(discountAction);
    expect(disabledDiscountButton.onPressed, isNull);
    expect((disabledDiscountButton.icon as Icon).icon,
        Icons.card_giftcard_rounded);
    expect(
      disabledDiscountButton.style?.foregroundColor
          ?.resolve({WidgetState.disabled}),
      Colors.white.withValues(alpha: .42),
    );
    final marginAction = find.byKey(const ValueKey('dealer-margin-visibility'));
    expect(tester.widget<IconButton>(marginAction).onPressed, isNull);
    expect(find.byKey(const ValueKey('offer-corporate:card')), findsNothing);
    expect(find.byKey(const ValueKey('offer-corporate:3')), findsNothing);
    await _revealUp(tester, find.text('Card'));
    await tester.tap(find.text('Card'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('hosted-emi-unavailable')), findsNothing);
    expect(find.byKey(const ValueKey('offer-corporate:card')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Card and EMI review fits a narrow phone without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const TextScaler.linear(2)),
        child: child!,
      ),
      home: MiniPosCheckoutPage(
        total: 1,
        items: const [
          {'imei': _imei, 'unit_price': 1},
        ],
        checkoutToken: 'checkout_token_123456789012345',
        requestPost: (path, body) async {
          expect(path, 'minipos/emi/quotes/start');
          return _quote();
        },
      ),
    ));

    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('payout-override')), findsNothing);
    await _reveal(tester, find.byKey(const ValueKey('payment-mode-selector')));
    expect(find.text('Card'), findsOneWidget);
    expect(find.text('Cost EMI'), findsOneWidget);
    expect(find.text('No Cost EMI'), findsOneWidget);
    final discountAction = find.byKey(const ValueKey('dealer-cashback-action'));
    final marginAction = find.byKey(const ValueKey('dealer-margin-visibility'));
    expect(tester.getCenter(marginAction).dx,
        lessThan(tester.getCenter(discountAction).dx));
    expect((tester.widget<IconButton>(discountAction).icon as Icon).icon,
        Icons.card_giftcard_rounded);
    expect(tester.widget<IconButton>(discountAction).onPressed, isNotNull);
    await tester.tap(find.text('Cost EMI'));
    await tester.pumpAndSettle();
    expect(tester.widget<IconButton>(discountAction).onPressed, isNotNull);
    await _reveal(tester, find.byKey(const ValueKey('offer-corporate:18')));
    await _revealUp(tester, find.text('No Cost EMI'));
    await tester.tap(find.text('No Cost EMI'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('offer-corporate:3')), findsOneWidget);
    expect(tester.widget<IconButton>(discountAction).onPressed, isNotNull);
    expect(tester.widget<IconButton>(marginAction).onPressed, isNotNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'dealer cashback has no minimum and is shown separately from PDF cashback',
      (tester) async {
    final cashbackRequests = <int>[];
    await tester.pumpWidget(MaterialApp(
      home: MiniPosCheckoutPage(
        total: 1,
        items: const [
          {'imei': _imei, 'unit_price': 1},
        ],
        checkoutToken: 'checkout_token_123456789012345',
        requestPost: (path, body) async {
          expect(path, 'minipos/emi/quotes/start');
          final requested = body['dealer_cashback_paise'];
          if (requested is int) cashbackRequests.add(requested);
          final quote = _quote();
          final dealerCashback = requested is int ? requested : 0;
          quote['dealer_cashback_paise'] = dealerCashback;
          if (requested is int) {
            quote['quote_token'] = 'quote-$requested';
          }
          for (final profile in ['corporate', 'personal']) {
            for (final offer in ((quote['profiles'] as Map)[profile]
                as Map)['offers'] as List) {
              if (offer['plan_type'] == 'NO_COST') {
                offer['cashback_paise'] = 200000;
              }
              offer['dealer_cashback_paise'] = dealerCashback;
              offer['card_amount_paise'] =
                  (offer['card_amount_paise'] as int) - dealerCashback;
              offer['final_dealer_payout_paise'] =
                  (offer['final_dealer_payout_paise'] as int) - dealerCashback;
              offer['dealer_profit_paise'] =
                  (offer['dealer_profit_paise'] as int) - dealerCashback;
            }
          }
          return quote;
        },
      ),
    ));

    await tester.pumpAndSettle();
    final action = find.byKey(const ValueKey('dealer-cashback-action'));
    expect(action, findsOneWidget);
    expect(tester.widget<IconButton>(action).onPressed, isNotNull);
    await tester.tap(find.text('No Cost EMI'));
    await tester.pumpAndSettle();
    expect(tester.widget<IconButton>(action).onPressed, isNotNull);
    expect(
      tester.widget<IconButton>(action).tooltip,
      'Give dealer cashback',
    );

    await tester.tap(action);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('dealer-cashback-sheet')), findsOneWidget);
    expect(
      find.ancestor(
        of: find.byKey(const ValueKey('dealer-cashback-sheet')),
        matching: find.byType(MiniPosTheme),
      ),
      findsOneWidget,
    );
    expect(find.text('Dealer cashback'), findsOneWidget);
    expect(
      find.text('Enter the cashback amount you want to give the customer.'),
      findsOneWidget,
    );
    expect(find.text('Dealer cashback amount'), findsOneWidget);
    expect(find.textContaining('Minimum discount'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('apply-dealer-cashback')));
    await tester.pump();
    expect(find.text('Enter a valid amount.'), findsOneWidget);
    expect(cashbackRequests, isEmpty);

    await tester.enterText(
        find.byKey(const ValueKey('dealer-cashback-input')), '39922.00');
    await tester.tap(find.byKey(const ValueKey('apply-dealer-cashback')));
    await tester.pump();
    expect(find.textContaining('Maximum allowed is'), findsOneWidget);
    expect(cashbackRequests, isEmpty);

    // There is no minimum dealer cashback.
    await tester.enterText(
        find.byKey(const ValueKey('dealer-cashback-input')), '1');
    await tester.tap(find.byKey(const ValueKey('apply-dealer-cashback')));
    await tester.pumpAndSettle();
    expect(find.text('Confirm dealer cashback'), findsOneWidget);
    expect(
      find.text(
          '₹ 1 will be deducted from your final payout, Do you want to recalculate the plans?'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('confirm-dealer-cashback')));
    await tester.pumpAndSettle();
    expect(cashbackRequests, [100]);
    expect(find.text('Dealer cashback'), findsWidgets);
    expect(find.text('₹1.00'), findsWidgets);

    // Zero removes the custom cashback.
    await tester.tap(action);
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const ValueKey('dealer-cashback-input')), '0');
    await tester.tap(find.byKey(const ValueKey('apply-dealer-cashback')));
    await tester.pumpAndSettle();
    expect(find.text('Remove dealer cashback?'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('confirm-dealer-cashback')));
    await tester.pumpAndSettle();
    expect(cashbackRequests, [100, 0]);

    // The previous confirmation closes the sheet, so open it again.
    await tester.tap(action);
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const ValueKey('dealer-cashback-input')), '500');
    await tester.tap(find.byKey(const ValueKey('apply-dealer-cashback')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirm-dealer-cashback')));
    await tester.pumpAndSettle();
    expect(cashbackRequests, [100, 0, 50000]);
    expect(find.text('Cashback'), findsWidgets);
    expect(find.text('Dealer cashback'), findsWidgets);
    expect(find.text('₹2,000.00'), findsWidgets);
    expect(find.text('₹500.00'), findsWidgets);

    await _reveal(tester, find.byKey(const ValueKey('offer-info-corporate:3')));
    await tester.tap(find.byKey(const ValueKey('offer-info-corporate:3')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('charge-breakdown-drawer')),
        matching: find.text('Dealer cashback'),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'dealer cashback requires explicit acceptance when payout becomes a loss',
      (tester) async {
    final cashbackRequests = <int>[];
    await tester.pumpWidget(MaterialApp(
      home: MiniPosCheckoutPage(
        total: 1,
        items: const [
          {'imei': _imei, 'unit_price': 1},
        ],
        checkoutToken: 'checkout_token_123456789012345',
        requestPost: (path, body) async {
          expect(path, 'minipos/emi/quotes/start');
          final requested = body['dealer_cashback_paise'];
          if (requested is int) cashbackRequests.add(requested);
          return _quote();
        },
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('dealer-cashback-action')));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const ValueKey('dealer-cashback-input')), '2000');
    await tester.tap(find.byKey(const ValueKey('apply-dealer-cashback')));
    await tester.pumpAndSettle();

    expect(
      find.text(
          '₹ 2,000 will be deducted from your final payout, Do you want to recalculate the plans?'),
      findsOneWidget,
    );
    const confirmationDescription =
        '₹ 2,000 will be deducted from your final payout, Do you want to recalculate the plans?';
    const lossAcceptance =
        'I accept the loss and wish to proceed with the cashback';
    expect(find.text(lossAcceptance), findsOneWidget);
    final descriptionText =
        tester.widget<Text>(find.text(confirmationDescription));
    final acceptanceText = tester.widget<Text>(find.text(lossAcceptance));
    expect(acceptanceText.style?.fontSize, descriptionText.style?.fontSize);
    final confirm = find.byKey(const ValueKey('confirm-dealer-cashback'));
    expect(tester.widget<FilledButton>(confirm).onPressed, isNull);
    expect(cashbackRequests, isEmpty);

    await tester
        .tap(find.byKey(const ValueKey('dealer-cashback-loss-acceptance')));
    await tester.pump();
    expect(tester.widget<FilledButton>(confirm).onPressed, isNotNull);
    await tester.tap(confirm);
    await tester.pumpAndSettle();
    expect(cashbackRequests, [200000]);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'groups every provider bank into accordions with centralized margins',
      (tester) async {
    final quote = _quote();
    (quote['profiles']['corporate'] as Map)['offers'] = [
      _offer('corporate', 'CARD', null),
      _bankOffer('axis', 'Axis Credit Card - EMI', 9, 1400),
      _bankOffer('bob', 'BOB Credit Card - EMI', 12, 1500),
      _bankOffer('axis', 'Axis Credit Card - EMI', 3, 1400),
      _bankOffer('bob', 'BOB Credit Card - EMI', 6, 1500),
    ];

    await tester.pumpWidget(MaterialApp(
      home: MiniPosCheckoutPage(
        total: 1,
        items: const [
          {'imei': _imei, 'unit_price': 1},
        ],
        checkoutToken: 'checkout_token_123456789012345',
        requestPost: (path, body) async {
          if (path == 'minipos/emi/quotes/start') return quote;
          if (path == 'minipos/owner-pin/verify') {
            expect(body, {'pin': '1234'});
            return {'verified': true};
          }
          fail('Unexpected POST $path');
        },
      ),
    ));
    await tester.pumpAndSettle();

    expect(
        find.byKey(const ValueKey('dealer-margin-visibility')), findsOneWidget);
    await tester.tap(find.text('Cost EMI'));
    await tester.pumpAndSettle();

    expect(
        find.byKey(const ValueKey('dealer-margin-visibility')), findsOneWidget);
    expect(find.text('Axis Credit Card - EMI'), findsOneWidget);
    expect(find.text('BOB Credit Card - EMI'), findsOneWidget);
    expect(find.text('1 plan'), findsNWidgets(2));
    expect(find.text('14.00% p.a.'), findsOneWidget);
    expect(find.byKey(const ValueKey('interest-badge-corporate:axis:9')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('offer-info-corporate:axis:9')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('margin-eye-corporate:axis:9')),
        findsNothing);

    await _reveal(tester, find.text('BOB Credit Card - EMI'));
    await tester.tap(find.text('BOB Credit Card - EMI'));
    await tester.pumpAndSettle();
    await _reveal(tester, find.byKey(const ValueKey('offer-corporate:bob:12')));
    expect(find.text('15.00% p.a.'), findsOneWidget);
    expect(find.byKey(const ValueKey('interest-badge-corporate:bob:12')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('offer-info-corporate:bob:12')),
        findsOneWidget);
    expect(find.text('Select Plan'), findsNWidgets(2));
    final axisPlanCard = tester.widget<Card>(
      find.byKey(const ValueKey('offer-corporate:axis:9')),
    );
    final bobPlanCard = tester.widget<Card>(
      find.byKey(const ValueKey('offer-corporate:bob:12')),
    );
    expect(axisPlanCard.color, Colors.transparent);
    expect(bobPlanCard.color, Colors.transparent);
    expect((axisPlanCard.shape! as RoundedRectangleBorder).side,
        isNot(BorderSide.none));
    expect((bobPlanCard.shape! as RoundedRectangleBorder).side,
        isNot(BorderSide.none));
    expect((axisPlanCard.shape! as RoundedRectangleBorder).side.color,
        isNot((bobPlanCard.shape! as RoundedRectangleBorder).side.color));

    await _revealUp(
        tester, find.byKey(const ValueKey('use-estimate-corporate:axis:9')));
    await tester
        .tap(find.byKey(const ValueKey('use-estimate-corporate:axis:9')));
    await tester.pump();
    expect(find.byKey(const ValueKey('estimate-selected-corporate:axis:9')),
        findsOneWidget);

    await _revealUp(tester, find.text('No Cost EMI'));
    await tester.tap(find.text('No Cost EMI'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('offer-corporate:axis:9')), findsNothing);
    expect(
        find.byKey(const ValueKey('offer-corporate:axis:3')), findsOneWidget);
    expect(find.byKey(const ValueKey('estimate-selected-corporate:axis:3')),
        findsNothing);
    expect(find.text('Axis Credit Card - EMI'), findsOneWidget);
    expect(find.text('BOB Credit Card - EMI'), findsOneWidget);

    await _reveal(
        tester, find.byKey(const ValueKey('dealer-margin-visibility')));
    await tester.tap(find.byKey(const ValueKey('dealer-margin-visibility')));
    await tester.pumpAndSettle();
    await _verifyProfitPin(tester);
    expect(find.text('Shopkeeper profit margin'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
}
