import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../data/providers.dart';

/// A release newer than the installed app.
class AppUpdate {
  const AppUpdate({required this.version, required this.page, this.apk});

  final String version;

  /// The release page with notes and all files.
  final Uri page;

  /// The phone APK for most devices, if the release has one.
  final Uri? apk;
}

/// Asks GitHub for the latest release. Android phones only: the web version
/// is always fresh, and the watch app stays offline.
abstract final class Updates {
  static const _latest =
      'https://api.github.com/repos/mdudnikov82-beep/qazaqsha/releases/latest';

  static bool get supported =>
      !kIsWeb &&
      defaultTargetPlatform == TargetPlatform.android &&
      !Platform.environment.containsKey('FLUTTER_TEST');

  /// The installed version, without the «-watch» suffix.
  static Future<String> currentVersion() async =>
      (await PackageInfo.fromPlatform()).version.split('-').first;

  /// The newer release, or null if there is none or the check failed
  /// (no internet is fine: we just try again next time).
  static Future<AppUpdate?> check() async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 8)
      ..userAgent = 'Qazaqsha-app';
    try {
      final current = await currentVersion();
      final req = await client.getUrl(Uri.parse(_latest));
      req.headers.set('Accept', 'application/vnd.github+json');
      final res = await req.close().timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return null;
      final body = await res
          .transform(utf8.decoder)
          .join()
          .timeout(const Duration(seconds: 10));
      return parse(jsonDecode(body) as Map<String, dynamic>, current);
    } catch (_) {
      return null;
    } finally {
      client.close(force: true);
    }
  }

  /// Reads GitHub's «latest release» answer.
  @visibleForTesting
  static AppUpdate? parse(Map<String, dynamic> json, String current) {
    final tag = json['tag_name'];
    final page = json['html_url'];
    if (tag is! String || page is! String) return null;
    if (json['draft'] == true || json['prerelease'] == true) return null;
    final version = tag.startsWith('v') ? tag.substring(1) : tag;
    if (!isNewer(version, current)) return null;
    String? apk;
    for (final a in (json['assets'] as List?) ?? const []) {
      final name = (a as Map)['name'];
      if (name is String && name.endsWith('-arm64.apk')) {
        apk = a['browser_download_url'] as String?;
      }
    }
    return AppUpdate(
      version: version,
      page: Uri.parse(page),
      apk: apk == null ? null : Uri.parse(apk),
    );
  }

  /// «1.10.0» is newer than «1.9.0». Anything unreadable is not newer.
  static bool isNewer(String a, String b) {
    List<int>? parts(String v) {
      final p = v.split('.').map(int.tryParse).toList();
      return p.contains(null) || p.isEmpty ? null : p.cast<int>();
    }

    final x = parts(a), y = parts(b);
    if (x == null || y == null) return false;
    for (var i = 0; i < x.length || i < y.length; i++) {
      final d = (i < x.length ? x[i] : 0) - (i < y.length ? y[i] : 0);
      if (d != 0) return d > 0;
    }
    return false;
  }
}

/// How the app looks for updates; tests replace it.
final updateCheckProvider = Provider<Future<AppUpdate?> Function()>(
  (ref) => Updates.supported ? Updates.check : () async => null,
);

/// A newer release, checked once per app start while the setting is on.
final availableUpdateProvider = FutureProvider<AppUpdate?>((ref) async {
  final on = ref.watch(statsProvider.select((s) => s.value?.checkUpdates));
  if (on != true) return null;
  return ref.watch(updateCheckProvider)();
});
