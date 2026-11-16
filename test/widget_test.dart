import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:sibekas_mobile/app.dart';
import 'package:sibekas_mobile/core/api_client.dart';
import 'fixtures.dart';

void main() {
  testWidgets('Guest can navigate all modules; private screens request login', (
    tester,
  ) async {
    final api = ApiClient(
      client: MockClient((request) async => fixtureResponse(request)),
    );
    addTearDown(api.dispose);
    await tester.pumpWidget(SiBekasApp(api: api));
    await tester.pumpAndSettle();
    expect(find.text('Buku Kalkulus UI'), findsOneWidget);
    for (final tab in ['Profil', 'Keranjang', 'Pesanan']) {
      await tester.tap(find.text(tab));
      await tester.pumpAndSettle();
      expect(find.text('Masuk ke akun'), findsOneWidget);
    }
    await tester.tap(find.text('Ulasan'));
    await tester.pumpAndSettle();
    expect(find.text('Bukunya terawat dan sesuai deskripsi.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Login opens profile, cart and orders with server data then logout clears access',
    (tester) async {
      final requests = <String>[];
      final api = ApiClient(
        client: MockClient((request) async {
          requests.add(request.url.path);
          return fixtureResponse(request);
        }),
      );
      addTearDown(api.dispose);
      await tester.pumpWidget(SiBekasApp(api: api));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Username'),
        'mahasiswa_ui',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Kata sandi'),
        'test-password',
      );
      await tester.tap(find.text('Masuk ke SiBekas'));
      await tester.pumpAndSettle();
      expect(api.isLoggedIn, isTrue);
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      expect(find.text('Mahasiswa UI'), findsOneWidget);
      await tester.tap(find.text('Keranjang'));
      await tester.pumpAndSettle();
      expect(find.text('Rp 90.000'), findsOneWidget);
      await tester.tap(find.text('Pesanan'));
      await tester.pumpAndSettle();
      expect(find.text('SB-261116-ABCD1234'), findsOneWidget);
      await tester.tap(find.byTooltip('Keluar'));
      await tester.pumpAndSettle();
      expect(api.isLoggedIn, isFalse);
      expect(find.text('Masuk ke akun'), findsOneWidget);
      expect(
        requests,
        containsAll(['/api/v1/profile/', '/api/v1/cart/', '/api/v1/orders/']),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Network failure offers retry and search is sent to API', (
    tester,
  ) async {
    var failing = true;
    final queries = <String?>[];
    final api = ApiClient(
      client: MockClient((request) async {
        queries.add(request.url.queryParameters['q']);
        if (failing) {
          return jsonResponse({'detail': 'Server sedang sibuk.'}, 503);
        }
        return fixtureResponse(request);
      }),
    );
    addTearDown(api.dispose);
    await tester.pumpWidget(SiBekasApp(api: api));
    await tester.pumpAndSettle();
    expect(find.text('Server sedang sibuk.'), findsOneWidget);
    failing = false;
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();
    expect(find.text('Buku Kalkulus UI'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'kalkulus');
    await tester.tap(find.byTooltip('Cari produk'));
    await tester.pumpAndSettle();
    expect(queries.last, 'kalkulus');
    expect(tester.takeException(), isNull);
  });
}
