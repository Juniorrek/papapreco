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
class API {
  /// The default targets `10.0.2.2`, which is how the Android emulator reaches
  /// the host machine — the right target for a bare `flutter run`.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080/papaprecoapi',
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
