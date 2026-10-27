import 'package:flutter/material.dart';
import 'package:waioz/api/minipos_service.dart';
import 'package:waioz/ui/minipos/minipos_widgets.dart';

const _vendorStatuses = {
  'draft': (
    'Draft',
    'Complete your bank and business details to submit for review.'
  ),
  'pending_admin': (
    'Pending',
    'Your details have been submitted and are waiting for admin review.'
  ),
  'submitting': (
    'Review',
    'The administrator is reviewing your details and completing Cashfree onboarding.'
  ),
  'processing': (
    'Review',
    'The administrator will mark your vendor approved once Cashfree approves it.'
  ),
  'active': ('Approved', 'Your vendor account is approved for MiniPOS.'),
  'rejected': (
    'Rejected',
    'Your onboarding was rejected. Review the feedback below before submitting again.'
  ),
  'blocked': (
    'Blocked',
    'Your vendor account is blocked. Contact the administrator for assistance.'
  ),
};

class MiniPosVendorPage extends StatefulWidget {
  const MiniPosVendorPage({super.key});
  @override
  State<MiniPosVendorPage> createState() => _MiniPosVendorPageState();
}

class _MiniPosVendorPageState extends State<MiniPosVendorPage> {
  final _form = GlobalKey<FormState>();
  final _api = MiniPosService.instance;
  final _holder = TextEditingController(),
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
    for (final c in [_holder, _account, _ifsc, _bank, _pan, _gst, _cin]) {
      c.dispose();
    }
    super.dispose();
  }

  void _populateVendor(Map<String, dynamic>? vendor) {
    _vendor = vendor;
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
      final businessTypes = List<String>.from(data['business_types'] ?? []);
      if (businessTypes.isEmpty) {
        throw const MiniPosException(
            'Business types could not be loaded. Please try again.');
      }
      if (mounted) {
        setState(() {
          _businessTypes = businessTypes;
          _populateVendor(data['vendor'] == null
              ? null
              : Map<String, dynamic>.from(data['vendor']));
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
        setState(
            () => _populateVendor(Map<String, dynamic>.from(data['vendor'])));
        miniPosMessage(context, 'Submitted for admin review.');
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
    final active = _vendor?['status'] == 'active';
    final status = '${_vendor?['status'] ?? ''}';
    final statusDetails = _vendorStatuses[status] ??
        ('Status unavailable', 'Refresh to check your onboarding status.');
    final needsAttention = status == 'rejected' || status == 'blocked';
    final note = '${_vendor?['admin_note'] ?? ''}'.trim();
    return MiniPosScaffold(
        appBar: AppBar(title: const Text('Bank & vendor onboarding')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? MiniPosUnavailable(message: _error!, onRetry: _load)
                : Form(
                    key: _form,
                    child:
                        ListView(padding: const EdgeInsets.all(16), children: [
                      if (_vendor != null) ...[
                        Card(
                            color: active
                                ? Colors.green.shade50
                                : needsAttention
                                    ? Colors.red.shade50
                                    : Colors.amber.shade50,
                            child: ListTile(
                                leading: Icon(
                                    active
                                        ? Icons.verified
                                        : needsAttention
                                            ? Icons.error_outline
                                            : Icons.hourglass_top,
                                    color: active
                                        ? Colors.green
                                        : needsAttention
                                            ? Colors.red
                                            : Colors.orange),
                                title: Text('Status: ${statusDetails.$1}'),
                                subtitle: Text(active
                                    ? '${_vendor!['cashfree_vendor_id']}\n${_vendor!['bank_account_masked']} · ${_vendor!['ifsc_masked']}'
                                    : '${statusDetails.$2}${note.isEmpty ? '' : '\nAdmin feedback: $note'}'))),
                        const SizedBox(height: 16),
                      ],
                      if (active)
                        const Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Text(
                                'Approved bank details can only be changed with administrator review.',
                                style: TextStyle(color: Colors.black54)))
                      else ...[
                        _field(_holder, 'Account holder name', _req),
                        _field(
                            _account,
                            'Bank account number',
                            (v) => RegExp(r'^\d{6,20}$').hasMatch(v ?? '')
                                ? null
                                : 'Enter a valid account number',
                            keyboard: TextInputType.number),
                        _field(
                            _ifsc,
                            'IFSC code',
                            (v) => RegExp(r'^[A-Za-z]{4}0[A-Za-z0-9]{6}$')
                                    .hasMatch(v ?? '')
                                ? null
                                : 'Enter a valid IFSC'),
                        _field(_bank, 'Bank name (optional)', null),
                        _dropdown(
                            'KYC account type',
                            _accountType,
                            const ['BUSINESS', 'INDIVIDUAL'],
                            (v) => setState(() => _accountType = v!)),
                        _dropdown(
                            'Business type',
                            _businessType,
                            _businessTypes,
                            (value) => setState(() => _businessType = value)),
                        _field(
                            _pan,
                            'PAN',
                            (v) => RegExp(r'^[A-Za-z]{5}\d{4}[A-Za-z]$')
                                    .hasMatch(v ?? '')
                                ? null
                                : 'Enter a valid PAN'),
                        _field(_gst, 'GSTIN (optional)', null),
                        _field(_cin, 'CIN (optional)', null),
                        FilledButton(
                            onPressed: _saving ? null : _save,
                            child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(_saving
                                    ? 'Submitting…'
                                    : 'Submit for admin review')))
                      ]
                    ])));
  }

  Widget _field(TextEditingController c, String label,
          String? Function(String?)? validator, {TextInputType? keyboard}) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: TextFormField(
              controller: c,
              validator: validator,
              keyboardType: keyboard,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                  labelText: label, border: const OutlineInputBorder())));
  Widget _dropdown(String label, String? value, List<String> items,
          ValueChanged<String?> changed) =>
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
              onChanged: changed));
}
