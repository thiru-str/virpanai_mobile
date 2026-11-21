/// Product descriptions are stored as HTML (the web renders them as such).
/// Cards show a one- or two-line teaser, so they need the words without the
/// markup: tags dropped, paragraphs and line breaks turned into spaces, the
/// common entities decoded and whitespace collapsed.
String htmlToPlainText(String? html) {
  if (html == null || html.isEmpty) return '';
  var s = html
      .replaceAll(
          RegExp(r'<\s*(script|style)[^>]*>[\s\S]*?<\s*/\s*\1\s*>',
              caseSensitive: false),
          ' ')
      .replaceAll(RegExp(r'<\s*br\s*/?\s*>', caseSensitive: false), ' ')
      .replaceAll(
          RegExp(r'</\s*(p|div|li|h[1-6])\s*>', caseSensitive: false), ' ')
      .replaceAll(RegExp(r'<[^>]*>'), '');
  const entities = {
    '&nbsp;': ' ',
    '&amp;': '&',
    '&quot;': '"',
    '&#39;': "'",
    '&apos;': "'",
    '&lt;': '<',
    '&gt;': '>',
    '&rsquo;': '’',
    '&lsquo;': '‘',
    '&rdquo;': '”',
    '&ldquo;': '“',
    '&hellip;': '…',
    '&ndash;': '–',
    '&mdash;': '—',
    '&rupee;': '₹',
  };
  entities.forEach((k, v) => s = s.replaceAll(k, v));
  s = s.replaceAllMapped(RegExp(r'&#(x?)([0-9a-fA-F]+);'), (m) {
    final code = int.tryParse(m[2]!, radix: m[1]!.isEmpty ? 10 : 16);
    return code == null ? m[0]! : String.fromCharCode(code);
  });
  return s.replaceAll(RegExp(r'\s+'), ' ').trim();
}
