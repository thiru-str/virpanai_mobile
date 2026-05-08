import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:url_launcher/url_launcher.dart';

class CommonHtmlWidget extends StatelessWidget {
  final String htmlContent;

  // Constructor to accept the HTML content
  const CommonHtmlWidget({
    super.key,
    required this.htmlContent,
  });

  String _normalizeHtml(String content) {
    var normalized = content.trim();

    // `flutter_html_table` does not handle colgroup/col sizing the same way a
    // browser does, so we drop those hints and let the table use the full width.
    normalized = normalized.replaceAll(
      RegExp(r'<colgroup[\s\S]*?</colgroup>', caseSensitive: false),
      '',
    );
    normalized = normalized.replaceAll(
      RegExp(r'\swidth="[^"]*"', caseSensitive: false),
      '',
    );
    normalized = normalized.replaceAll(
      RegExp(r'\scolwidth="[^"]*"', caseSensitive: false),
      '',
    );

    return normalized;
  }

  List<_HtmlSegment> _buildSegments(String content) {
    final document = html_parser.parseFragment(content);
    final segments = <_HtmlSegment>[];
    final buffer = StringBuffer();

    void flushBuffer() {
      final value = buffer.toString().trim();
      if (value.isNotEmpty) {
        segments.add(_HtmlSegment.html(value));
      }
      buffer.clear();
    }

    for (final node in document.nodes) {
      if (node is dom.Element && node.localName?.toLowerCase() == 'table') {
        flushBuffer();
        segments.add(_HtmlSegment.table(node.outerHtml));
      } else {
        buffer.write(node.toString());
      }
    }

    flushBuffer();
    return segments;
  }

  Widget _buildNativeTable(String tableHtml) {
    final document = html_parser.parseFragment(tableHtml);
    final table = document.querySelector('table');
    if (table == null) {
      return const SizedBox();
    }

    final rows = table.querySelectorAll('tr');
    if (rows.isEmpty) {
      return const SizedBox();
    }

    final tableRows = <TableRow>[];

    for (final row in rows) {
      final cells = row.children
          .where((child) =>
              child.localName == 'th' || child.localName == 'td')
          .toList();

      if (cells.isEmpty) {
        continue;
      }

      final isHeaderRow = cells.any((cell) => cell.localName == 'th');
      final normalizedCells = List<dom.Element>.from(cells);
      while (normalizedCells.length < 2) {
        normalizedCells.add(dom.Element.tag('td'));
      }

      tableRows.add(
        TableRow(
          decoration: BoxDecoration(
            color: isHeaderRow ? const Color(0xFFF2F2F2) : Colors.white,
          ),
          children: normalizedCells.take(2).map((cell) {
            final text = cell.text.trim();
            final isSectionLabel = !isHeaderRow &&
                normalizedCells[1].text.trim().isEmpty &&
                text.isNotEmpty;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color: Colors.black87,
                  fontWeight: isHeaderRow || isSectionLabel
                      ? FontWeight.w700
                      : FontWeight.w400,
                ),
              ),
            );
          }).toList(),
        ),
      );
    }

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(0.46),
        1: FlexColumnWidth(0.54),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: tableRows,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cleanedHtml = _normalizeHtml(htmlContent);
    final segments = _buildSegments(cleanedHtml);

    if (segments.any((segment) => segment.isTable)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final segment in segments) ...[
            if (segment.isTable)
              _buildNativeTable(segment.content)
            else
              Html(
                data: segment.content,
                shrinkWrap: true,
                style: {
                  "html": Style(
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                  ),
                  "body": Style(
                    color: Colors.black,
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                  ),
                  "p": Style(
                    fontSize: FontSize(14),
                    color: Colors.black,
                    lineHeight: const LineHeight(1.5),
                  ),
                },
                onLinkTap: (String? url, Map<String, String> attributes, _) {
                  if (url != null && url.startsWith('mailto:')) {
                    _launchEmailWithFallback(url.replaceFirst('mailto:', ''));
                  } else if (url != null) {
                    _launchUrl(url);
                  }
                },
              ),
            const SizedBox(height: 8),
          ],
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        final htmlWidget = Html(
          data: cleanedHtml,
          shrinkWrap: false,
          style: {
            "html": Style(
              width: Width(availableWidth, Unit.px),
              margin: Margins.zero,
              padding: HtmlPaddings.zero,
            ),
            "img": Style(
              display: Display.block,
              alignment: Alignment.center,
              width: Width(100, Unit.percent),
              margin: Margins.symmetric(vertical: 8),
            ),
            "body": Style(
              color: Colors.black,
              margin: Margins.zero,
              padding: HtmlPaddings.zero,
            ),
            "div": Style(
              margin: Margins.zero,
              color: Colors.black,
            ),
            "span": Style(
              fontSize: FontSize(14),
              color: Colors.black,
            ),
            "p": Style(
              fontSize: FontSize(14),
              color: Colors.black,
              lineHeight: const LineHeight(1.5),
            ),
            "a": Style(textDecoration: TextDecoration.underline),
            "ul": Style(
              margin: Margins.only(left: 18, bottom: 12),
              padding: HtmlPaddings.zero,
            ),
            "ol": Style(
              margin: Margins.only(left: 18, bottom: 12),
              padding: HtmlPaddings.zero,
            ),
            "li": Style(
              fontSize: FontSize(14),
              color: Colors.black,
              lineHeight: const LineHeight(1.5),
            ),
            "table": Style(
              margin: Margins.symmetric(vertical: 8),
              width: Width(availableWidth, Unit.px),
              border: Border.all(color: Colors.black12),
              backgroundColor: Colors.white,
            ),
            "tr": Style(
              border: Border.all(color: Colors.black12),
            ),
            "th": Style(
              padding: HtmlPaddings.all(6),
              backgroundColor: Colors.black12,
              border: Border.all(color: Colors.black12),
              color: Colors.black,
              fontSize: FontSize(12),
            ),
            "td": Style(
              padding: HtmlPaddings.all(6),
              border: Border.all(color: Colors.black12),
              color: Colors.black,
              fontSize: FontSize(12),
            ),
          },
          onLinkTap: (String? url, Map<String, String> attributes, _) {
            if (url != null && url.startsWith('mailto:')) {
              _launchEmailWithFallback(url.replaceFirst('mailto:', ''));
            } else if (url != null) {
              _launchUrl(url);
            }
          },
          extensions: const [
            TableHtmlExtension(),
          ],
        );

        return SizedBox(
          width: availableWidth,
          child: htmlWidget,
        );
      },
    );
  }
}

class _HtmlSegment {
  final String content;
  final bool isTable;

  const _HtmlSegment._({
    required this.content,
    required this.isTable,
  });

  factory _HtmlSegment.html(String content) =>
      _HtmlSegment._(content: content, isTable: false);

  factory _HtmlSegment.table(String content) =>
      _HtmlSegment._(content: content, isTable: true);
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
