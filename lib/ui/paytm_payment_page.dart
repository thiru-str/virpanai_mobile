import 'dart:convert';

import 'package:flutter/material.dart';
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
  late final WebViewController _controller;
  bool _loading = true;
  bool _done = false;
  bool _checkoutOpened = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'PaytmCallback',
        onMessageReceived: (message) => _handleMessage(message.message),
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
          onNavigationRequest: (request) {
            final url = request.url;

            if (url.contains('/order/confirmed/')) {
              _done = true;
              widget.onSuccess();
              return NavigationDecision.prevent;
            }

            if (url.contains('/order/transaction/failed/')) {
              _done = true;
              widget.onFailure('Paytm payment was not completed.');
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadHtmlString(_html());
  }

  void _handleMessage(String message) {
    if (_done) return;

    final payload = jsonDecode(message);
    final event = payload['event']?.toString();
    final data = payload['data'];
    final status = data is Map
        ? (data['STATUS'] ??
            data['status'] ??
            (data['resultInfo'] is Map ? data['resultInfo']['resultStatus'] : null))
        : null;

    if (event == 'checkoutReady') {
      setState(() {
        _checkoutOpened = true;
        _loading = false;
      });
      return;
    }

    if (event == 'transactionStatus' &&
        ['TXN_SUCCESS', 'PENDING', 'success'].contains(status?.toString())) {
      _done = true;
      widget.onSuccess();
      return;
    }

    final eventName = payload['eventName']?.toString();
    if (event == 'notifyMerchant' &&
        ['APP_CLOSED', 'SESSION_EXPIRED', 'PAYTM_EXPIRY', 'TXN_ABORT', 'TXN_FAILURE']
            .contains(eventName)) {
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

  String _html() {
    final data = widget.data;
    final token = data.txnToken ?? data.token ?? '';
    final orderId = data.orderId ?? data.id ?? '';
    final scriptUrl = '${data.host}/merchantpgpui/checkoutjs/merchants/${data.mid}.js';
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: WebViewWidget(controller: _controller),
          ),
          if (_loading)
            Center(child: CircularProgressIndicator(color: AppColors.primary)),
        ],
      ),
    );
  }
}
