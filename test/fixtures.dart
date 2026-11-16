import 'dart:convert';
import 'package:http/http.dart' as http;

const productJson = {
  'id': 1,
  'name': 'Buku Kalkulus UI',
  'description': 'Buku kuliah layak pakai.',
  'price': 45000,
  'stock': 2,
  'condition_display': 'Baik',
  'seller_name': 'penjual_ui',
  'category': {'name': 'Buku'},
  'image_url': '',
};
const profileJson = {
  'username': 'mahasiswa_ui',
  'email': 'mahasiswa@ui.ac.id',
  'full_name': 'Mahasiswa UI',
  'faculty': 'Fasilkom',
  'student_id': '2500000000',
  'phone_number': '081234567890',
  'bio': 'Suka barang preloved.',
  'address': 'Depok',
  'is_staff': false,
};
http.Response jsonResponse(Object body, [int status = 200]) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);
Map<String, Object?> paginated(List<Object> items, {String? next}) => {
  'count': items.length,
  'next': next,
  'previous': null,
  'results': items,
};
http.Response fixtureResponse(http.Request request) {
  switch (request.url.path) {
    case '/api/v1/auth/login/':
      return jsonResponse({'token': 'test-token', 'profile': profileJson});
    case '/api/v1/auth/logout/':
      return http.Response('', 204);
    case '/api/v1/products/':
      return jsonResponse(paginated([productJson]));
    case '/api/v1/profile/':
      return jsonResponse(profileJson);
    case '/api/v1/profile/favorites/':
      return jsonResponse(paginated([productJson]));
    case '/api/v1/cart/':
      return jsonResponse({
        'items': [
          {
            'product': productJson,
            'quantity': 2,
            'line_total': 90000,
            'available': true,
            'unavailable_reason': '',
          },
        ],
        'subtotal': 90000,
        'total_items': 2,
      });
    case '/api/v1/orders/':
      return jsonResponse(
        paginated([
          {
            'number': 'SB-261116-ABCD1234',
            'status_display': 'Diproses',
            'delivery_method_display': 'Ambil di kampus UI',
            'total': 45000,
            'created_at': '2026-11-16T12:00:00Z',
            'items': [
              {'product_name': 'Buku Kalkulus UI', 'quantity': 1},
            ],
          },
        ]),
      );
    case '/api/v1/reviews/':
      return jsonResponse(
        paginated([
          {
            'product_name': 'Buku Kalkulus UI',
            'username': 'pembeli_ui',
            'rating': 5,
            'comment': 'Bukunya terawat dan sesuai deskripsi.',
            'edited': false,
          },
        ]),
      );
    default:
      return jsonResponse({'detail': 'Tidak ditemukan.'}, 404);
  }
}
