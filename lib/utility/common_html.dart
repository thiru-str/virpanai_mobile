import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final Color subtleColor =
        isDark ? const Color(0xFFAAAAAA) : const Color(0xFF666666);
    // flutter_html resolves % against the element's intrinsic size, not the
    // container. Use LayoutBuilder to get the exact available width in px.
    return LayoutBuilder(builder: (context, constraints) {
      final double contentWidth = constraints.maxWidth;
      return Html(
        data: cleanHtml(htmlContent),
        style: {
          "body": Style(
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
            color: textColor,
            fontSize: FontSize(15),
            lineHeight: LineHeight(1.65),
          ),
          "figure": Style(
            display: Display.block,
            margin: Margins.symmetric(vertical: 12),
            width: Width(contentWidth, Unit.px),
          ),
          "img": Style(
            display: Display.block,
            alignment: Alignment.center,
            width: Width(contentWidth, Unit.px),
          ),
          "p": Style(
            color: textColor,
            fontSize: FontSize(15),
            lineHeight: LineHeight(1.65),
            margin: Margins.only(bottom: 10),
          ),
          "div": Style(
            color: textColor,
            margin: Margins.zero,
          ),
          "span": Style(
            color: textColor,
            fontSize: FontSize(15),
          ),
          "h1": Style(
            color: textColor,
            fontSize: FontSize(22),
            fontWeight: FontWeight.bold,
            margin: Margins.only(top: 4, bottom: 8),
          ),
          "h2": Style(
            color: textColor,
            fontSize: FontSize(19),
            fontWeight: FontWeight.bold,
            margin: Margins.only(top: 4, bottom: 6),
          ),
          "h3": Style(
            color: textColor,
            fontSize: FontSize(17),
            fontWeight: FontWeight.w600,
            margin: Margins.only(top: 4, bottom: 6),
          ),
          "ul": Style(
            margin: Margins.only(left: 4, bottom: 10),
            padding: HtmlPaddings.only(left: 16),
          ),
          "ol": Style(
            margin: Margins.only(left: 4, bottom: 10),
            padding: HtmlPaddings.only(left: 16),
          ),
          "li": Style(
            color: textColor,
            fontSize: FontSize(15),
            lineHeight: LineHeight(1.65),
            margin: Margins.only(bottom: 4),
          ),
          "strong": Style(
            color: textColor,
            fontWeight: FontWeight.w700,
          ),
          "em": Style(
            color: textColor,
            fontStyle: FontStyle.italic,
          ),
          "blockquote": Style(
            color: subtleColor,
            fontStyle: FontStyle.italic,
            margin: Margins.symmetric(vertical: 8),
            padding: HtmlPaddings.only(left: 12),
            border: Border(left: BorderSide(color: subtleColor, width: 3)),
          ),
          "a": Style(
            color: const Color(0xFF1B6B3A),
            textDecoration: TextDecoration.underline,
          ),
          "table": Style(
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          "td": Style(
            color: textColor,
            fontSize: FontSize(14),
            padding: HtmlPaddings.all(8),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          "th": Style(
            color: textColor,
            fontSize: FontSize(14),
            fontWeight: FontWeight.w700,
            padding: HtmlPaddings.all(8),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
        },
        onLinkTap: (String? url, Map<String, String> attributes, _) {
          if (url != null && url.startsWith('mailto:')) {
            _launchEmailWithFallback(url.replaceFirst('mailto:', ''));
          } else if (url != null) {
            _launchUrl(url);
          }
        },
      );
    });
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