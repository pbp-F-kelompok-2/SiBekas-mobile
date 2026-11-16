import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiException implements Exception {
  const ApiException(this.message, [this.statusCode]);
  final String message;
  final int? statusCode;
  @override
  String toString() => message;
}

class ApiPage<T> {
  const ApiPage(this.items, this.hasNext);
  final List<T> items;
  final bool hasNext;
}

/// Shared HTTP client. Login credentials and token are only kept in memory.
class ApiClient extends ChangeNotifier {
  ApiClient({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      baseUrl =
          (baseUrl ??
                  const String.fromEnvironment(
                    'API_BASE_URL',
                    defaultValue:
                        'https://faris-salman-sibekas.pws.cs.ui.ac.id/api/v1/',
                  ))
              .replaceFirst(RegExp(r'/*$'), '/');
  final http.Client _client;
  final String baseUrl;
  String? _token;
  String? username;
  bool get isLoggedIn => _token != null;

  Future<Map<String, dynamic>> get(String path, {Map<String, String>? query}) =>
      _request('GET', path, query: query);

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final request = http.Request(method, uri)
      ..headers['Accept'] = 'application/json';
    if (_token != null) request.headers['Authorization'] = 'Token $_token';
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }
    try {
      final response = await _client
          .send(request)
          .then(http.Response.fromStream)
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 204) return {};
      if (response.statusCode == 401 && _token != null) {
        _token = null;
        username = null;
        notifyListeners();
      }
      Map<String, dynamic> data;
      try {
        data =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      } on FormatException {
        throw ApiException(
          'Server tidak mengirim JSON. Periksa alamat API.',
          response.statusCode,
        );
      } on TypeError {
        throw const ApiException('Format respons API tidak sesuai.');
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          data['detail']?.toString() ??
              (data.isEmpty
                  ? 'Permintaan gagal (${response.statusCode}).'
                  : data.values.first.toString()),
          response.statusCode,
        );
      }
      return data;
    } on TimeoutException {
      throw const ApiException('Koneksi terlalu lama. Coba lagi.');
    } on http.ClientException {
      throw const ApiException(
        'Tidak dapat terhubung. Periksa internet dan alamat server.',
      );
    }
  }

  Future<void> login(String username, String password) async {
    final data = await _request(
      'POST',
      'auth/login/',
      body: {'username': username.trim(), 'password': password},
    );
    _token = data['token'] as String;
    this.username =
        (data['profile'] as Map<String, dynamic>)['username'] as String;
    notifyListeners();
  }

  Future<void> logout() async {
    await _request('POST', 'auth/logout/');
    _token = null;
    username = null;
    notifyListeners();
  }

  Future<ApiPage<T>> page<T>(
    String path,
    T Function(Map<String, dynamic>) parse, {
    int page = 1,
    Map<String, String> query = const {},
  }) async {
    final data = await get(path, query: {...query, 'page': '$page'});
    return ApiPage(
      (data['results'] as List)
          .map((row) => parse(row as Map<String, dynamic>))
          .toList(),
      data['next'] != null,
    );
  }

  Future<ProfileData> profile() async =>
      ProfileData.fromJson(await get('profile/'));
  Future<CartData> cart() async => CartData.fromJson(await get('cart/'));
  @override
  void dispose() {
    _client.close();
    super.dispose();
  }
}
