import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';
import 'package:waioz/api/minipos_service.dart';
import 'package:waioz/ui/minipos/minipos_order_detail_page.dart';
import 'package:waioz/ui/minipos/minipos_temp_cart.dart';
import 'package:waioz/ui/minipos/minipos_widgets.dart';
import 'package:waioz/utility/app_colors.dart';

enum MiniPosCardProfile { corporate, personal }

enum MiniPosPaymentMode { card, emi, noCostEmi }

enum MiniPosCheckoutStage { review, customerInfo }

typedef MiniPosCashfreeLauncher = Future<void> Function(
  String orderId,
  String paymentSessionId,
  String environment,
);

/// Server-authoritative quote review followed by Cashfree hosted checkout.
/// Card details and financial calculations never happen in this widget.
class MiniPosCheckoutPage extends StatefulWidget {
  final int total;
  final List<Map<String, dynamic>> items;
  final String checkoutToken;
  final Future<Map<String, dynamic>> Function(String, Map<String, dynamic>)?
      requestPost;
  final Future<Map<String, dynamic>> Function(String)? requestGet;
  final MiniPosCashfreeLauncher? cashfreeLauncher;

  const MiniPosCheckoutPage({
    super.key,
    required this.total,
    required this.items,
    required this.checkoutToken,
    this.requestPost,
    this.requestGet,
    this.cashfreeLauncher,
  });

  @override
  State<MiniPosCheckoutPage> createState() => _MiniPosCheckoutPageState();
}

class _MiniPosCheckoutPageState extends State<MiniPosCheckoutPage>
    with WidgetsBindingObserver {
  final _form = GlobalKey<FormState>();
  final _api = MiniPosService.instance;
  final _cashfree = CFPaymentGatewayService();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _ownerPin = TextEditingController();

  MiniPosCardProfile _profile = MiniPosCardProfile.corporate;
  MiniPosPaymentMode _paymentMode = MiniPosPaymentMode.card;
  MiniPosCheckoutStage _stage = MiniPosCheckoutStage.review;
  bool _loadingQuote = false;
  bool _selecting = false;
  bool _reviewing = false;
  bool _confirming = false;
  bool _startingPayment = false;
  bool _verifyingPayment = false;
  bool _cancellingPayment = false;
  bool _terms = false;
  bool _showDealerMargins = false;
  String? _quoteToken;
  String? _selectedOfferId;
  Map<String, dynamic>? _product;
  Map<String, dynamic>? _selectedOffer;
  Map<String, dynamic>? _dealerReview;
  String? _reasonTag;
  List<Map<String, dynamic>> _offers = const [];
  bool _hostedEmiBindingAvailable = true;
  bool _dealerActionRequired = false;
  int _confirmationsRequired = 0;
  int _confirmationsCompleted = 0;
  int _dealerCashbackPaise = 0;
  int? _maximumDealerCashbackPaise;
  int? _dealerProfitPaise;
  String? _appOrderId;
  String? _cashfreeOrderId;
  String? _paymentSessionId;
  String _paymentEnvironment = 'sandbox';

  String get _profileValue => _profile.name;
  String get _imei => '${widget.items.single['imei'] ?? ''}'.trim();
  bool get _hasPendingPayment =>
      _appOrderId != null && _paymentSessionId != null;
  List<Map<String, dynamic>> get _visibleOffers => _offers.where((row) {
        final type = _planType(row);
        final isConservativeProfile =
            '${row['card_profile']}'.toLowerCase() == 'corporate';
        if (!isConservativeProfile) return false;
        return switch (_paymentMode) {
          MiniPosPaymentMode.card => type == 'CARD',
          MiniPosPaymentMode.emi => type != 'CARD' && type != 'NO_COST',
          MiniPosPaymentMode.noCostEmi => type == 'NO_COST',
        };
      }).toList(growable: false);

  bool get _isEmiMode => _paymentMode != MiniPosPaymentMode.card;

  bool get _canToggleDealerMargins =>
      _stage == MiniPosCheckoutStage.review &&
      _quoteToken?.isNotEmpty == true &&
      !_loadingQuote &&
      _visibleOffers.any((offer) => [
            'dealer_profit_paise',
            'dealer_profit_margin_percent',
            'dealer_profit_margin_bps',
            'dealer_margin_bps',
          ].any((key) => offer[key] != null));

  String get _selectedProfileValue {
    final selected = _offers.cast<Map<String, dynamic>?>().firstWhere(
          (row) => row?['offer_id'] == _selectedOfferId,
          orElse: () => null,
        );
    final value = '${selected?['card_profile'] ?? _profileValue}'.toLowerCase();
    return value == 'personal' ? 'personal' : 'corporate';
  }

  bool get _canAdjustDealerCashback =>
      _stage == MiniPosCheckoutStage.review &&
      _quoteToken?.isNotEmpty == true &&
      (_maximumDealerCashbackPaise ?? 0) > 0 &&
      _visibleOffers.any((offer) => offer['selectable'] != false) &&
      _selectedOffer == null &&
      !_loadingQuote &&
      !_selecting &&
      !_hasPendingPayment;

  String get _dealerCashbackTooltip => _canAdjustDealerCashback
      ? 'Give dealer cashback'
      : 'Dealer cashback is not available right now';

  String? _singleCardOfferId(List<Map<String, dynamic>> offers) {
    final cards = offers
        .where((offer) =>
            '${offer['card_profile']}'.toLowerCase() == 'corporate' &&
            _planType(offer) == 'CARD')
        .toList(growable: false);
    return cards.length == 1 ? '${cards.single['offer_id']}' : null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cashfree.setCallback(_cashfreeSuccess, _cashfreeFailure);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_calculateOffers());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _name.dispose();
    _phone.dispose();
    _ownerPin.clear();
    _ownerPin.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _hasPendingPayment) {
      unawaited(_verifyPayment(silent: true));
      return;
    }
    if (state != AppLifecycleState.resumed) {
      _ownerPin.clear();
      if (mounted && (_dealerReview != null || _showDealerMargins)) {
        setState(() {
          _dealerReview = null;
          _showDealerMargins = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) =>
      (widget.requestPost ?? _api.post)(path, body);
  Future<Map<String, dynamic>> _get(String path) =>
      (widget.requestGet ?? _api.get)(path);
  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;
  String _message(Object error, String fallback) =>
      error is MiniPosException ? error.message : fallback;

  void _reportError(String message) {
    if (!mounted) return;
    miniPosMessage(context, message);
  }

  Future<bool> _verifyProfitPin() async {
    final controller = TextEditingController();
    String? validationMessage;
    bool verifying = false;
    final verified = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => MiniPosTheme(
        child: StatefulBuilder(
          builder: (dialogContext, setDialogState) => AlertDialog(
            title: const Text('Enter PIN'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter your 4-digit PIN to view profit details.',
                ),
                const SizedBox(height: 14),
                TextField(
                  key: const ValueKey('profit-pin-input'),
                  controller: controller,
                  autofocus: true,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  decoration: InputDecoration(
                    labelText: 'PIN',
                    counterText: '',
                    errorText: validationMessage,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => setDialogState(
                    () => validationMessage = null,
                  ),
                  onSubmitted: (_) {
                    if (!verifying) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: verifying
                    ? null
                    : () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                key: const ValueKey('profit-pin-submit'),
                onPressed: verifying
                    ? null
                    : () async {
                        final pin = controller.text.trim();
                        if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
                          setDialogState(() =>
                              validationMessage = 'Enter your 4-digit PIN.');
                          return;
                        }
                        setDialogState(() => verifying = true);
                        try {
                          final response = await _post(
                            'minipos/owner-pin/verify',
                            {'pin': pin},
                          );
                          if (response['verified'] != true) {
                            throw const MiniPosException(
                                'Unable to verify the PIN.');
                          }
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop(true);
                          }
                        } catch (error) {
                          if (dialogContext.mounted) {
                            setDialogState(() {
                              verifying = false;
                              validationMessage = _message(
                                error,
                                'Unable to verify the PIN.',
                              );
                            });
                          }
                        }
                      },
                child: Text(verifying ? 'Verifying…' : 'Verify'),
              ),
            ],
          ),
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 250));
    controller.clear();
    controller.dispose();
    return verified == true;
  }

  Future<void> _toggleDealerMargins() async {
    if (_showDealerMargins) {
      setState(() => _showDealerMargins = false);
      return;
    }
    if (!await _verifyProfitPin() || !mounted) return;
    setState(() => _showDealerMargins = true);
  }

  Future<void> _calculateOffers({int? dealerCashbackPaise}) async {
    if (_loadingQuote) return;
    if (widget.items.length != 1 || !RegExp(r'^\d{15}$').hasMatch(_imei)) {
      miniPosMessage(context,
          'Checkout supports one scanned device at a time. Keep one phone in the cart.');
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _loadingQuote = true);
    try {
      final data = await _post('minipos/emi/quotes/start', {
        'imei': _imei,
        'card_profile': _profileValue,
        if (dealerCashbackPaise != null)
          'dealer_cashback_paise': dealerCashbackPaise,
      });
      _applyQuote(data, replaceOffers: true);
      if (_quoteToken?.isNotEmpty != true || _offers.isEmpty) {
        throw const MiniPosException(
            'No payment option is available for this device.');
      }
    } catch (error) {
      _reportError(_message(
          error, 'Unable to calculate payment options. Please try again.'));
    } finally {
      if (mounted) setState(() => _loadingQuote = false);
    }
  }

  void _applyQuote(Map<String, dynamic> data, {bool replaceOffers = false}) {
    final parsed = _parseOffers(data);
    setState(() {
      _quoteToken = '${data['quote_token'] ?? _quoteToken ?? ''}';
      if (data['product'] is Map) {
        _product = Map<String, dynamic>.from(data['product'] as Map);
      }
      if (replaceOffers || parsed.isNotEmpty) _offers = parsed;
      if (_paymentMode == MiniPosPaymentMode.card) {
        _selectedOfferId = _singleCardOfferId(_offers);
      }
      _dealerCashbackPaise =
          int.tryParse('${data['dealer_cashback_paise'] ?? 0}') ?? 0;
      _maximumDealerCashbackPaise = int.tryParse(
            '${data['maximum_dealer_cashback_paise'] ?? ''}',
          ) ??
          _maximumDealerCashbackPaise;
      _dealerProfitPaise =
          int.tryParse('${data['dealer_profit_paise'] ?? ''}') ??
              _dealerProfitPaise;
      final approval = data['approval'] is Map ? data['approval'] as Map : null;
      _confirmationsRequired = int.tryParse(
              '${data['confirmations_required'] ?? approval?['confirmations_required'] ?? 0}') ??
          0;
      _confirmationsCompleted = int.tryParse(
              '${data['confirmations_completed'] ?? approval?['confirmations_completed'] ?? 0}') ??
          0;
      _dealerActionRequired = data['dealer_action_required'] == true ||
          _confirmationsCompleted < _confirmationsRequired;
      _hostedEmiBindingAvailable =
          data['hosted_emi_binding_available'] != false;
    });
  }

  List<Map<String, dynamic>> _parseOffers(Map<String, dynamic> data) {
    final rows = <Map<String, dynamic>>[];
    final profiles = data['profiles'];
    if (profiles is Map) {
      for (final profile in const ['corporate', 'personal']) {
        final value = profiles[profile];
        final offers = value is Map ? value['offers'] : value;
        if (offers is List) {
          for (final raw in offers.whereType<Map>()) {
            final offer = Map<String, dynamic>.from(raw);
            offer['card_profile'] ??= profile;
            if (_validOffer(offer)) rows.add(offer);
          }
        }
      }
    }
    for (final key in const ['offers', 'customer_offers']) {
      final values = data[key];
      if (values is! List) continue;
      for (final raw in values.whereType<Map>()) {
        final offer = Map<String, dynamic>.from(raw);
        offer['card_profile'] ??= _profileValue;
        if (_validOffer(offer) &&
            !rows.any((item) => item['offer_id'] == offer['offer_id'])) {
          rows.add(offer);
        }
      }
    }
    return rows;
  }

  String _planType(Map<String, dynamic> offer) {
    final value = '${offer['plan_type'] ?? offer['type'] ?? ''}'
        .trim()
        .toUpperCase()
        .replaceAll(' ', '_');
    if (value == 'CARD' || value == 'FULL_CARD') return 'CARD';
    if (value == 'NO_COST' || value == 'NO_COST_EMI') return 'NO_COST';
    if (value == 'LOW_COST' || value == 'LOW_COST_EMI') return 'LOW_COST';
    return 'BANK_EMI';
  }

  String _offerBankName(Map<String, dynamic> offer) {
    for (final key in const [
      'provider_bank_name',
      'bank_name',
      'issuer_name',
      'provider_name',
    ]) {
      final value = '${offer[key] ?? ''}'.trim();
      if (value.isNotEmpty) return value;
    }
    return 'Card EMI';
  }

  String _offerBankKey(Map<String, dynamic> offer) {
    for (final key in const [
      'provider_bank_id',
      'bank_id',
      'bank_code',
      'provider_payment_code',
      'payment_code',
    ]) {
      final value = '${offer[key] ?? ''}'.trim();
      if (value.isNotEmpty) return '$key:$value';
    }
    return 'name:${_offerBankName(offer).toLowerCase()}';
  }

  Map<String, List<Map<String, dynamic>>> _groupOffersByBank(
      List<Map<String, dynamic>> offers) {
    final banks = <String, List<Map<String, dynamic>>>{};
    for (final offer in offers) {
      banks.putIfAbsent(_offerBankKey(offer), () => []).add(offer);
    }
    return banks;
  }

  bool _validOffer(Map<String, dynamic> offer) {
    if ('${offer['offer_id'] ?? ''}'.isEmpty || offer['selectable'] == false) {
      return false;
    }
    final profile = '${offer['card_profile'] ?? ''}'.toLowerCase();
    if (profile != 'corporate' && profile != 'personal') return false;
    final type = _planType(offer);
    final months = int.tryParse('${offer['tenure_months'] ?? 0}') ?? 0;
    if (type == 'CARD') return months == 0;
    if (const [3, 6, 9, 12].contains(months)) return true;
    if (months == 18) return type == 'NO_COST' || type == 'LOW_COST';
    if (const [24, 36].contains(months)) return type == 'LOW_COST';
    return false;
  }

  void _changePaymentMode(MiniPosPaymentMode mode) {
    if (_selecting || _selectedOffer != null || mode == _paymentMode) return;
    setState(() {
      _paymentMode = mode;
      _selectedOfferId =
          mode == MiniPosPaymentMode.card ? _singleCardOfferId(_offers) : null;
      _terms = false;
    });
  }

  void _chooseOffer(Map<String, dynamic> offer) {
    final profile = '${offer['card_profile']}'.toLowerCase();
    setState(() {
      _profile = profile == 'personal'
          ? MiniPosCardProfile.personal
          : MiniPosCardProfile.corporate;
      _selectedOfferId = '${offer['offer_id']}';
      _terms = false;
    });
  }

  Future<bool> _confirmDealerCashback(
    BuildContext context,
    int cashbackPaise,
  ) async {
    final removing = cashbackPaise == 0;
    final currentProfit = _dealerProfitPaise;
    final cashbackIncrease = cashbackPaise - _dealerCashbackPaise;
    final causesLoss = !removing &&
        currentProfit != null &&
        currentProfit - cashbackIncrease < 0;
    final formatted = miniPosMoney(cashbackPaise);
    final amount = (formatted.endsWith('.00')
            ? formatted.substring(0, formatted.length - 3)
            : formatted)
        .replaceFirst('₹', '₹ ');
    var acceptsLoss = false;
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => StatefulBuilder(
            builder: (dialogContext, setDialogState) => AlertDialog(
              title: Text(removing
                  ? 'Remove dealer cashback?'
                  : 'Confirm dealer cashback'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    removing
                        ? 'This will remove the dealer cashback and restore your payout. Do you want to recalculate the plans?'
                        : '$amount will be deducted from your final payout, Do you want to recalculate the plans?',
                    style: Theme.of(dialogContext).textTheme.bodyMedium,
                  ),
                  if (causesLoss) ...[
                    const SizedBox(height: 14),
                    CheckboxListTile(
                      key: const ValueKey('dealer-cashback-loss-acceptance'),
                      value: acceptsLoss,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(
                        'I accept the loss and wish to proceed with the cashback',
                        style: Theme.of(dialogContext).textTheme.bodyMedium,
                      ),
                      onChanged: (value) => setDialogState(
                        () => acceptsLoss = value == true,
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  key: const ValueKey('confirm-dealer-cashback'),
                  onPressed: causesLoss && !acceptsLoss
                      ? null
                      : () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Confirm & recalculate'),
                ),
              ],
            ),
          ),
        ) ??
        false;
  }

  Future<void> _showDealerCashbackSheet() async {
    if (!_canAdjustDealerCashback) return;
    final maximum = _maximumDealerCashbackPaise!;
    final controller = TextEditingController(
      text: _dealerCashbackPaise == 0
          ? ''
          : (_dealerCashbackPaise / 100).toStringAsFixed(2),
    );
    String? validationMessage;

    final contribution = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (sheetContext) => MiniPosTheme(
        child: StatefulBuilder(
          builder: (sheetContext, setSheetState) => Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(sheetContext).bottom),
            child: Container(
              key: const ValueKey('dealer-cashback-sheet'),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              decoration: const BoxDecoration(
                gradient: AppColors.linearGradient,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: .45),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.percent_rounded,
                            color: AppColors.primary),
                      ),
                      Expanded(
                        child: Text(
                          'Dealer cashback',
                          style: Theme.of(sheetContext)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        icon: Icon(Icons.close, color: AppColors.primary),
                      ),
                    ]),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter the cashback amount you want to give the customer.',
                      style: TextStyle(color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Maximum allowed: ${miniPosMoney(maximum)}',
                      style: const TextStyle(
                          color: Colors.black54, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      key: const ValueKey('dealer-cashback-input'),
                      controller: controller,
                      autofocus: true,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d{0,7}(\.\d{0,2})?')),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Dealer cashback amount',
                        prefixText: '₹ ',
                        helperText: 'Enter ₹0 to remove the dealer cashback.',
                        errorText: validationMessage,
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (_) => setSheetState(
                        () => validationMessage = null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        key: const ValueKey('apply-dealer-cashback'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          final rupees =
                              double.tryParse(controller.text.trim());
                          final paise =
                              rupees == null ? null : (rupees * 100).round();
                          if (paise == null || paise < 0) {
                            setSheetState(() =>
                                validationMessage = 'Enter a valid amount.');
                            return;
                          }
                          if (paise > maximum) {
                            setSheetState(() => validationMessage =
                                'Maximum allowed is ${miniPosMoney(maximum)}.');
                            return;
                          }
                          if (!await _confirmDealerCashback(
                            sheetContext,
                            paise,
                          )) {
                            return;
                          }
                          if (!sheetContext.mounted) return;
                          Navigator.of(sheetContext).pop(paise);
                        },
                        child: const Text('Recalculate plans'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    // Modal routes finish their reverse animation after `pop` completes. Keep
    // the field controller alive until the closing sheet is fully detached.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    controller.dispose();
    if (!mounted || contribution == null) return;

    setState(() {
      _selectedOfferId = null;
      _selectedOffer = null;
      _terms = false;
      _dealerReview = null;
      _ownerPin.clear();
    });
    await _calculateOffers(dealerCashbackPaise: contribution);
  }

  Future<void> _selectOffer() async {
    if (_selecting || !_terms || _selectedOfferId == null) return;
    setState(() => _selecting = true);
    try {
      final data = await _post('minipos/emi/quotes/select', {
        'quote_token': _quoteToken,
        'offer_id': _selectedOfferId,
        'card_profile': _selectedProfileValue,
        'terms_accepted': true,
      });
      if (data['selected_offer'] is! Map || data['frozen'] != true) {
        throw const MiniPosException(
            'Unable to confirm this option. Please calculate it again.');
      }
      if (!mounted) return;
      final selected = Map<String, dynamic>.from(data['selected_offer'] as Map);
      final quoted = _offers.cast<Map<String, dynamic>?>().firstWhere(
            (row) => row?['offer_id'] == selected['offer_id'],
            orElse: () => null,
          );
      setState(() {
        _quoteToken = '${data['quote_token'] ?? _quoteToken}';
        // `/select` intentionally returns a customer-safe subset. Preserve the
        // matching server quote row already shown to the authenticated
        // shopkeeper so its dealer review does not disappear after freezing.
        _selectedOffer = {...?quoted, ...selected};
        final approval =
            data['approval'] is Map ? data['approval'] as Map : null;
        _confirmationsRequired = int.tryParse(
                '${data['confirmations_required'] ?? approval?['confirmations_required'] ?? 0}') ??
            0;
        _confirmationsCompleted = int.tryParse(
                '${data['confirmations_completed'] ?? approval?['confirmations_completed'] ?? 0}') ??
            0;
        _dealerActionRequired = data['dealer_action_required'] == true ||
            _confirmationsCompleted < _confirmationsRequired;
        if (!_dealerActionRequired) {
          _stage = MiniPosCheckoutStage.customerInfo;
        }
      });
    } catch (error) {
      _reportError(_message(error, 'Unable to confirm this payment option.'));
    } finally {
      if (mounted) setState(() => _selecting = false);
    }
  }

  Future<void> _reviewOwnerDecision() async {
    if (_reviewing || !_dealerActionRequired) return;
    final pin = _ownerPin.text.trim();
    if (!RegExp(r'^\d{4,6}$').hasMatch(pin)) {
      _reportError('Enter the owner PIN to continue.');
      return;
    }
    setState(() => _reviewing = true);
    try {
      final data = await _post('minipos/emi/quotes/review', {
        'quote_token': _quoteToken,
        'owner_pin': pin,
      });
      if (data['dealer_review'] is! Map) {
        throw const MiniPosException('Unable to load the owner review.');
      }
      if (mounted) {
        setState(() {
          _quoteToken = '${data['quote_token'] ?? _quoteToken}';
          _dealerReview =
              Map<String, dynamic>.from(data['dealer_review'] as Map);
          _reasonTag = '${_dealerReview!['default_reason_tag'] ?? ''}'.trim();
          if (_reasonTag!.isEmpty) _reasonTag = null;
        });
      }
    } catch (error) {
      _reportError(_message(error, 'Unable to load the owner review.'));
    } finally {
      if (mounted) setState(() => _reviewing = false);
    }
  }

  Future<void> _confirmOwnerDecision() async {
    if (_confirming || _dealerReview == null) return;
    final confirmation = '${_dealerReview!['next_confirmation'] ?? ''}';
    if (confirmation.isEmpty) return;
    setState(() => _confirming = true);
    try {
      final data = await _post('minipos/emi/quotes/confirm', {
        'quote_token': _quoteToken,
        'owner_pin': _ownerPin.text.trim(),
        'confirmation': confirmation,
        if (_dealerReview!['reason_required'] == true) 'reason_tag': _reasonTag,
      });
      _ownerPin.clear();
      _dealerReview = null;
      _reasonTag = null;
      _applyQuote(data);
    } catch (error) {
      _reportError(_message(error, 'Unable to record owner confirmation.'));
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }

  Future<void> _startPayment() async {
    if (_startingPayment || _selectedOffer == null || _dealerActionRequired) {
      return;
    }
    if (_hasPendingPayment) {
      await _openHostedCheckout();
      return;
    }
    if (_form.currentState?.validate() != true) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _startingPayment = true);
    try {
      final data = await _post('minipos/checkout', {
        'imei': _imei,
        'checkout_token': widget.checkoutToken,
        'quote_token': _quoteToken,
        'offer_id': _selectedOfferId,
        'card_profile': _selectedProfileValue,
        'name': _name.text.trim(),
        'phone': _phone.text.trim(),
      });
      final order = data['order'] is Map ? data['order'] as Map : data;
      final payment = data['payment'] is Map ? data['payment'] as Map : data;
      _appOrderId = '${order['id'] ?? data['order_id'] ?? ''}';
      _cashfreeOrderId =
          '${payment['cashfree_order_id'] ?? payment['order_id'] ?? ''}';
      _paymentSessionId =
          '${payment['payment_session_id'] ?? data['payment_session_id'] ?? ''}';
      _paymentEnvironment =
          '${payment['environment'] ?? data['environment'] ?? 'sandbox'}';
      if (_appOrderId!.isEmpty ||
          _cashfreeOrderId!.isEmpty ||
          _paymentSessionId!.isEmpty) {
        throw const MiniPosException('Payment gateway session is incomplete.');
      }
      await _openHostedCheckout();
    } catch (error) {
      _reportError(_message(error, 'Unable to open the payment gateway.'));
    } finally {
      if (mounted) setState(() => _startingPayment = false);
    }
  }

  Future<void> _openHostedCheckout() async {
    final orderId = _cashfreeOrderId;
    final sessionId = _paymentSessionId;
    if (orderId == null || sessionId == null) return;
    if (widget.cashfreeLauncher != null) {
      await widget.cashfreeLauncher!(orderId, sessionId, _paymentEnvironment);
      return;
    }
    try {
      final session = CFSessionBuilder()
          .setEnvironment(_paymentEnvironment == 'production'
              ? CFEnvironment.PRODUCTION
              : CFEnvironment.SANDBOX)
          .setOrderId(orderId)
          .setPaymentSessionId(sessionId)
          .build();
      _cashfree
          .doPayment(CFWebCheckoutPaymentBuilder().setSession(session).build());
    } on CFException catch (error) {
      throw MiniPosException(error.message);
    }
  }

  void _cashfreeSuccess(String orderId) {
    if (orderId != _cashfreeOrderId) {
      _reportError(
          'The payment gateway returned a different order. Check payment status before retrying.');
      return;
    }
    unawaited(_verifyPayment());
  }

  void _cashfreeFailure(CFErrorResponse error, String orderId) {
    _reportError(
        '${error.getMessage() ?? 'Gateway checkout was not completed.'} You can safely retry or check payment status.');
  }

  Future<void> _verifyPayment({bool silent = false}) async {
    if (_verifyingPayment || _appOrderId == null) return;
    setState(() => _verifyingPayment = true);
    try {
      final data = await _get(
          'minipos/payments/${Uri.encodeComponent(_appOrderId!)}/status');
      if (data['paid'] == true || '${data['payment_status']}' == 'paid') {
        MiniPosTempCart.instance.clear();
        if (!mounted) return;
        await Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => MiniPosOrderDetailPage(
              orderId: _appOrderId!, paymentCompleted: true),
        ));
      } else if (!silent && mounted) {
        _reportError(
            'Payment is still pending. Complete it in the gateway, retry, or cancel this attempt.');
      }
    } catch (error) {
      if (!silent && mounted) {
        _reportError(_message(error, 'Unable to verify payment status.'));
      }
    } finally {
      if (mounted) setState(() => _verifyingPayment = false);
    }
  }

  Future<void> _cancelPayment() async {
    if (_cancellingPayment || _appOrderId == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel payment attempt?'),
        content: const Text(
            'The payment gateway will be checked first. A successful payment cannot be cancelled here.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep payment')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Cancel attempt')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _cancellingPayment = true);
    try {
      final data = await _post(
          'minipos/payments/${Uri.encodeComponent(_appOrderId!)}/cancel', {});
      if (data['paid'] == true) {
        await _verifyPayment();
        return;
      }
      if (mounted) {
        const message =
            'Payment attempt cancelled. The selected plan is retained.';
        setState(() {
          _appOrderId = null;
          _cashfreeOrderId = null;
          _paymentSessionId = null;
        });
        miniPosMessage(context, message);
      }
    } catch (error) {
      _reportError(_message(error, 'Unable to cancel this payment attempt.'));
    } finally {
      if (mounted) setState(() => _cancellingPayment = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: !_hasPendingPayment,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && _hasPendingPayment) {
            miniPosMessage(context,
                'A gateway payment is pending. Check its status or cancel the attempt before leaving.');
          }
        },
        child: MiniPosScaffold(
          appBar: AppBar(
            title: Text(_stage == MiniPosCheckoutStage.review
                ? 'Review payment'
                : 'Customer info'),
            actions: _stage == MiniPosCheckoutStage.review
                ? [
                    IconButton(
                      key: const ValueKey('dealer-margin-visibility'),
                      tooltip: !_canToggleDealerMargins
                          ? 'Shopkeeper profit margin is not available'
                          : _showDealerMargins
                              ? 'Hide shopkeeper profit margins'
                              : 'Show shopkeeper profit margins',
                      style: IconButton.styleFrom(
                        foregroundColor: Colors.white,
                        disabledForegroundColor:
                            Colors.white.withValues(alpha: .42),
                        backgroundColor: Colors.white.withValues(alpha: .14),
                        disabledBackgroundColor:
                            Colors.white.withValues(alpha: .06),
                      ),
                      onPressed:
                          _canToggleDealerMargins ? _toggleDealerMargins : null,
                      icon: Icon(
                        _showDealerMargins
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        key: const ValueKey('dealer-cashback-action'),
                        tooltip: _dealerCashbackTooltip,
                        style: IconButton.styleFrom(
                          foregroundColor: Colors.white,
                          disabledForegroundColor:
                              Colors.white.withValues(alpha: .42),
                          backgroundColor: Colors.white.withValues(alpha: .14),
                          disabledBackgroundColor:
                              Colors.white.withValues(alpha: .06),
                        ),
                        onPressed: _canAdjustDealerCashback
                            ? _showDealerCashbackSheet
                            : null,
                        icon: const Icon(Icons.card_giftcard_rounded),
                      ),
                    ),
                  ]
                : null,
          ),
          body: SafeArea(
            top: false,
            child: Form(
              key: _form,
              child: ListView(
                key: const ValueKey('minipos-checkout-list'),
                padding: const EdgeInsets.all(16),
                children: [
                  if (_stage == MiniPosCheckoutStage.review) ...[
                    if (_quoteToken == null) ...[
                      if (_loadingQuote) ...[
                        const Center(child: CircularProgressIndicator()),
                        const SizedBox(height: 12),
                        const Center(
                            child: Text('Calculating payment options…')),
                      ] else
                        FilledButton.icon(
                          key: const ValueKey('calculate-options'),
                          onPressed: _calculateOffers,
                          icon: const Icon(Icons.refresh),
                          label: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text('Retry payment options'),
                          ),
                        ),
                    ] else ...[
                      if (_product != null) _productSummary(),
                      _paymentModeSelector(),
                      const SizedBox(height: 12),
                      _planList(),
                      if (_dealerActionRequired) _ownerApproval(),
                    ],
                  ] else ...[
                    Text('Customer details',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _field(_name, 'Customer name', validator: _required),
                    _field(_phone, 'Mobile number',
                        keyboard: TextInputType.phone,
                        prefix: '+91 ',
                        formatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: (value) =>
                            RegExp(r'^[6-9]\d{9}$').hasMatch(value ?? '')
                                ? null
                                : 'Enter a valid 10-digit mobile number'),
                    _paymentActions(),
                  ],
                ],
              ),
            ),
          ),
        ),
      );

  Widget _productSummary() => Container(
        key: const ValueKey('quote-product-summary'),
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: .22)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${_product!['product_title'] ?? 'Device'}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          if ('${_product!['variant_title'] ?? ''}'.trim().isNotEmpty)
            Text('${_product!['variant_title']}',
                maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          _summaryRow('MOP', _product!['mop_paise'], strong: true),
        ]),
      );

  Widget _paymentModeSelector() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment type', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<MiniPosPaymentMode>(
              key: const ValueKey('payment-mode-selector'),
              segments: const [
                ButtonSegment(
                    value: MiniPosPaymentMode.card, label: Text('Card')),
                ButtonSegment(
                    value: MiniPosPaymentMode.emi, label: Text('Cost EMI')),
                ButtonSegment(
                    value: MiniPosPaymentMode.noCostEmi,
                    label: FittedBox(
                        fit: BoxFit.scaleDown, child: Text('No Cost EMI'))),
              ],
              selected: {_paymentMode},
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) =>
                    states.contains(WidgetState.selected)
                        ? AppColors.primary
                        : Colors.white),
                foregroundColor: WidgetStateProperty.resolveWith((states) =>
                    states.contains(WidgetState.selected)
                        ? Colors.white
                        : AppColors.primary),
                side: WidgetStatePropertyAll(
                  BorderSide(color: AppColors.primary),
                ),
              ),
              onSelectionChanged: _selectedOffer == null
                  ? (value) => _changePaymentMode(value.first)
                  : null,
              showSelectedIcon: false,
            ),
          ),
          const SizedBox(height: 6),
        ],
      );

  Widget _planList() {
    final rows = _visibleOffers;
    if (rows.isEmpty) {
      if (_paymentMode == MiniPosPaymentMode.emi) {
        return Container(
          key: const ValueKey('interest-bearing-emi-empty'),
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF5FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: .22),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.account_balance_outlined,
                  color: AppColors.primary, size: 28),
              const SizedBox(height: 8),
              const Text(
                'No interest-bearing EMI plans',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text(
                'No interest-bearing EMI estimate is available right now. Try Card or No Cost EMI.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        );
      }
      if (_isEmiMode && !_hostedEmiBindingAvailable) {
        return Container(
          key: const ValueKey('hosted-emi-unavailable'),
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFFCC80)),
          ),
          child: const Text(
            'EMI plans are not available for this payment right now. You can continue with Card payment.',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        );
      }
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text(switch (_paymentMode) {
          MiniPosPaymentMode.card => 'Card payment is not available right now.',
          MiniPosPaymentMode.emi =>
            'No interest-bearing EMI plan is available for this payment.',
          MiniPosPaymentMode.noCostEmi =>
            'No Cost EMI is not available for this payment.',
        }),
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Payment options', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 4),
      Text(
        switch (_paymentMode) {
          MiniPosPaymentMode.card =>
            'Review the card payment amount before continuing.',
          MiniPosPaymentMode.emi =>
            'Compare interest-bearing monthly payment estimates. The gateway confirms the final bank and EMI plan.',
          MiniPosPaymentMode.noCostEmi =>
            'Compare No Cost EMI estimates. The gateway confirms final eligibility and the EMI plan.',
        },
        style: const TextStyle(color: Colors.black54),
      ),
      if (_isEmiMode && !_hostedEmiBindingAvailable)
        Container(
          key: const ValueKey('hosted-emi-unavailable'),
          width: double.infinity,
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFFCC80)),
          ),
          child: const Text(
            'EMI plans are not available for this payment right now. You can continue with Card payment.',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      if (_dealerActionRequired)
        const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Text(
            'Complete the private owner confirmation below before selecting a payment option.',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      const SizedBox(height: 8),
      if (_isEmiMode)
        ..._emiBankCards(rows)
      else
        for (final offer in rows) _planCard(offer),
      if (_selectedOffer == null) ...[
        CheckboxListTile(
          key: const ValueKey('plan-terms'),
          contentPadding: EdgeInsets.zero,
          value: _terms,
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: _dealerActionRequired
              ? null
              : (value) => setState(() => _terms = value == true),
          title: Text(switch (_paymentMode) {
            MiniPosPaymentMode.card =>
              'The customer confirms the card payment amount and will complete payment in the gateway.',
            MiniPosPaymentMode.emi =>
              'The customer understands this is an estimate and will select the final EMI plan in the gateway.',
            MiniPosPaymentMode.noCostEmi =>
              'The customer understands that No Cost EMI eligibility and the final plan will be confirmed in the gateway.',
          }),
        ),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            key: const ValueKey('confirm-plan'),
            onPressed: _dealerActionRequired ||
                    _selecting ||
                    !_terms ||
                    _selectedOfferId == null
                ? null
                : _selectOffer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(_selecting ? 'Continuing…' : 'Continue'),
            ),
          ),
        ),
      ],
    ]);
  }

  List<Widget> _emiBankCards(List<Map<String, dynamic>> offers) {
    final banks = _groupOffersByBank(offers).entries.toList(growable: false);
    return [
      for (var index = 0; index < banks.length; index++)
        Card(
          key: ValueKey('emi-bank-${_offerBankName(banks[index].value.first)}'),
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color(0xFFDCE3E6)),
            borderRadius: BorderRadius.circular(14),
          ),
          clipBehavior: Clip.antiAlias,
          child: ExpansionTile(
            key: PageStorageKey<String>('emi-bank-${banks[index].key}'),
            initiallyExpanded: index == 0,
            leading:
                Icon(Icons.account_balance_outlined, color: AppColors.primary),
            title: Text(
              _offerBankName(banks[index].value.first),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              '${banks[index].value.length} ${banks[index].value.length == 1 ? 'plan' : 'plans'}',
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
            iconColor: AppColors.primary,
            collapsedIconColor: AppColors.primary,
            shape: const Border(),
            collapsedShape: const Border(),
            tilePadding: const EdgeInsets.symmetric(horizontal: 14),
            childrenPadding: const EdgeInsets.fromLTRB(10, 0, 10, 4),
            children: [
              for (var offerIndex = 0;
                  offerIndex < banks[index].value.length;
                  offerIndex++)
                _planCard(
                  banks[index].value[offerIndex],
                  showBankName: false,
                  emiColorIndex: (index * 3) + offerIndex,
                ),
            ],
          ),
        ),
    ];
  }

  Widget _planCard(
    Map<String, dynamic> offer, {
    bool showBankName = true,
    int? emiColorIndex,
  }) {
    const emiAccents = [
      Color(0xFF2A7F9E),
      Color(0xFF32845F),
      Color(0xFF7A5AB5),
      Color(0xFFC7772B),
      Color(0xFFB55278),
      Color(0xFF4073B8),
      Color(0xFF68843B),
    ];
    final id = '${offer['offer_id']}';
    final selected = id == _selectedOfferId;
    final type = _planType(offer);
    final emiAccent = emiColorIndex == null
        ? null
        : emiAccents[emiColorIndex % emiAccents.length];
    final months = int.tryParse('${offer['tenure_months'] ?? 0}') ?? 0;
    final isEmiPlan = months > 0;
    final interestRate = _interestRateText(offer);
    final title = type == 'CARD' ? 'Card payment' : '$months-month estimate';
    final planSubtitle =
        '${offer['provider_plan_label'] ?? offer['plan_label'] ?? ''}'.trim();
    final normalizedTitle =
        title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
    final normalizedSubtitle =
        planSubtitle.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
    final showPlanSubtitle = planSubtitle.isNotEmpty &&
        !normalizedSubtitle.startsWith(normalizedTitle);
    return Card(
      key: ValueKey('offer-$id'),
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: isEmiPlan
          ? Colors.transparent
          : selected
              ? const Color(0xFFF0F8F8)
              : Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: selected
              ? AppColors.primary
              : emiAccent?.withValues(alpha: .62) ?? const Color(0xFFDCE3E6),
          width: selected ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              IconButton(
                key: ValueKey('offer-info-$id'),
                visualDensity: VisualDensity.compact,
                tooltip: 'View payout and charges',
                onPressed: () => _showChargeBreakdown(offer),
                icon: const Icon(Icons.info_outline, size: 21),
              ),
            ]),
            if (months > 0 && interestRate != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  key: ValueKey('interest-badge-$id'),
                  margin: const EdgeInsets.only(bottom: 5),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        (emiAccent ?? AppColors.primary).withValues(alpha: .18),
                    border: Border.all(
                      color: (emiAccent ?? AppColors.primary)
                          .withValues(alpha: .7),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    interestRate,
                    style: TextStyle(
                      color: emiAccent ?? AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            if (showBankName &&
                '${offer['provider_bank_name'] ?? offer['bank_name'] ?? ''}'
                    .trim()
                    .isNotEmpty)
              Text(
                '${offer['provider_bank_name'] ?? offer['bank_name']}',
                style: const TextStyle(color: Colors.black54),
              ),
            if (showPlanSubtitle)
              Text(
                planSubtitle,
                style: const TextStyle(color: Colors.black54),
              ),
            const SizedBox(height: 6),
            _summaryRow(type == 'CARD' ? 'Amount to pay' : 'Card amount',
                offer['card_amount_paise'] ?? offer['customer_payable_paise'],
                strong: true),
            if (months > 0 && offer['monthly_emi_paise'] != null)
              _summaryRow('Monthly payment', offer['monthly_emi_paise']),
            if (offer['cashback_paise'] != null)
              _summaryRow('Cashback', offer['cashback_paise']),
            if ((int.tryParse('${offer['dealer_cashback_paise'] ?? 0}') ?? 0) >
                0)
              _summaryRow('Dealer cashback', offer['dealer_cashback_paise']),
            if (_showDealerMargins) _dealerProfitHighlight(id, offer),
            if (_selectedOffer == null) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: selected
                    ? Chip(
                        key: ValueKey('estimate-selected-$id'),
                        avatar: const Icon(Icons.check, size: 17),
                        label: const Text('Selected plan'),
                        backgroundColor: const Color(0xFFDDEFEF),
                        side: BorderSide(color: AppColors.primary),
                      )
                    : OutlinedButton.icon(
                        key: ValueKey('use-estimate-$id'),
                        onPressed: _dealerActionRequired
                            ? null
                            : () => _chooseOffer(offer),
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: const Text('Select Plan'),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _ownerApproval() => Container(
        key: const ValueKey('owner-approval'),
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Owner confirmation required',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text(
              'Keep this review private. Enter the owner PIN to inspect and confirm the server calculation.'),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey('inline-owner-pin'),
            controller: _ownerPin,
            keyboardType: TextInputType.number,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            decoration: const InputDecoration(
                labelText: 'Owner PIN', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          if (_dealerReview == null)
            FilledButton(
                key: const ValueKey('review-owner-decision'),
                onPressed: _reviewing ? null : _reviewOwnerDecision,
                child: Text(_reviewing ? 'Loading…' : 'Review privately'))
          else ...[
            _dealerReviewDetails(_dealerReview!),
            if (_dealerReview!['reason_required'] == true) ...[
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                key: const ValueKey('loss-reason'),
                initialValue: _reasonTag,
                decoration: const InputDecoration(
                    labelText: 'Reason for accepting loss',
                    border: OutlineInputBorder()),
                items: (_dealerReview!['reason_tags'] as List? ?? const [])
                    .whereType<Map>()
                    .map((item) => DropdownMenuItem<String>(
                          value: '${item['value']}',
                          child: Text('${item['label'] ?? item['value']}'),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _reasonTag = value),
              ),
            ],
            const SizedBox(height: 10),
            FilledButton(
                key: const ValueKey('confirm-owner-decision'),
                onPressed: _confirming ? null : _confirmOwnerDecision,
                child: Text(_confirming ? 'Confirming…' : 'Confirm decision')),
          ],
        ]),
      );

  Widget _dealerReviewDetails(Map<String, dynamic> review) => Container(
        key: const ValueKey('dealer-review-details'),
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (review['message'] is String) Text('${review['message']}'),
          const SizedBox(height: 8),
          _summaryRow('Dealer cost', review['dealer_cost_paise']),
          _summaryRow('Proposed payout', review['proposed_payout_paise']),
          _summaryRow('Proposed margin', review['proposed_margin_paise'],
              strong: true),
          if (review['below_cost'] == true)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Warning: this payout is below dealer cost.',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w700)),
            ),
        ]),
      );

  Widget _paymentActions() => Padding(
        padding: const EdgeInsets.only(top: 18),
        child: Column(children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const ValueKey('pay-now'),
              onPressed:
                  _dealerActionRequired || _startingPayment || _verifyingPayment
                      ? null
                      : _startPayment,
              icon: const Icon(Icons.lock_outline),
              label: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_startingPayment
                    ? 'Opening gateway…'
                    : _hasPendingPayment
                        ? 'Retry gateway checkout'
                        : 'Continue to Payment'),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'The customer selects the final card, bank and EMI tenure securely in the gateway. This estimate does not preselect a gateway plan.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
          if (_hasPendingPayment) ...[
            const SizedBox(height: 10),
            Wrap(alignment: WrapAlignment.center, spacing: 8, children: [
              OutlinedButton(
                key: const ValueKey('check-payment-status'),
                onPressed: _verifyingPayment ? null : () => _verifyPayment(),
                child: Text(
                    _verifyingPayment ? 'Checking…' : 'Check payment status'),
              ),
              TextButton(
                key: const ValueKey('cancel-payment-attempt'),
                onPressed: _cancellingPayment ? null : _cancelPayment,
                child: Text(_cancellingPayment
                    ? 'Cancelling…'
                    : 'Cancel payment attempt'),
              ),
            ]),
          ],
        ]),
      );

  Widget _summaryRow(
    String label,
    dynamic paise, {
    bool strong = false,
    bool masked = false,
    Key? valueKey,
  }) {
    if (paise == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Text(label)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(masked ? '••••' : miniPosMoney(paise),
              key: valueKey,
              textAlign: TextAlign.end,
              style: TextStyle(
                  fontWeight: strong ? FontWeight.w700 : FontWeight.w500)),
        ),
      ]),
    );
  }

  Widget _dealerProfitHighlight(
    String offerId,
    Map<String, dynamic> offer, {
    String label = 'Shopkeeper profit margin',
    bool revealed = true,
    VoidCallback? onVisibilityPressed,
  }) =>
      Container(
        key: ValueKey('dealer-profit-highlight-$offerId'),
        width: double.infinity,
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: .09),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: .28),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                revealed ? _dealerProfitText(offer) : '••••',
                key: ValueKey('dealer-profit-value-$offerId'),
                textAlign: TextAlign.end,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            if (onVisibilityPressed != null) ...[
              const SizedBox(width: 4),
              IconButton(
                key: ValueKey('dealer-profit-visibility-$offerId'),
                tooltip: revealed ? 'Hide your profit' : 'Show your profit',
                visualDensity: VisualDensity.compact,
                onPressed: onVisibilityPressed,
                icon: Icon(
                  revealed
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                ),
              ),
            ],
          ],
        ),
      );

  int? _dealerCostPaise(Map<String, dynamic> offer) {
    final finalPayout = num.tryParse(
      '${offer['final_dealer_payout_paise'] ?? offer['quoted_dealer_payout_paise'] ?? offer['dealer_payout_paise'] ?? ''}',
    );
    final profit = num.tryParse('${offer['dealer_profit_paise'] ?? ''}');
    if (finalPayout == null || profit == null) return null;
    return (finalPayout - profit).round();
  }

  int? _convenienceFeePaise(Map<String, dynamic> offer) {
    final explicit =
        num.tryParse('${offer['convenience_fee_paise'] ?? ''}'.trim());
    if (explicit != null) return explicit.round();
    // Compatibility for quotes created before the backend exposed the
    // separated field. Total GPF already includes the platform component.
    final total = num.tryParse('${offer['total_gpf_paise'] ?? ''}'.trim());
    final platform =
        num.tryParse('${offer['gowelmart_margin_paise'] ?? ''}'.trim());
    if (total == null || platform == null) return null;
    return (total - platform).clamp(0, double.maxFinite).round();
  }

  String _dealerProfitText(Map<String, dynamic> offer) {
    final profitPaise =
        num.tryParse('${offer['dealer_profit_paise'] ?? ''}'.trim());
    final percentage =
        num.tryParse('${offer['dealer_profit_margin_percent'] ?? ''}'.trim());
    if (percentage != null) {
      final margin = '${percentage.toStringAsFixed(2)}%';
      return profitPaise == null
          ? margin
          : '${miniPosMoney(profitPaise)} ($margin)';
    }

    final basisPoints = num.tryParse(
      '${offer['dealer_profit_margin_bps'] ?? offer['dealer_margin_bps'] ?? ''}'
          .trim(),
    );
    final margin = basisPoints == null
        ? null
        : '${(basisPoints / 100).toStringAsFixed(2)}%';
    if (profitPaise == null) return margin ?? 'Not available';
    if (margin == null) return miniPosMoney(profitPaise);
    return '${miniPosMoney(profitPaise)} ($margin)';
  }

  String? _interestRateText(Map<String, dynamic> offer) {
    final selectedRate = offer['selected_rate'];
    final basisPoints = num.tryParse(
      '${offer['annual_interest_bps'] ?? (selectedRate is Map ? selectedRate['annual_interest_bps'] : null) ?? ''}'
          .trim(),
    );
    if (basisPoints == null) return null;
    return '${(basisPoints / 100).toStringAsFixed(2)}% p.a.';
  }

  Future<void> _showChargeBreakdown(Map<String, dynamic> offer) async {
    final months = int.tryParse('${offer['tenure_months'] ?? 0}') ?? 0;
    final interestRate = _interestRateText(offer);
    var revealProfit = false;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (sheetContext) => MiniPosTheme(
        child: StatefulBuilder(
          builder: (sheetContext, setSheetState) => FractionallySizedBox(
            heightFactor: .72,
            child: Container(
              key: const ValueKey('charge-breakdown-drawer'),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              decoration: const BoxDecoration(
                gradient: AppColors.linearGradient,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: .45),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.receipt_long_outlined,
                            color: AppColors.primary, size: 22),
                      ),
                      Expanded(
                        child: Text('Payment breakdown',
                            style: Theme.of(sheetContext)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700)),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        icon: Icon(Icons.close, color: AppColors.primary),
                      ),
                    ]),
                    const Text(
                      'Private shopkeeper view. Use this to understand the payout and charges.',
                      style: TextStyle(color: Colors.black54),
                    ),
                    if (months > 0 && interestRate != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        key: ValueKey(
                          'breakdown-interest-badge-${offer['offer_id']}',
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: .12),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: .55),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          interestRate,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(children: [
                          _summaryRow(
                            'Customer pays',
                            offer['card_amount_paise'] ??
                                offer['customer_payable_paise'],
                            strong: true,
                          ),
                          if (months > 0 && offer['monthly_emi_paise'] != null)
                            _summaryRow(
                                'Monthly payment', offer['monthly_emi_paise']),
                          _summaryRow('Cashback', offer['cashback_paise']),
                          if ((int.tryParse(
                                      '${offer['dealer_cashback_paise'] ?? 0}') ??
                                  0) >
                              0)
                            _summaryRow(
                              'Dealer cashback',
                              offer['dealer_cashback_paise'],
                            ),
                          const Divider(height: 28),
                          _summaryRow(
                            'Purchase cost',
                            _dealerCostPaise(offer),
                            masked: !revealProfit,
                            valueKey: ValueKey(
                              'purchase-cost-value-${offer['offer_id']}',
                            ),
                          ),
                          _summaryRow(
                            'Final payout',
                            offer['final_dealer_payout_paise'] ??
                                offer['quoted_dealer_payout_paise'] ??
                                offer['dealer_payout_paise'],
                            strong: true,
                          ),
                          _dealerProfitHighlight(
                            'breakdown-${offer['offer_id']}',
                            offer,
                            label: 'Your profit',
                            revealed: revealProfit,
                            onVisibilityPressed: () async {
                              if (revealProfit) {
                                setSheetState(() => revealProfit = false);
                                return;
                              }
                              if (await _verifyProfitPin() &&
                                  sheetContext.mounted) {
                                setSheetState(() => revealProfit = true);
                              }
                            },
                          ),
                          const Divider(height: 28),
                          _summaryRow(
                              'Convenience fee', _convenienceFeePaise(offer)),
                          _summaryRow('Platform fee (GST inclusive)',
                              offer['gowelmart_margin_paise']),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        child: const Text('Done'),
                      ),
                    ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType? keyboard,
    String? prefix,
    List<TextInputFormatter>? formatters,
    String? Function(String?)? validator,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TextFormField(
          key: ValueKey(label == 'Customer name'
              ? 'customer-name'
              : label == 'Mobile number'
                  ? 'customer-phone'
                  : 'field-$label'),
          enabled: _stage == MiniPosCheckoutStage.customerInfo &&
              !_startingPayment &&
              !_hasPendingPayment,
          controller: controller,
          keyboardType: keyboard,
          inputFormatters: formatters,
          validator: validator,
          textCapitalization: keyboard == TextInputType.phone
              ? TextCapitalization.none
              : TextCapitalization.words,
          decoration: InputDecoration(
              labelText: label,
              prefixText: prefix,
              counterText: '',
              border: const OutlineInputBorder()),
        ),
      );
}
