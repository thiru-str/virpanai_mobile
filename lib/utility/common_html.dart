import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:waioz/utility/font_utils.dart';

class CommonHtmlWidget extends StatelessWidget {
  final String htmlContent;

  // Constructor to accept the HTML content
  const CommonHtmlWidget({
    super.key,
    required this.htmlContent,
  });

  // Function to clean the HTML by removing inline styles
  String cleanHtml(String content) {
    final RegExp styleRegExp = RegExp(r'style="[^"]*"');
    return content.replaceAll(styleRegExp, '');
  }

  @override
  Widget build(BuildContext context) {
    return Html(
      data: cleanHtml(htmlContent),
      style: {
        "img": Style(
          display: Display.block, // Ensures it behaves as a block element
          alignment: Alignment.center,
          width: Width(250, Unit.percent), // Optional: Adjust size
        ),
        "body": Style(
          color: Colors.black, // Default text color to white
          fontSize: FontSize(15),
          fontFamily: FontUtils.defaultFont,
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
          fontFamily: FontUtils.defaultFont,
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