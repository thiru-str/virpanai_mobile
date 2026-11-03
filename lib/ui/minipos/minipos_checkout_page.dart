import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:waioz/api/minipos_service.dart';
import 'package:waioz/ui/minipos/minipos_order_detail_page.dart';
import 'package:waioz/ui/minipos/minipos_temp_cart.dart';
import 'package:waioz/ui/minipos/minipos_widgets.dart';

class MiniPosCheckoutPage extends StatefulWidget {
  final int total;
  final List<Map<String, dynamic>> items;
  final String checkoutToken;
  const MiniPosCheckoutPage(
      {super.key,
      required this.total,
      required this.items,
      required this.checkoutToken});
  @override
  State<MiniPosCheckoutPage> createState() => _MiniPosCheckoutPageState();
}

class _MiniPosCheckoutPageState extends State<MiniPosCheckoutPage> {
  final _form = GlobalKey<FormState>();
  final _cashfree = CFPaymentGatewayService();
  final _api = MiniPosService.instance;
  // Walk-in sale: only the customer's name and mobile number are needed.
  final _name = TextEditingController(), _phone = TextEditingController();
  bool _busy = false;
  bool _resolving = false;
  bool _paymentOpen = false;
  bool _cancelRequested = false;
  bool _userCancelled = false;
  String? _internalOrderId;
  @override
  void initState() {
    super.initState();
    _cashfree.setCallback(_verify, _failed);
  }

  @override
  void dispose() {
    for (final c in [_name, _phone]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;
  Future<void> _checkout() async {
    if (_busy) return;
    if (_internalOrderId != null) {
      await _retryPayment();
      return;
    }
    if (!_form.currentState!.validate()) return;
    FocusManager.instance.primaryFocus?.unfocus();
    _cancelRequested = false;
    _userCancelled = false;
    setState(() => _busy = true);
    try {
      final data = await _api.post('minipos/checkout', {
        'expected_total': widget.total,
        'items': widget.items,
        'checkout_token': widget.checkoutToken,
        'name': _name.text.trim(),
        'phone': _phone.text.replaceAll(' ', '').trim(),
      });
      _internalOrderId = '${data['order']['id']}';
      if (!mounted) return;
      final payment = Map<String, dynamic>.from(data['payment']);
      final session = CFSessionBuilder()
          .setEnvironment(payment['environment'] == 'production'
              ? CFEnvironment.PRODUCTION
              : CFEnvironment.SANDBOX)
          .setOrderId('${payment['cashfree_order_id']}')
          .setPaymentSessionId('${payment['payment_session_id']}')
          .build();
      // Cashfree's native activity is translucent while its sheet loads.
      // Paint a neutral background before launch so the form cannot flash through.
      setState(() => _paymentOpen = true);
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
      _cashfree.setCallback(_verify, _failed);
      _cashfree
          .doPayment(CFWebCheckoutPaymentBuilder().setSession(session).build());
    } catch (e) {
      if (_internalOrderId != null) {
        _cancelRequested = true;
        await _resolvePayment();
      } else if (mounted) {
        miniPosMessage(context, e);
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _verify(String _) => _resolvePayment();

  Future<void> _retryPayment() async {
    _cancelRequested = true;
    _userCancelled = false;
    await _resolvePayment();
    if (mounted && _internalOrderId == null) await _checkout();
  }

  Future<void> _resolvePayment() async {
    final id = _internalOrderId;
    if (id == null || _resolving || !mounted) return;
    _resolving = true;
    setState(() => _busy = true);
    try {
      var result = _cancelRequested
          ? await _api.post('minipos/payments/$id/cancel', {})
          : await _api.get('minipos/payments/$id/status');
      for (var attempt = 0;
          attempt < 8 && result['payment_status'] == 'pending';
          attempt++) {
        await Future<void>.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
        result = await _api.get('minipos/payments/$id/status');
      }
      if (!mounted) return;
      if (result['paid'] == true) {
        MiniPosTempCart.instance.clear();
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => MiniPosOrderDetailPage(
                    orderId: id, paymentCompleted: true)));
      } else if (['failed', 'expired', 'cancelled']
          .contains(result['payment_status'])) {
        _internalOrderId = null;
        miniPosMessage(
            context,
            _userCancelled
                ? 'Payment cancelled. Your cart is ready to try again.'
                : 'Payment was not completed. Please try again.');
      } else {
        miniPosMessage(
            context, 'Cashfree is still closing this payment. Retry shortly.');
      }
    } catch (_) {
      if (mounted) {
        miniPosMessage(context,
            'Unable to confirm payment status. Check again before retrying.');
      }
    } finally {
      _resolving = false;
      if (mounted) {
        setState(() {
          _busy = false;
          _paymentOpen = false;
        });
      }
    }
  }

  void _failed(CFErrorResponse error, String _) {
    _cancelRequested = true;
    _userCancelled = '${error.getCode()} ${error.getMessage()}'
        .toLowerCase()
        .contains('cancel');
    _resolvePayment();
  }

  @override
  Widget build(BuildContext context) => _paymentOpen
      ? PopScope(
          canPop: false,
          child: MiniPosScaffold(
            body: const Center(child: CircularProgressIndicator()),
          ),
        )
      : MiniPosScaffold(
          appBar: AppBar(title: const Text('Customer checkout')),
          body: Form(
              key: _form,
              child: ListView(padding: const EdgeInsets.all(16), children: [
                Text('Order total: ${miniPosMoney(widget.total)}',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                const Text(
                    'Pay by credit or debit card, in full or with EMI.',
                    style: TextStyle(color: Colors.black54)),
                const SizedBox(height: 20),
                _field(_name, 'Customer name', validator: _required),
                // Indian mobile: fixed +91, exactly 10 digits.
                _field(_phone, 'Mobile number',
                    keyboard: TextInputType.phone,
                    prefix: '+91 ',
                    formatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: (v) => RegExp(r'^[6-9]\d{9}$').hasMatch(v ?? '')
                        ? null
                        : 'Enter a valid 10-digit mobile number'),
                const SizedBox(height: 12),
                FilledButton(
                    onPressed: _busy ? null : _checkout,
                    child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: _busy
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : Text(_internalOrderId != null
                                ? 'Retry payment'
                                : 'Pay ${miniPosMoney(widget.total)}')))
              ])));
  Widget _field(TextEditingController controller, String label,
          {TextInputType? keyboard,
          String? prefix,
          List<TextInputFormatter>? formatters,
          String? Function(String?)? validator}) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: TextFormField(
              enabled: !_busy && _internalOrderId == null,
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
                  border: const OutlineInputBorder())));
}
