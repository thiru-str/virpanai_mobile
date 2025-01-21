import 'package:flutter/material.dart';
import 'package:waioz/ui/widgets/common_header_app_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StaticPage extends StatefulWidget {

  final String pageTitle;
  const StaticPage({Key? key,required this.pageTitle}) : super(key: key);

  @override
  _StaticPageState createState() => _StaticPageState();
}

class _StaticPageState extends State<StaticPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://www.lipsum.com'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:CommonHeaderAppBar(
        title: widget.pageTitle,
        onBackTap: () {
          Navigator.of(context).pop();
        },
      ),
      body: SafeArea(
        child: WebViewWidget(
          controller: _controller,
        ),
      ),
    );
  }
}