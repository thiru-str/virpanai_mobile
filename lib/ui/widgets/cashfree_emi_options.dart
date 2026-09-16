import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/ui/cashfree_plans_page.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_config.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CashfreeEmiOptions extends StatefulWidget {
  final num amount;
  final String placement;
  const CashfreeEmiOptions({
    super.key,
    required this.amount,
    this.placement = 'pdp',
  });

  @override
  State<CashfreeEmiOptions> createState() => _CashfreeEmiOptionsState();
}

class _CashfreeEmiOptionsState extends State<CashfreeEmiOptions> {
  Future<Map<String, dynamic>>? _emiOptions;
  late Future<Map<String, dynamic>> _bnplConfig;

  @override
  void initState() {
    super.initState();
    _bnplConfig = widget.placement == 'checkout'
        ? Future.value({'enabled': false})
        : ApiService().getCashfreeBnplConfig();
  }

  @override
  void didUpdateWidget(covariant CashfreeEmiOptions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amount != widget.amount) {
      _emiOptions = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.amount <= 0) return const SizedBox.shrink();
    Widget content;
    if (widget.placement != 'checkout') {
      content = FutureBuilder<Map<String, dynamic>>(
        future: _bnplConfig,
        builder: (context, snapshot) {
          final config = snapshot.data;
          final clientId = config?['client_id']?.toString();
          if (config?['enabled'] == true &&
              config?['environment'] == 'production' &&
              clientId != null &&
              clientId.isNotEmpty) {
            return _CashfreeBnplWebWidget(
              key: ValueKey('$clientId:${widget.amount}'),
              clientId: clientId,
              amount: widget.amount,
              fallbackBuilder: _buildEligibilityList,
            );
          }
          return _buildEligibilityList();
        },
      );
    } else {
      content = _buildEligibilityList();
    }
    return widget.placement == 'cart'
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: content,
          )
        : content;
  }

  Widget _buildEligibilityList() {
    _emiOptions ??= ApiService().getCashfreeEmiOptions(widget.amount);
    return FutureBuilder<Map<String, dynamic>>(
      future: _emiOptions,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final options = data?['options'] as List? ?? [];
        if (data?['enabled'] != true || options.isEmpty)
          return const SizedBox.shrink();
        final rows = <String>[];
        for (final option in options) {
          final details = option is Map ? option['entity_details'] : null;
          final plans = details is Map
              ? (details['emi_plans'] ?? details['payment_method_details'])
                      as List? ??
                  []
              : <dynamic>[];
          for (final plan in plans) {
            if (plan is Map) {
              final name = plan['display'] ??
                  plan['bank_name'] ??
                  option['entity_value'] ??
                  'Eligible bank';
              final tenure = plan['tenure'];
              final interest = plan['interest_rate'];
              rows.add(
                  '$name${tenure != null ? ' · $tenure months' : ''}${interest != null ? ' · $interest% p.a.' : ''}');
            }
          }
        }
        if (rows.isEmpty) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: .06),
              borderRadius: BorderRadius.circular(10)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('EMI options available with Cashfree',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            ...rows.map((row) => Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(row, style: const TextStyle(fontSize: 12)))),
          ]),
        );
      },
    );
  }
}

/// Cashfree publishes BNPL Plus for native web, not a dedicated Flutter SDK.
/// Render that public-ID-only widget in the app's existing WebView stack.
/// Checkout payments still use the Cashfree Flutter payment SDK separately.
class _CashfreeBnplWebWidget extends StatefulWidget {
  final String clientId;
  final num amount;
  final Widget Function() fallbackBuilder;

  const _CashfreeBnplWebWidget({
    super.key,
    required this.clientId,
    required this.amount,
    required this.fallbackBuilder,
  });

  @override
  State<_CashfreeBnplWebWidget> createState() => _CashfreeBnplWebWidgetState();
}

class _CashfreeBnplWebWidgetState extends State<_CashfreeBnplWebWidget> {
  late final WebViewController _controller;
  double _height = 140;
  bool _failed = false;
  bool _openingPlans = false;

  Future<void> _openPlans(String tab) async {
    if (!mounted || _openingPlans) return;
    _openingPlans = true;
    try {
      await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute<void>(
          builder: (_) => CashfreePlansPage(
            amount: widget.amount,
            initialTab: tab,
          ),
        ),
      );
    } finally {
      _openingPlans = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        'CashfreeBnplHeight',
        onMessageReceived: (message) {
          final height = double.tryParse(message.message);
          if (height != null && mounted) {
            final nextHeight = height.clamp(100.0, 640.0);
            if ((_height - nextHeight).abs() > 3) {
              setState(() => _height = nextHeight);
            }
          }
        },
      )
      ..addJavaScriptChannel(
        'CashfreeBnplStatus',
        onMessageReceived: (message) {
          if (message.message == 'failed' && mounted) {
            setState(() => _failed = true);
          }
        },
      )
      ..addJavaScriptChannel(
        'CashfreeBnplModal',
        onMessageReceived: (message) {
          _openPlans(message.message);
        },
      )
      ..loadHtmlString(_html(), baseUrl: AppConfig.baseUrl);
  }

  String _html() {
    // jsonEncode escapes the public App ID and amount for JavaScript. No
    // Cashfree secret or webhook credential is ever sent to this WebView.
    final clientId = jsonEncode(widget.clientId);
    final amount = jsonEncode(widget.amount.toString());
    return '''<!doctype html>
<html><head><meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>html,body{margin:0;padding:0;background:transparent;overflow:auto}
#cashfree-widget{width:100%;min-height:100px}
#cashfree-widget iframe{width:100%}</style>
<script src="https://sdk.cashfree.com/js/widget/1.0.2/cashfree-widget.prod.js"></script>
</head><body><div id="cashfree-widget"></div><script>
(function(){
  window.addEventListener('message', function(event) {
    if (event.origin !== 'https://cf-widget-frame.cashfree.com') return;
    if (event.data && event.data.isModelOpen) {
      // Keep Cashfree's compact preview, but show its read-only offers and EMI
      // data in a native screen. Its web-only detail iframe adds a dim backdrop.
      event.stopImmediatePropagation();
      CashfreeBnplModal.postMessage(String(event.data.opentab || 'offerDetails'));
    }
  }, true);
  var lastHeight = 0;
  function reportHeight(){
    var h = Math.ceil(Math.max(document.body.scrollHeight,
      document.getElementById('cashfree-widget').scrollHeight));
    if (h > 0 && Math.abs(h - lastHeight) > 3) {
      lastHeight = h;
      CashfreeBnplHeight.postMessage(String(h));
    }
  }
  window.addEventListener('load', function(){
    if (typeof CF_Widget !== 'function') {
      CashfreeBnplStatus.postMessage('failed');
      return;
    }
    try {
      CF_Widget({clientID:$clientId, amount:$amount,
        offers:'true', payLater:'true', emi:'true',
        theme:{widgetColor:'#ffffff',linkColor:'#5b21b6',
          cfLogoTheme:'dark',isLogoActive:true}}).load();
      if (typeof ResizeObserver === 'function') {
        new ResizeObserver(reportHeight).observe(document.body);
      }
      if (typeof MutationObserver === 'function') {
        new MutationObserver(reportHeight).observe(document.body,
          {childList:true,subtree:true,attributes:true});
      }
      reportHeight();
      setTimeout(function(){
        if (!document.getElementById('cashfree-widget').hasChildNodes()) {
          CashfreeBnplStatus.postMessage('failed');
        }
      }, 15000);
    } catch (e) {
      CashfreeBnplStatus.postMessage('failed');
    }
  });
})();
</script></body></html>''';
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) return widget.fallbackBuilder();
    return Container(
      margin: const EdgeInsets.only(top: 12),
      height: _height,
      child: WebViewWidget(controller: _controller),
    );
  }
}
