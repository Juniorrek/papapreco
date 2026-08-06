/// Single point of configuration for the API address.
///
/// The base URL is injected at build time so that no environment is ever
/// committed to source:
///
/// ```
/// flutter run --dart-define=API_BASE_URL=http://YOUR_LAN_IP:8080/papaprecoapi
/// ```
///
/// It includes the scheme (`http`/`https`) and the API's context path, so
/// pointing the app at a deployed environment behind HTTPS takes a different
/// build argument rather than a code change.
library;

import 'package:flutter/foundation.dart' show kReleaseMode;

class API {
  /// `10.0.2.2` is how the Android emulator reaches the host machine — the
  /// right target for a bare `flutter run`, and wrong for anything installed
  /// on a real device.
  static const String _developmentDefault = 'http://10.0.2.2:8080/papaprecoapi';

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _developmentDefault,
  );

  static final Uri _base = _parseBaseUrl();

  static Uri _parseBaseUrl() {
    final Uri base = Uri.parse(baseUrl);

    if (!base.hasScheme || !base.hasAuthority) {
      throw StateError(
          'API_BASE_URL must include a scheme and a host, e.g. http://10.0.2.2:8080/papaprecoapi (got: "$baseUrl")');
    }

    return base;
  }

  /// Fails a release build that was compiled without
  /// `--dart-define=API_BASE_URL`, at startup rather than at the first request.
  ///
  /// Without this the omission is silent: the APK installs, launches and shows
  /// its first screen, then every call times out against an address that only
  /// means anything inside an emulator. That failure reaches whoever installed
  /// the app rather than whoever built it, which is why it is worth crashing
  /// over. Debug and profile builds are untouched — the default is the point of
  /// the default.
  ///
  /// Call once from `main()`, before any request can be made.
  static void assertConfiguredForRelease() {
    if (!kReleaseMode) return;

    if (baseUrl == _developmentDefault) {
      throw StateError(
          'This release build has no API_BASE_URL and is pointing at the '
          'emulator default. Rebuild with --dart-define=API_BASE_URL=https://<host>/papaprecoapi');
    }

    // Android has blocked cleartext HTTP by default since API 28, so an http://
    // release build cannot reach its API on any current phone. Better to say so
    // here than to let it present as the whole network being down.
    if (_base.scheme != 'https') {
      throw StateError(
          'This release build targets "$baseUrl", which is not HTTPS. Android '
          'blocks cleartext traffic, so every request would fail on a real device.');
    }
  }

  /// Builds the absolute URI for [path], resolved against [baseUrl].
  ///
  /// [path] is relative to the base URL (`'produtos/lista'`, not
  /// `'/produtos/lista'`) and is percent-encoded, as are the values in [query].
  /// User-supplied values therefore belong in [query] rather than interpolated
  /// into the [path] string.
  static Uri uri(String path, [Map<String, dynamic>? query]) {
    final String prefix =
        _base.path.endsWith('/') ? _base.path : '${_base.path}/';
    final String relative = path.startsWith('/') ? path.substring(1) : path;

    return _base.replace(
      path: '$prefix$relative',
      queryParameters: query == null || query.isEmpty
          ? null
          : query.map((key, value) => MapEntry(key, value.toString())),
    );
  }
}
