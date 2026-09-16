import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:waioz/api/api_service.dart';

/// Read-only Cashfree merchandising screen. Payment selection and checkout
/// remain with the existing Cashfree payment SDK.
class CashfreePlansPage extends StatefulWidget {
  final num amount;
  final String initialTab;

  const CashfreePlansPage({
    super.key,
    required this.amount,
    required this.initialTab,
  });

  @override
  State<CashfreePlansPage> createState() => _CashfreePlansPageState();
}

class _CashfreePlansPageState extends State<CashfreePlansPage> {
  late Future<Map<String, dynamic>> _options;

  @override
  void initState() {
    super.initState();
    _options = ApiService().getCashfreeDisplayOptions(widget.amount);
  }

  int get _initialIndex {
    if (widget.initialTab == 'emiDetails') return 1;
    if (widget.initialTab == 'payLaterDetails') return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final amount = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    ).format(widget.amount);

    return DefaultTabController(
      length: 3,
      initialIndex: _initialIndex,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FC),
        appBar: AppBar(
          title: const Text('Offers & EMI plans'),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF172033),
          elevation: 0,
          bottom: const TabBar(
            labelColor: Color(0xFF172033),
            unselectedLabelColor: Color(0xFF6B7280),
            indicatorColor: Color(0xFF243C79),
            tabs: [
              Tab(text: 'Offers'),
              Tab(text: 'Card EMI'),
              Tab(text: 'Pay Later'),
            ],
          ),
        ),
        body: FutureBuilder<Map<String, dynamic>>(
          future: _options,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _message(
                'Cashfree options could not be loaded.',
                action: TextButton(
                  onPressed: () => setState(() {
                    _options =
                        ApiService().getCashfreeDisplayOptions(widget.amount);
                  }),
                  child: const Text('Retry'),
                ),
              );
            }
            final data = snapshot.data ?? const <String, dynamic>{};
            if (data['enabled'] != true) {
              return _message('Cashfree offers and EMI plans are unavailable.');
            }
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Text(
                    'Options for $amount · Final eligibility and terms are confirmed at checkout.',
                    style:
                        const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _offersTab(_asList(data['offers'])),
                      _emiTab(_asList(data['emi_options'])),
                      _payLaterTab(_asList(data['paylater_options'])),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _offersTab(List<Map<String, dynamic>> offers) {
    if (offers.isEmpty) {
      return _message('No offers are currently available for this amount.');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: offers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final offer = _asMap(offers[index]['entity_details']).isNotEmpty
            ? _asMap(offers[index]['entity_details'])
            : offers[index];
        final meta = _asMap(offer['offer_meta']);
        final terms = _asMap(offer['offer_tnc']);
        final title = _string(meta['offer_title']) ??
            _string(offer['title']) ??
            'Cashfree offer';
        final description =
            _string(meta['offer_description']) ?? _string(offer['description']);
        final code = _string(meta['offer_code']) ?? _string(offer['code']);
        final tnc = _string(terms['offer_tnc_value']) ??
            (offer['tncType'] == 'text' ? _string(offer['tnc']) : null);
        return Card(
          elevation: 0,
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_offer_outlined,
                        color: Color(0xFF243C79)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                  ],
                ),
                if (description != null) ...[
                  const SizedBox(height: 8),
                  Text(description),
                ],
                if (code != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: SelectableText(
                          'Code: $code',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Copy offer code',
                        icon: const Icon(Icons.copy_outlined, size: 20),
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: code));
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(const SnackBar(
                              content: Text('Offer code copied'),
                              duration: Duration(seconds: 2),
                            ));
                        },
                      ),
                    ],
                  ),
                ],
                if (tnc != null) ...[
                  const SizedBox(height: 8),
                  Text(tnc,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF6B7280))),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _emiTab(List<Map<String, dynamic>> options) {
    final banks = <String, List<Map<String, dynamic>>>{};
    for (final option in options) {
      final details = _asMap(option['entity_details']);
      final plans = _asList(details['emi_plans'] ??
          details['payment_method_details'] ??
          option['schemes']);
      final bankName = _emiBankName(option);
      if (plans.isEmpty) {
        banks.putIfAbsent(bankName, () => []).add(const <String, dynamic>{});
      } else {
        for (final plan in plans) {
          final name = _string(plan['bank_name']) ??
              _string(plan['display']) ??
              bankName;
          banks.putIfAbsent(name, () => []).add(plan);
        }
      }
    }
    if (banks.isEmpty) {
      return _message('No EMI plans are currently available for this amount.');
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: banks.entries.map((bank) {
        return Card(
          elevation: 0,
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ExpansionTile(
            leading: const Icon(Icons.account_balance_outlined,
                color: Color(0xFF243C79)),
            title: Text(bank.key,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            children: bank.value.map((plan) {
              final tenure = _string(plan['tenure'] ?? plan['months']);
              final interest =
                  _string(plan['interest_rate'] ?? plan['interest']);
              final monthly = _string(plan['monthly_emi'] ??
                  plan['emi_amount'] ??
                  plan['emiAmount']);
              final details = <String>[
                if (tenure != null) '$tenure months',
                if (interest != null) '$interest% p.a.',
              ];
              return ListTile(
                title: Text(details.isEmpty
                    ? 'Available at checkout'
                    : details.join(' · ')),
                subtitle: monthly == null
                    ? null
                    : Text(
                        'Monthly EMI: ${monthly.startsWith('₹') ? monthly : '₹$monthly'}'),
                dense: true,
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _payLaterTab(List<Map<String, dynamic>> options) {
    if (options.isEmpty) {
      return _message(
        'Pay Later availability depends on your account and is confirmed at Cashfree checkout.',
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: options.map((option) {
        final details = _asMap(option['entity_details']);
        final methods = _asList(details['payment_method_details']);
        final names = methods
            .map((method) =>
                _string(method['display']) ?? _string(method['nick']))
            .whereType<String>()
            .toList();
        final name = _string(option['display']) ??
            (names.isNotEmpty
                ? names.join(', ')
                : _string(option['entity_value']) ?? 'Pay Later');
        return Card(
          elevation: 0,
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined,
                color: Color(0xFF243C79)),
            title: Text(name),
            subtitle: const Text('Final eligibility is checked at checkout.'),
          ),
        );
      }).toList(),
    );
  }

  Widget _message(String text, {Widget? action}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline, size: 28, color: Color(0xFF8992A3)),
            const SizedBox(height: 12),
            Text(text,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF596273))),
            if (action != null) action,
          ],
        ),
      ),
    );
  }

  static Map<String, dynamic> _asMap(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

  static List<Map<String, dynamic>> _asList(dynamic value) => value is List
      ? value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList()
      : <Map<String, dynamic>>[];

  static String? _string(dynamic value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static String _emiBankName(Map<String, dynamic> option) {
    // Names for the payment codes returned by Cashfree's BNPL Plus preview.
    const paymentCodes = <int, String>{
      6004: 'Axis Credit Card',
      6005: 'Standard Chartered Credit Card',
      6006: 'Yes Credit Card',
      6007: 'ICICI Credit Card',
      6008: 'Kotak Credit Card',
      6009: 'SBI Credit Card',
      6010: 'HDFC Credit Card',
      6011: 'Citi Credit Card',
      6012: 'IndusInd Credit Card',
      6013: 'HSBC Credit Card',
      6014: 'RBL Credit Card',
      6015: 'Bank of Baroda Credit Card',
      6016: 'Amex Credit Card',
      6017: 'AU Credit Card',
      6018: 'Federal Credit Card',
      6050: 'HDFC Cardless EMI',
      6051: 'Federal Cardless EMI',
      6052: 'IDFC Cardless EMI',
      6053: 'Kotak Cardless EMI',
      6054: 'Home Credit Cardless EMI',
      6055: 'ICICI Cardless EMI',
      6056: 'Bank of Baroda Cardless EMI',
      6057: 'CASHe Cardless EMI',
      6061: 'ZestMoney Cardless EMI',
      6062: 'KreditBee Cardless EMI',
      6063: 'Snapmint Cardless EMI',
      11002: 'HDFC Debit Card',
      11003: 'Axis Debit Card',
      11004: 'Kotak Debit Card',
    };
    final paymentCode = int.tryParse(option['paymentCode']?.toString() ?? '');
    return _string(option['display']) ??
        _string(option['name']) ??
        (paymentCode == null ? null : paymentCodes[paymentCode]) ??
        _string(option['bank_name']) ??
        _string(option['nick']) ??
        _string(option['entity_value']) ??
        'EMI option';
  }
}
