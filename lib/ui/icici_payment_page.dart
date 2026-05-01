import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Opens ICICI's hosted payment page in a WebView.
///
/// After payment, ICICI posts back to /icici/callback which redirects to:
///   Success: <storefrontUrl>/order/confirmed/<orderId>
///   Failure: <storefrontUrl>/order/transaction/failed/<txnId>
///
/// We intercept those URL patterns regardless of domain and call the
/// appropriate callback so the app can navigate natively.
class IciciPaymentPage extends StatefulWidget {
  final String redirectUrl;
  final void Function(String orderId) onSuccess;
  final void Function() onFailure;

  const IciciPaymentPage({
    super.key,
    required this.redirectUrl,
    required this.onSuccess,
    required this.onFailure,
  });

  @override
  State<IciciPaymentPage> createState() => _IciciPaymentPageState();
}

class _IciciPaymentPageState extends State<IciciPaymentPage> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _loading = true),
          onPageFinished: (_) => setState(() => _loading = false),
          onNavigationRequest: (request) {
            final url = request.url;

            if (url.contains('/order/confirmed/')) {
              // Extract order ID — last path segment after /order/confirmed/
              final orderId = Uri.parse(url).pathSegments.last;
              widget.onSuccess(orderId);
              return NavigationDecision.prevent;
            }

            if (url.contains('/order/transaction/failed/')) {
              widget.onFailure();
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.redirectUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay with ICICI Bank'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            widget.onFailure();
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
