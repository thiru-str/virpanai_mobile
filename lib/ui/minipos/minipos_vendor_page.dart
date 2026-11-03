import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:waioz/api/minipos_service.dart';
import 'package:waioz/ui/minipos/minipos_widgets.dart';
import 'package:waioz/utility/app_colors.dart';

/// Only three states are shown: Not connected, Verifying, Connected.
enum _CashfreeState { notConnected, verifying, connected }

_CashfreeState _stateOf(String status) {
  if (status == 'active') return _CashfreeState.connected;
  if (const ['pending_admin', 'submitting', 'processing'].contains(status)) {
    return _CashfreeState.verifying;
  }
  return _CashfreeState.notConnected; // draft, rejected, blocked, none
}

class MiniPosVendorPage extends StatefulWidget {
  const MiniPosVendorPage({super.key});
  @override
  State<MiniPosVendorPage> createState() => _MiniPosVendorPageState();
}

class _MiniPosVendorPageState extends State<MiniPosVendorPage> {
  final _form = GlobalKey<FormState>();
  final _api = MiniPosService.instance;
  final _vendorName = TextEditingController(),
      _vendorEmail = TextEditingController(),
      _vendorPhone = TextEditingController(),
      _holder = TextEditingController(),
      _account = TextEditingController(),
      _ifsc = TextEditingController(),
      _bank = TextEditingController(),
      _pan = TextEditingController(),
      _gst = TextEditingController(),
      _cin = TextEditingController();
  List<String> _businessTypes = [];
  String? _businessType;
  String _accountType = 'BUSINESS';
  Map<String, dynamic>? _vendor;
  bool _loading = true, _saving = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in [
      _vendorName,
      _vendorEmail,
      _vendorPhone,
      _holder,
      _account,
      _ifsc,
      _bank,
      _pan,
      _gst,
      _cin
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _populateVendor(Map<String, dynamic>? vendor,
      [Map<String, dynamic>? customer]) {
    _vendor = vendor;
    final profileName = [customer?['first_name'], customer?['last_name']]
        .map((part) => '${part ?? ''}'.trim())
        .where((part) => part.isNotEmpty)
        .join(' ');
    String contactValue(String key, String profileValue) {
      final saved = '${vendor?[key] ?? ''}'.trim();
      return saved.isNotEmpty ? saved : profileValue;
    }

    String capitalizeName(String value) => value.replaceAllMapped(
        RegExp(r'(^|[\s./&,-])([a-z])'),
        (match) => '${match.group(1)}${match.group(2)!.toUpperCase()}');

    String localPhone(String value) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      return digits.length == 12 && digits.startsWith('91')
          ? digits.substring(2)
          : digits;
    }

    _vendorName.text = contactValue(
        'vendor_name',
        capitalizeName(profileName.isNotEmpty
            ? profileName
            : '${customer?['company_name'] ?? ''}'.trim()));
    _vendorEmail.text =
        contactValue('email', '${customer?['email'] ?? ''}'.trim());
    _vendorPhone.text =
        localPhone(contactValue('phone', '${customer?['phone'] ?? ''}'.trim()));
    _holder.text = '${vendor?['account_holder_name'] ?? ''}';
    _account.text = '${vendor?['account_number'] ?? ''}';
    _ifsc.text = '${vendor?['ifsc'] ?? ''}';
    _bank.text = '${vendor?['bank_name'] ?? ''}';
    _pan.text = '${vendor?['pan'] ?? ''}';
    _gst.text = '${vendor?['gst'] ?? ''}';
    _cin.text = '${vendor?['cin'] ?? ''}';
    final savedBusinessType = vendor?['business_type'];
    _businessType = _businessTypes.contains(savedBusinessType)
        ? savedBusinessType as String
        : vendor == null && _businessTypes.contains('Retail and Shopping')
            ? 'Retail and Shopping'
            : null;
    final savedAccountType = vendor?['account_type'];
    _accountType =
        savedAccountType == 'BUSINESS' || savedAccountType == 'INDIVIDUAL'
            ? savedAccountType as String
            : 'BUSINESS';
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _api.get('minipos/vendor');
      final vendor = data['vendor'] == null
          ? null
          : Map<String, dynamic>.from(data['vendor']);
      Map<String, dynamic>? customer;
      if (vendor == null) {
        try {
          final profile = await _api.get('store/customers/me');
          if (profile['customer'] is Map) {
            customer = Map<String, dynamic>.from(profile['customer']);
          }
        } catch (e) {
          debugPrint('[MiniPOS vendor] Could not prefill contact: $e');
        }
      }
      final businessTypes = List<String>.from(data['business_types'] ?? []);
      if (businessTypes.isEmpty) {
        throw const MiniPosException(
            'Business types could not be loaded. Please try again.');
      }
      if (mounted) {
        setState(() {
          _businessTypes = businessTypes;
          _populateVendor(vendor, customer);
        });
      }
    } catch (e) {
      debugPrint('[MiniPOS vendor] Failed to load vendor: $e');
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final data = await _api.put('minipos/vendor', {
        'vendor_name': _vendorName.text.trim(),
        'email': _vendorEmail.text.trim(),
        'phone': _vendorPhone.text.trim(),
        'account_holder_name': _holder.text.trim(),
        'account_number': _account.text.trim(),
        'ifsc': _ifsc.text.trim(),
        'bank_name': _bank.text.trim(),
        'account_type': _accountType,
        'business_type': _businessType,
        'pan': _pan.text.trim(),
        'gst': _gst.text.trim(),
        'cin': _cin.text.trim()
      });
      if (mounted) {
        final vendor = Map<String, dynamic>.from(data['vendor']);
        setState(() => _populateVendor(vendor));
        final state = _stateOf('${vendor['status'] ?? ''}');
        if (state == _CashfreeState.connected) {
          miniPosMessage(context, 'Vendor connected successfully');
        } else if (state == _CashfreeState.verifying) {
          miniPosMessage(context, 'Vendor details submitted for verification');
        } else {
          miniPosMessage(context,
              '${vendor['admin_note'] ?? 'Vendor details could not be verified. Please review and resubmit.'}');
        }
      }
    } catch (e) {
      if (mounted) miniPosMessage(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _req(String? v) => v == null || v.trim().isEmpty ? 'Required' : null;
  @override
  Widget build(BuildContext context) {
    final status = '${_vendor?['status'] ?? ''}';
    final state = _stateOf(status);
    final verifying = state == _CashfreeState.verifying;
    final connected = state == _CashfreeState.connected;
    // Fields and Connect are locked while Cashfree verifies (or once connected).
    final locked = verifying || connected || status == 'blocked' || _saving;
    final note = '${_vendor?['admin_note'] ?? ''}'.trim();
    return MiniPosScaffold(
        appBar: AppBar(
            title: Text(connected ? 'Vendor details' : 'Connect Vendor'),
            actions: [
              IconButton(
                  tooltip: 'Check status',
                  onPressed: _loading ? null : _load,
                  icon: const Icon(Icons.refresh)),
            ]),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? MiniPosUnavailable(message: _error!, onRetry: _load)
                : Form(
                    key: _form,
                    child:
                        ListView(padding: const EdgeInsets.all(16), children: [
                      if (verifying || connected) ...[
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(
                              color: connected
                                  ? Colors.green.shade50
                                  : Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                  color: connected
                                      ? Colors.green.shade200
                                      : Colors.amber.shade200),
                            ),
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(
                                  connected
                                      ? Icons.verified_rounded
                                      : Icons.hourglass_top_rounded,
                                  size: 20,
                                  color: connected
                                      ? Colors.green.shade700
                                      : Colors.orange.shade800),
                              const SizedBox(width: 7),
                              Text(connected ? 'Connected' : 'Verifying',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: connected
                                          ? Colors.green.shade700
                                          : Colors.orange.shade800)),
                            ]),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ] else if (note.isNotEmpty) ...[
                        // Why the last attempt did not connect.
                        Text(note,
                            style: TextStyle(
                                color: Colors.red.shade700, fontSize: 13)),
                        const SizedBox(height: 16),
                      ],
                      if (connected)
                        _connectedDetails()
                      else ...[
                        const Padding(
                          padding: EdgeInsets.only(bottom: 14),
                          child: Text('Vendor contact',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                        ),
                        _field(
                            _vendorName,
                            'Vendor name',
                            (v) => (v ?? '').trim().length >= 2
                                ? null
                                : 'Enter vendor name',
                            enabled: !locked,
                            capitalization: TextCapitalization.words),
                        _field(
                            _vendorEmail,
                            'Vendor email',
                            (v) => RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                    .hasMatch((v ?? '').trim())
                                ? null
                                : 'Enter a valid email',
                            keyboard: TextInputType.emailAddress,
                            enabled: !locked,
                            validateOnChange: true,
                            capitalization: TextCapitalization.none),
                        _field(
                            _vendorPhone,
                            'Vendor mobile number',
                            (v) => RegExp(r'^[6-9]\d{9}$')
                                    .hasMatch((v ?? '').trim())
                                ? null
                                : 'Enter 10 digits starting with 6, 7, 8 or 9',
                            keyboard: TextInputType.phone,
                            enabled: !locked,
                            validateOnChange: true,
                            prefixText: '+91 ',
                            capitalization: TextCapitalization.none,
                            formatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10)
                            ]),
                        const SizedBox(height: 8),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 14),
                          child: Text('Bank details',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                        ),
                        _field(_holder, 'Account holder name', _req,
                            enabled: !locked),
                        _field(
                            _account,
                            'Bank account number',
                            (v) => RegExp(r'^\d{6,20}$').hasMatch(v ?? '')
                                ? null
                                : 'Enter a valid account number',
                            keyboard: TextInputType.number,
                            enabled: !locked),
                        _field(
                            _ifsc,
                            'IFSC code',
                            (v) => RegExp(r'^[A-Za-z]{4}0[A-Za-z0-9]{6}$')
                                    .hasMatch(v ?? '')
                                ? null
                                : 'Enter a valid IFSC',
                            enabled: !locked),
                        _field(_bank, 'Bank name (optional)', null,
                            enabled: !locked),
                        const SizedBox(height: 8),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 14),
                          child: Text('KYC details',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                        ),
                        _dropdown(
                            'Account type',
                            _accountType,
                            const ['BUSINESS', 'INDIVIDUAL'],
                            (v) => setState(() => _accountType = v!),
                            enabled: !locked),
                        _dropdown(
                            'Business type',
                            _businessType,
                            _businessTypes,
                            (value) => setState(() => _businessType = value),
                            enabled: !locked),
                        _field(
                            _pan,
                            'PAN',
                            (v) => RegExp(r'^[A-Za-z]{5}\d{4}[A-Za-z]$')
                                    .hasMatch(v ?? '')
                                ? null
                                : 'Enter a valid PAN',
                            enabled: !locked),
                        _field(_gst, 'GSTIN (optional)', null,
                            enabled: !locked),
                        _field(_cin, 'CIN (optional)', null, enabled: !locked),
                        FilledButton(
                            onPressed: locked ? null : _save,
                            child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(_saving
                                    ? 'Connecting'
                                    : verifying
                                        ? 'Verifying'
                                        : 'Connect Vendor')))
                      ]
                    ])));
  }

  Widget _connectedDetails() {
    final vendor = _vendor!;
    String shown(dynamic value) {
      final text = '${value ?? ''}'.trim();
      return text.isEmpty ? '-' : text;
    }

    final submitted =
        DateTime.tryParse('${vendor['submitted_at'] ?? ''}')?.toLocal();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _detailsCard('Account details', [
        ('Vendor ID', shown(vendor['cashfree_vendor_id'])),
        ('Vendor name', shown(vendor['vendor_name'])),
        ('Phone', shown(vendor['phone'])),
        ('Email', shown(vendor['email'])),
        (
          'Submitted on',
          submitted == null
              ? '-'
              : DateFormat('dd MMM yyyy, hh:mm a').format(submitted)
        ),
      ]),
      const SizedBox(height: 12),
      _detailsCard('Bank details', [
        ('Account holder', shown(vendor['account_holder_name'])),
        ('Account number', shown(vendor['account_number'])),
        ('IFSC', shown(vendor['ifsc'])),
        ('Bank name', shown(vendor['bank_name'])),
      ]),
      const SizedBox(height: 12),
      _detailsCard('KYC details', [
        ('Account type', shown(vendor['account_type'])),
        ('Business type', shown(vendor['business_type'])),
        ('PAN', shown(vendor['pan'])),
        ('GSTIN', shown(vendor['gst'])),
        ('CIN', shown(vendor['cin'])),
      ]),
      const SizedBox(height: 12),
      const Text('To change these details, contact Gowelmart support.',
          style: TextStyle(fontSize: 12, color: Colors.black54)),
    ]);
  }

  Widget _detailsCard(String title, List<(String, String)> details) =>
      Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary),
        ),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EC)),
          for (var index = 0; index < details.length; index++) ...[
            if (index > 0)
              const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EC)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                    flex: 2,
                    child: Text(details[index].$1,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black54))),
                const SizedBox(width: 12),
                Expanded(
                    flex: 3,
                    child: Text(details[index].$2,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600))),
              ]),
            ),
          ],
        ]),
      );

  Widget _field(TextEditingController c, String label,
          String? Function(String?)? validator,
          {TextInputType? keyboard,
          bool enabled = true,
          bool validateOnChange = false,
          String? prefixText,
          TextCapitalization capitalization = TextCapitalization.characters,
          List<TextInputFormatter>? formatters}) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: TextFormField(
              controller: c,
              enabled: enabled,
              validator: validator,
              autovalidateMode: validateOnChange
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              keyboardType: keyboard,
              textCapitalization: capitalization,
              inputFormatters: formatters,
              decoration: InputDecoration(
                  labelText: label,
                  prefixText: prefixText,
                  border: const OutlineInputBorder())));
  Widget _dropdown(String label, String? value, List<String> items,
          ValueChanged<String?> changed, {bool enabled = true}) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: DropdownButtonFormField<String>(
              initialValue: value,
              isExpanded: true,
              validator: _req,
              decoration: InputDecoration(
                  labelText: label, border: const OutlineInputBorder()),
              items: items
                  .map((v) => DropdownMenuItem(
                      value: v,
                      child: Text(v.replaceAll('_', ' '),
                          maxLines: 1, overflow: TextOverflow.ellipsis)))
                  .toList(),
              onChanged: enabled ? changed : null));
}
