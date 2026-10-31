import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waioz/utility/store_image.dart';

void main() {
  const cdn = 'cdn.store.com';
  const base = 'https://store.com';
  String? optimised(String url, [int w = 750]) => optimisedImageUrl(url, w, base: base, cdnHost: cdn);

  group('storeImagePixels', () {
    test('snaps up to a width the optimiser accepts', () {
      expect(storeImagePixels(180, null, 3, BoxFit.cover), 640); // 540 px
      expect(storeImagePixels(360, null, 3, BoxFit.contain), 1080);
      expect(storeImagePixels(60, 80, 2, BoxFit.cover), 256);
    });
    test('never asks past the largest width', () {
      expect(storeImagePixels(1200, null, 3, BoxFit.cover), 1920);
    });
    test('a tall cover frame needs its height across, other fits do not', () {
      expect(storeImagePixels(180, 240, 3, BoxFit.cover), 750); // 720 px
      expect(storeImagePixels(180, 240, 3, BoxFit.contain), 640);
    });
    test('ignores an unbounded height', () {
      expect(storeImagePixels(180, double.infinity, 3, BoxFit.cover), 640);
    });
    test('caps the pixel ratio at 3x', () {
      expect(storeImagePixels(180, null, 4, BoxFit.cover), 640);
    });
  });

  group('optimisedImageUrl', () {
    test('builds an optimiser URL for a file on the CDN', () {
      expect(optimised('https://cdn.store.com/a.webp'),
          'https://store.com/_next/image?url=https%3A%2F%2Fcdn.store.com%2Fa.webp&w=750&q=75');
    });
    test('a filename with spaces reaches the optimiser escaped once, either spelling', () {
      const once = 'https://store.com/_next/image?url=https%3A%2F%2Fcdn.store.com%2FMy%2520Saree.webp&w=750&q=75';
      expect(optimised('https://cdn.store.com/My Saree.webp'), once);
      expect(optimised('https://cdn.store.com/My%20Saree.webp'), once);
    });
    test('leaves other hosts, GIFs and SVGs alone', () {
      expect(optimised('https://other.com/a.webp'), isNull);
      expect(optimised('https://cdn.store.com/a.gif'), isNull);
      expect(optimised('https://cdn.store.com/a.SVG'), isNull);
    });
    test('is off when the build has no optimiser', () {
      expect(optimisedImageUrl('https://cdn.store.com/a.webp', 750, base: '', cdnHost: cdn), isNull);
    });
  });
}
