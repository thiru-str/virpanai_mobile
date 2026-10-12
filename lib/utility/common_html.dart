import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

String _cleanHtml(String content) {
  final RegExp styleRegExp = RegExp(r'style="[^"]*"');
  return content.replaceAll(styleRegExp, '');
}

class CommonHtmlWidget extends StatefulWidget {
  final String htmlContent;

  const CommonHtmlWidget({
    super.key,
    required this.htmlContent,
  });

  @override
  State<CommonHtmlWidget> createState() => _CommonHtmlWidgetState();
}

class _CommonHtmlWidgetState extends State<CommonHtmlWidget> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    // Defer heavy HTML parsing to after the first frame so the page paints
    // immediately without blocking the main thread.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const SizedBox(height: 60);
    return Html(
      data: _cleanHtml(widget.htmlContent),
      style: {
        "img": Style(
          display: Display.block, // Ensures it behaves as a block element
          alignment: Alignment.center,
          width: Width(250, Unit.percent), // Optional: Adjust size
        ),
        "body": Style(
          color: Colors.black, // Default text color to white
        ),
        "div": Style(
          margin: Margins.all(0),
          color: Colors.black,
        ),
        "span": Style(
          fontSize: FontSize(14),
          color: Colors.black,
        ),
        "p": Style(
          fontSize: FontSize(14),
          color: Colors.black,
        ),
        "a": Style(
          textDecoration: TextDecoration.underline
        ),
      },
      onLinkTap: (String? url, Map<String, String> attributes, _) {
        if (url != null && url.startsWith('mailto:')) {
          // Use Gmail web URL to open in browser/Gmail app
          _launchEmailWithFallback(url.replaceFirst('mailto:', ''));
        } else if (url != null) {
          _launchUrl(url);
        }
      },
      /*extensions: const [
        TableHtmlExtension(), // Enables table rendering support
      ]*/
    );
  }
}

void _launchUrl(String urlString) async {
  final Uri url = Uri.parse(urlString);
  if (await canLaunchUrl(url)) {
    await launchUrl(
      url,
      mode: LaunchMode.externalApplication, // Opens the URL in the default browser.
    );
  } else {
    throw 'Could not launch $urlString';
  }
}

void _launchEmailWithFallback(String email) async {
  final Uri gmailUri = Uri(
    scheme: 'https',
    host: 'mail.google.com',
    path: '/mail/',
    queryParameters: {
      'view': 'cm',
      'fs': '1',
      'to': email,
    },
  );

  if (await canLaunchUrl(gmailUri)) {
    await launchUrl(gmailUri, mode: LaunchMode.externalApplication); // Opens in browser or Gmail app
  } else {
    print("Could not open Gmail web interface.");
  }
}