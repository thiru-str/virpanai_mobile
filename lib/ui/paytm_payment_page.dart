import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:waioz/model/shipping_response.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaytmPaymentPage extends StatefulWidget {
  final Data data;
  final VoidCallback onSuccess;
  final void Function(String message) onFailure;

  const PaytmPaymentPage({
    super.key,
    required this.data,
    required this.onSuccess,
    required this.onFailure,
  });

  @override
  State<PaytmPaymentPage> createState() => _PaytmPaymentPageState();
}

class _PaytmPaymentPageState extends State<PaytmPaymentPage> {
  static const _upiChannel = MethodChannel('com.waioz.cartel/upi');

  late final WebViewController _controller;
  bool _loading = true;
  bool _done = false;
  bool _checkoutOpened = false;
  bool _showingExitPrompt = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'PaytmCallback',
        onMessageReceived: (message) => _handleMessage(message.message),
      )
      ..addJavaScriptChannel(
        'PaytmUpiIntentBridge',
        onMessageReceived: (message) => _openUpiApp(message.message),
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!_checkoutOpened) {
              setState(() => _loading = true);
            }
          },
          onPageFinished: (_) {
            if (_checkoutOpened) {
              setState(() => _loading = false);
            }
          },
          onNavigationRequest: (request) async {
            final url = request.url;

            if (url.contains('/order/confirmed/')) {
              _done = true;
              widget.onSuccess();
              return NavigationDecision.prevent;
            }

            if (url.contains('/order/transaction/failed/')) {
              _done = true;
              widget.onFailure(_failureMessageFromUrl(url));
              return NavigationDecision.prevent;
            }

            if (_isUpiIntentUrl(url)) {
              await _openUpiApp(url);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      );

    _loadCheckout();
  }

  static const _upiSchemes = {'upi', 'tez', 'phonepe', 'paytmmp', 'gpay'};

  static const _upiAvailabilityUris = {
    'upi': 'upi://pay',
    'tez': 'tez://upi/pay',
    'phonepe': 'phonepe://pay',
    'paytmmp': 'paytmmp://pay',
    'gpay': 'gpay://upi/pay',
  };

  bool _isUpiIntentUrl(String url) {
    final scheme = Uri.tryParse(url)?.scheme.toLowerCase();
    return scheme == 'intent' || _upiSchemes.contains(scheme);
  }

  Future<void> _loadCheckout() async {
    final supportedSchemes = <String>{};

    for (final entry in _upiAvailabilityUris.entries) {
      try {
        if (await canLaunchUrl(Uri.parse(entry.value))) {
          supportedSchemes.add(entry.key);
        }
      } catch (_) {
        // An unavailable app is reported to Paytm by omitting its scheme.
      }
    }

    if (!mounted) return;
    await _controller.loadHtmlString(
      _html(supportedUpiSchemes: supportedSchemes),
    );
  }

  Uri? _upiUri(String rawUrl) {
    final uri = Uri.tryParse(rawUrl);
    if (uri == null) return null;

    final scheme = uri.scheme.toLowerCase();
    if (_upiSchemes.contains(scheme)) return uri;

    // Android intent URLs commonly wrap a normal UPI URL as:
    // intent://pay?...#Intent;scheme=upi;package=...;end
    if (scheme == 'intent') {
      final marker = rawUrl.indexOf('#Intent;');
      if (marker == -1) return null;

      final intentMetadata = rawUrl.substring(marker + '#Intent;'.length);
      final declaredScheme = RegExp(
        r'(?:^|;)scheme=([^;]+)',
      ).firstMatch(intentMetadata)?.group(1)?.toLowerCase();
      if (declaredScheme == null || !_upiSchemes.contains(declaredScheme)) {
        return null;
      }

      final intentTarget = rawUrl.substring('intent://'.length, marker);
      return Uri.tryParse('$declaredScheme://$intentTarget');
    }

    return null;
  }

  Future<void> _openUpiApp(String rawUrl) async {
    final uri = _upiUri(rawUrl);
    if (uri == null) return;

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final result = await _upiChannel.invokeMapMethod<String, dynamic>(
          'launchUpi',
          {'url': uri.toString()},
        );

        if (!mounted || _done || result?['launched'] != true) return;
        return;
      }

      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Keep Paytm checkout available when no UPI app can handle the intent.
    }
  }

  void _handleMessage(String message) {
    if (_done) return;

    final payload = jsonDecode(message);
    final event = payload['event']?.toString();
    final data = payload['data'];
    final status = data is Map
        ? (data['STATUS'] ??
              data['status'] ??
              (data['resultInfo'] is Map
                  ? data['resultInfo']['resultStatus']
                  : null))
        : null;

    if (event == 'checkoutReady') {
      setState(() {
        _checkoutOpened = true;
        _loading = false;
      });
      return;
    }

    final normalizedStatus = status?.toString().toUpperCase();
    if (event == 'transactionStatus' &&
        ['TXN_SUCCESS', 'SUCCESS'].contains(normalizedStatus)) {
      _done = true;
      widget.onSuccess();
      return;
    }

    if (event == 'transactionStatus' && normalizedStatus == 'PENDING') {
      return;
    }

    final eventName = payload['eventName']?.toString();
    if (event == 'notifyMerchant' &&
        [
          'APP_CLOSED',
          'SESSION_EXPIRED',
          'PAYTM_EXPIRY',
          'TXN_ABORT',
          'TXN_FAILURE',
        ].contains(eventName)) {
      _done = true;
      widget.onFailure(_notifyMessage(eventName));
      return;
    }

    if (event == 'transactionStatus') {
      _done = true;
      final resultInfo = data is Map ? data['resultInfo'] : null;
      widget.onFailure(
        (data is Map
                    ? (data['RESPMSG'] ??
                          (resultInfo is Map ? resultInfo['resultMsg'] : null))
                    : null)
                ?.toString() ??
            'Paytm payment was not completed.',
      );
    }
  }

  Future<void> _handleBackPressed() async {
    if (_done || _showingExitPrompt) return;

    _showingExitPrompt = true;
    final shouldSkip = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Are you sure you want to exit?'),
          content: const Text('You will be taken back to the previous screen'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Continue to payment'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Yes, exit'),
            ),
          ],
        );
      },
    );
    _showingExitPrompt = false;

    if (!mounted || shouldSkip != true || _done) return;

    _done = true;
    widget.onFailure(_notifyMessage('APP_CLOSED'));
  }

  String _failureMessageFromUrl(String url) {
    final uri = Uri.tryParse(url);
    final params = uri?.queryParameters ?? const <String, String>{};
    final message =
        params['message'] ??
        params['error'] ??
        params['error_message'] ??
        params['RESPMSG'];

    return message?.trim().isNotEmpty == true
        ? message!.trim()
        : 'Paytm payment was not completed.';
  }

  String _notifyMessage(String? eventName) {
    switch (eventName) {
      case 'APP_CLOSED':
        return 'Paytm checkout was skipped. You can try again anytime.';
      case 'SESSION_EXPIRED':
      case 'PAYTM_EXPIRY':
        return 'Paytm session expired. Please try again.';
      case 'TXN_ABORT':
        return 'Paytm payment was cancelled.';
      case 'TXN_FAILURE':
        return 'Paytm payment failed. Please try another payment method.';
      default:
        return 'Paytm payment was not completed.';
    }
  }

  String _html({required Set<String> supportedUpiSchemes}) {
    final data = widget.data;
    final token = data.txnToken ?? data.token ?? '';
    final orderId = data.orderId ?? data.id ?? '';
    final scriptUrl =
        '${data.host}/merchantpgpui/checkoutjs/merchants/${data.mid}.js';
    final config = jsonEncode({
      'flow': 'DEFAULT',
      'root': '',
      'data': {
        'orderId': orderId,
        'token': token,
        'tokenType': 'TXN_TOKEN',
        'amount': data.amount?.toString() ?? '',
      },
      'merchant': {'redirect': false},
    });
    final supportedSchemes = jsonEncode({
      for (final scheme in supportedUpiSchemes) scheme: true,
    });
    final upiIntentBridge = supportedUpiSchemes.contains('upi')
        ? '''
  <script>
    // Paytm checks for this Android WebView interface before enabling UPI
    // intent. The Flutter channel opens the supplied UPI URL outside WebView,
    // allowing Android to show all installed UPI apps.
    var supportedUpiSchemes = $supportedSchemes;
    window.checkoutUpiIntent = {
      openUpiApp: function(url) {
        try {
          if (!url || !window.PaytmUpiIntentBridge) {
            return false;
          }
          var value = String(url);
          var separator = value.indexOf(':');
          var scheme = separator > 0
            ? value.substring(0, separator).toLowerCase()
            : '';
          if (!supportedUpiSchemes[scheme]) {
            return false;
          }
          PaytmUpiIntentBridge.postMessage(value);
          return true;
        } catch (error) {
          return false;
        }
      }
    };
  </script>
'''
        : '';

    return '''
<!doctype html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    html, body {
      margin: 0;
      height: 100%;
      width: 100%;
      overflow: hidden;
      overscroll-behavior: none;
      background: #fff;
      position: fixed;
      inset: 0;
    }
  </style>
$upiIntentBridge
  <script src="$scriptUrl"></script>
</head>
<body>
  <script>
    function post(event, data, eventName) {
      PaytmCallback.postMessage(JSON.stringify({ event: event, data: data || {}, eventName: eventName || '' }));
    }

    function lockScroll() {
      document.documentElement.style.overflow = 'hidden';
      document.documentElement.style.height = '100%';
      document.documentElement.style.position = 'fixed';
      document.documentElement.style.inset = '0';
      document.body.style.overflow = 'hidden';
      document.body.style.height = '100%';
      document.body.style.position = 'fixed';
      document.body.style.inset = '0';
    }

    document.addEventListener('touchmove', function(event) {
      event.preventDefault();
    }, { passive: false });

    function waitForCheckoutReady(attempt) {
      if (window.Paytm && window.Paytm.CheckoutJS && typeof window.Paytm.CheckoutJS.init === 'function') {
        startPaytm();
        return;
      }

      if (attempt >= 40) {
        post('transactionStatus', { RESPMSG: 'Paytm checkout did not finish loading.' });
        return;
      }

      setTimeout(function() { waitForCheckoutReady(attempt + 1); }, 250);
    }

    function startPaytm() {
      var config = $config;
      config.handler = {
        transactionStatus: function(data) { post('transactionStatus', data); },
        notifyMerchant: function(eventName, data) { post('notifyMerchant', data, eventName); }
      };
      window.Paytm.CheckoutJS.init(config).then(function() {
        lockScroll();
        window.Paytm.CheckoutJS.invoke();
        post('checkoutReady', {});
        setTimeout(lockScroll, 250);
        setTimeout(lockScroll, 750);
        setTimeout(lockScroll, 1500);
      }).catch(function(error) {
        post('transactionStatus', { RESPMSG: error && error.message ? error.message : 'Failed to start Paytm.' });
      });
    }

    window.onload = function() {
      lockScroll();
      waitForCheckoutReady(0);
    };
  </script>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _result) {
        if (!didPop) {
          _handleBackPressed();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            SafeArea(child: WebViewWidget(controller: _controller)),
            if (_loading)
              Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
          ],
        ),
      ),
    );
  }
}
