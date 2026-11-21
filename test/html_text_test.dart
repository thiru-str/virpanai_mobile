import 'package:flutter_test/flutter_test.dart';
import 'package:waioz/utility/html_text.dart';

void main() {
  test('product description HTML becomes card text', () {
    const html =
        "<p>Ever wanted to throw a bottle just because? Here's your moment.</p>\n<p>This Rage Room experience&nbsp;is designed for one.</p>";
    expect(htmlToPlainText(html),
        "Ever wanted to throw a bottle just because? Here's your moment. This Rage Room experience is designed for one.");
  });
  test('entities, breaks and empty input', () {
    expect(htmlToPlainText('Tea &amp; cake<br/>for two &#8377;999'),
        'Tea & cake for two ₹999');
    expect(htmlToPlainText(null), '');
    expect(htmlToPlainText('<p> </p>'), '');
    expect(htmlToPlainText('Plain text stays'), 'Plain text stays');
  });
}
