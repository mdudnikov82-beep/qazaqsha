import 'package:flutter_test/flutter_test.dart';
import 'package:qazaqsha/core/updates.dart';

void main() {
  test('versions compare by number, not by text', () {
    expect(Updates.isNewer('1.10.0', '1.9.0'), isTrue);
    expect(Updates.isNewer('2.0', '1.9.9'), isTrue);
    expect(Updates.isNewer('1.9.0', '1.9.0'), isFalse);
    expect(Updates.isNewer('1.9', '1.9.0'), isFalse);
    expect(Updates.isNewer('1.8.5', '1.9.0'), isFalse);
    expect(Updates.isNewer('beta', '1.9.0'), isFalse);
  });

  Map<String, dynamic> release(String tag, {bool pre = false}) => {
    'tag_name': tag,
    'html_url': 'https://github.com/x/y/releases/tag/$tag',
    'prerelease': pre,
    'assets': [
      {'name': 'qazaqsha-$tag-universal.apk', 'browser_download_url': 'u'},
      {
        'name': 'qazaqsha-$tag-arm64.apk',
        'browser_download_url': 'https://a/arm64.apk',
      },
    ],
  };

  test('a newer release is offered with its arm64 APK', () {
    final u = Updates.parse(release('v1.10.0'), '1.9.0')!;
    expect(u.version, '1.10.0');
    expect(u.apk.toString(), 'https://a/arm64.apk');
    expect(u.page.toString(), contains('v1.10.0'));
  });

  test('same, older, pre-release or odd answers offer nothing', () {
    expect(Updates.parse(release('v1.9.0'), '1.9.0'), isNull);
    expect(Updates.parse(release('v1.8.0'), '1.9.0'), isNull);
    expect(Updates.parse(release('v2.0.0', pre: true), '1.9.0'), isNull);
    expect(Updates.parse({'message': 'Not Found'}, '1.9.0'), isNull);
  });
}
