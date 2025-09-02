import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waioz/ui/widgets/common_header_app_bar.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StaticPage extends StatefulWidget {

  final String pageTitle;
  final String htmlData;

  const StaticPage({Key? key, required this.pageTitle, required this.htmlData})
      : super(key: key);

  @override
  _StaticPageState createState() => _StaticPageState();
}

class _StaticPageState extends State<StaticPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();


    // Get the font family from FontUtils
    String fontFamily = FontUtils.apiPrimaryFont ?? FontUtils.defaultCircularStd;

    // Check if the font is available in Google Fonts
    bool isGoogleFont = GoogleFonts.asMap().containsKey(fontFamily);

    // Generate HTML with the selected font
    String formattedHtml = '''
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=3.0, user-scalable=yes">
        <style>
          ${isGoogleFont ? "@import url('https://fonts.googleapis.com/css2?family=$fontFamily&display=swap');" : ""}
          body {
            font-family: '${isGoogleFont ? fontFamily : FontUtils.defaultCircularStd}', sans-serif;
            padding: 25px;
            margin: 0;
            line-height: 1.6;
          }
          img {
        max-width: 100%;
        height: auto;
        display: block;
        margin: 0 auto;
      }
        </style>
      </head>
      <body>${widget.htmlData}</body>
      </html>
    ''';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(true)
      ..loadHtmlString(formattedHtml); // ✅ Load HTML with the correct font
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