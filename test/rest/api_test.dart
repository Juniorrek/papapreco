import 'package:flutter_test/flutter_test.dart';
import 'package:papapreco/rest/api.dart';

// API.baseUrl comes from String.fromEnvironment, resolved at compile time.
// These tests derive their expectations from it instead of pinning the default
// URL, so they stay valid under `flutter test --dart-define=API_BASE_URL=...`.
String get _base => API.baseUrl.endsWith('/')
    ? API.baseUrl.substring(0, API.baseUrl.length - 1)
    : API.baseUrl;

void main() {
  group('API.uri', () {
    test('resolves the path against the base URL, keeping the context path',
        () {
      expect(API.uri('produtos/lista').toString(), '$_base/produtos/lista');
    });

    test('accepts a leading slash without doubling it', () {
      expect(API.uri('/produtos/lista'), API.uri('produtos/lista'));
    });

    test('appends query parameters', () {
      final Uri uri = API.uri('produtos/historico', {
        'nome': 'arroz',
        'latitude': -25.441105,
        'longitude': -49.276855,
      });

      expect(uri.toString(), startsWith('$_base/produtos/historico?'));
      expect(uri.queryParameters, {
        'nome': 'arroz',
        'latitude': '-25.441105',
        'longitude': '-49.276855',
      });
    });

    test('emits no "?" when there are no parameters', () {
      expect(API.uri('produtos').hasQuery, isFalse);
      expect(API.uri('produtos', {}).hasQuery, isFalse);
    });

    test('escapes user-supplied query values', () {
      final Uri uri = API.uri('produtos/filtrar', {'nome': 'café & pão'});

      expect(uri.queryParameters['nome'], 'café & pão');
      expect(uri.query, isNot(contains('&pão')));
    });

    test('escapes values interpolated into the path', () {
      final Uri uri = API.uri('produtos/nome/${'café com leite'}');

      expect(uri.pathSegments.last, 'café com leite');
      expect(uri.toString(), isNot(contains(' ')));
    });
  });
}
