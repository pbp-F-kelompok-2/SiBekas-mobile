import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sibekas_mobile/core/api_client.dart';
import 'package:sibekas_mobile/models/models.dart';
import 'fixtures.dart';

void main() {
  test(
    'Login sends JSON and token is attached to later requests, then revoked on logout',
    () async {
      final requests = <http.Request>[];
      final api = ApiClient(
        baseUrl: 'https://example.test/api/v1',
        client: MockClient((request) async {
          requests.add(request);
          return fixtureResponse(request);
        }),
      );
      addTearDown(api.dispose);
      await api.login(' mahasiswa_ui ', 'password with spaces ');
      expect(jsonDecode(requests.first.body), {
        'username': 'mahasiswa_ui',
        'password': 'password with spaces ',
      });
      expect(requests.first.headers['Content-Type'], 'application/json');
      final cart = await api.cart();
      expect(requests.last.headers['Authorization'], 'Token test-token');
      expect(cart.subtotal, 90000);
      await api.logout();
      expect(api.isLoggedIn, isFalse);
    },
  );
  test(
    'Pagination and query parameters preserve filter and parse DRF JSON',
    () async {
      late Uri uri;
      final api = ApiClient(
        client: MockClient((request) async {
          uri = request.url;
          return jsonResponse(
            paginated([productJson], next: 'https://example.test/page3'),
          );
        }),
      );
      addTearDown(api.dispose);
      final page = await api.page(
        'products/',
        Product.fromJson,
        page: 2,
        query: {'q': 'buku & alat'},
      );
      expect(uri.queryParameters, {'q': 'buku & alat', 'page': '2'});
      expect(page.hasNext, isTrue);
      expect(page.items.single.price, 45000);
    },
  );
  test('Expired token resets login and exposes 401', () async {
    final api = ApiClient(
      client: MockClient(
        (request) async => request.url.path.endsWith('login/')
            ? fixtureResponse(request)
            : jsonResponse({'detail': 'Token kedaluwarsa.'}, 401),
      ),
    );
    addTearDown(api.dispose);
    await api.login('mahasiswa_ui', 'password');
    await expectLater(
      api.profile(),
      throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 401)),
    );
    expect(api.isLoggedIn, isFalse);
  });
  test('HTML and network failures become readable errors', () async {
    final html = ApiClient(
      client: MockClient(
        (request) async => http.Response('<html>404</html>', 404),
      ),
    );
    final offline = ApiClient(
      client: MockClient(
        (request) async => throw http.ClientException('offline'),
      ),
    );
    addTearDown(html.dispose);
    addTearDown(offline.dispose);
    await expectLater(html.get('products/'), throwsA(isA<ApiException>()));
    await expectLater(offline.get('products/'), throwsA(isA<ApiException>()));
  });
  test('Rupiah display uses Indonesian grouping', () {
    expect(rupiah(1500000), 'Rp 1.500.000');
    expect(rupiah(0), 'Rp 0');
  });
}
