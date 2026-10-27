import 'package:flutter/material.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';
import 'package:waioz/api/minipos_service.dart';
import 'package:waioz/ui/minipos/minipos_order_detail_page.dart';
import 'package:waioz/ui/minipos/minipos_widgets.dart';

class MiniPosCheckoutPage extends StatefulWidget {
  final int total;
  const MiniPosCheckoutPage({super.key, required this.total});
  @override
  State<MiniPosCheckoutPage> createState() => _MiniPosCheckoutPageState();
}

class _MiniPosCheckoutPageState extends State<MiniPosCheckoutPage> {
  final _form = GlobalKey<FormState>();
  final _cashfree = CFPaymentGatewayService();
  final _api = MiniPosService.instance;
  final _name = TextEditingController(),
      _phone = TextEditingController(),
      _email = TextEditingController(),
      _address1 = TextEditingController(),
      _address2 = TextEditingController(),
      _city = TextEditingController(),
      _state = TextEditingController(),
      _pincode = TextEditingController();
  bool _busy = false;
  String? _internalOrderId;
  @override
  void initState() {
    super.initState();
    _cashfree.setCallback(_verify, _failed);
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _phone,
      _email,
      _address1,
      _address2,
      _city,
      _state,
      _pincode
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;
  Future<void> _checkout() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final data = await _api.post('minipos/checkout', {
        'name': _name.text.trim(),
        'phone': _phone.text.trim(),
        'email': _email.text.trim(),
        'address_line_1': _address1.text.trim(),
        'address_line_2': _address2.text.trim(),
        'city': _city.text.trim(),
        'state': _state.text.trim(),
        'pincode': _pincode.text.trim()
      });
      _internalOrderId = '${data['order']['id']}';
      final payment = Map<String, dynamic>.from(data['payment']);
      final session = CFSessionBuilder()
          .setEnvironment(payment['environment'] == 'production'
              ? CFEnvironment.PRODUCTION
              : CFEnvironment.SANDBOX)
          .setOrderId('${payment['cashfree_order_id']}')
          .setPaymentSessionId('${payment['payment_session_id']}')
          .build();
      _cashfree
          .doPayment(CFWebCheckoutPaymentBuilder().setSession(session).build());
    } on CFException catch (e) {
      if (mounted) miniPosMessage(context, e.message);
      setState(() => _busy = false);
    } catch (e) {
      if (mounted) miniPosMessage(context, e);
      setState(() => _busy = false);
    }
  }

  Future<void> _verify(String _) async {
    final id = _internalOrderId;
    if (id == null) return;
    try {
      final result = await _api.get('minipos/payments/$id/status');
      if (!mounted) return;
      if (result['paid'] == true)
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => MiniPosOrderDetailPage(
                    orderId: id, paymentCompleted: true)));
      else
        miniPosMessage(context,
            'Payment is ${result['payment_status']}. You can safely check again from MiniPOS orders.');
    } catch (e) {
      if (mounted)
        miniPosMessage(context,
            'Payment verification is pending. Check MiniPOS orders before paying again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _failed(CFErrorResponse error, String _) {
    if (mounted) {
      setState(() => _busy = false);
      miniPosMessage(
          context, error.getMessage() ?? 'Cashfree payment was not completed.');
    }
  }

  @override
  Widget build(BuildContext context) => MiniPosScaffold(
      appBar: AppBar(title: const Text('Customer checkout')),
      body: Form(
          key: _form,
          child: ListView(padding: const EdgeInsets.all(16), children: [
            Text('Order total: ${miniPosMoney(widget.total)}',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            const Text(
                'Cashfree checkout will show eligible card EMI and payment options.',
                style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 20),
            _field(_name, 'Customer name', validator: _required),
            _field(_phone, 'Phone number',
                keyboard: TextInputType.phone,
                validator: (v) => RegExp(r'^\+?[6-9]\d{9}$')
                        .hasMatch((v ?? '').replaceAll(' ', ''))
                    ? null
                    : 'Enter a valid Indian phone number'),
            _field(_email, 'Email (optional)',
                keyboard: TextInputType.emailAddress,
                validator: (v) => (v ?? '').trim().isEmpty ||
                        RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(v!.trim())
                    ? null
                    : 'Enter a valid email'),
            _field(_address1, 'Address', validator: _required),
            _field(_address2, 'Address line 2 (optional)'),
            Row(children: [
              Expanded(child: _field(_city, 'City', validator: _required)),
              const SizedBox(width: 12),
              Expanded(child: _field(_state, 'State', validator: _required))
            ]),
            _field(_pincode, 'Pincode',
                keyboard: TextInputType.number,
                validator: (v) => RegExp(r'^[1-9]\d{5}$').hasMatch(v ?? '')
                    ? null
                    : 'Enter a valid pincode'),
            const SizedBox(height: 12),
            FilledButton(
                onPressed: _busy ? null : _checkout,
                child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(_busy
                        ? 'Please wait…'
                        : 'Pay ${miniPosMoney(widget.total)}')))
          ])));
  Widget _field(TextEditingController controller, String label,
          {TextInputType? keyboard, String? Function(String?)? validator}) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: TextFormField(
              controller: controller,
              keyboardType: keyboard,
              validator: validator,
              textCapitalization: keyboard == TextInputType.emailAddress
                  ? TextCapitalization.none
                  : TextCapitalization.words,
              decoration: InputDecoration(
                  labelText: label, border: const OutlineInputBorder())));
}
