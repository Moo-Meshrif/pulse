import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// In-memory storage for the PKCE sign-up flow (the app uses shared_preferences).
class _MemoryAsyncStorage extends GotrueAsyncStorage {
  final _items = <String, String>{};

  @override
  Future<String?> getItem({required String key}) async => _items[key];

  @override
  Future<void> removeItem({required String key}) async => _items.remove(key);

  @override
  Future<void> setItem({required String key, required String value}) async =>
      _items[key] = value;
}

/// A Supabase client whose HTTP goes to [respond] instead of the network, with every request recorded.
/// The repositories run their real request building against canned answers.
class BackendDouble {
  BackendDouble(this.respond);

  final Future<http.Response> Function(http.Request request) respond;
  final List<http.Request> requests = [];

  static const uid = 'user-1';

  late final SupabaseClient client = SupabaseClient(
    'https://test.supabase.co',
    'publishable-key',
    authOptions: AuthClientOptions(pkceAsyncStorage: _MemoryAsyncStorage()),
    httpClient: MockClient((request) async {
      requests.add(request);
      final response = await respond(request);
      // A real client always sets the request on its response, and postgrest reads it.
      return http.Response(
        response.body,
        response.statusCode,
        headers: response.headers,
        request: request,
      );
    }),
  );

  /// Requests whose path ends with [suffix].
  Iterable<http.Request> to(String suffix) =>
      requests.where((r) => r.url.path.endsWith(suffix));

  static Map<String, dynamic> userJson({
    String email = 'dip@example.com',
    List<Map<String, dynamic>>? identities,
  }) => {
    'id': uid,
    'aud': 'authenticated',
    'email': email,
    'created_at': '2026-01-01T00:00:00Z',
    'app_metadata': <String, dynamic>{},
    'user_metadata': <String, dynamic>{},
    'identities': ?identities,
  };

  static String _jwt() {
    String part(Map<String, dynamic> json) =>
        base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
    return '${part({'alg': 'HS256', 'typ': 'JWT'})}.'
        '${part({'sub': uid, 'role': 'authenticated', 'aud': 'authenticated', 'exp': 4102444800})}.sig';
  }

  /// The answer to a successful password grant.
  static http.Response sessionResponse({String email = 'dip@example.com'}) =>
      json({
        'access_token': _jwt(),
        'token_type': 'bearer',
        'expires_in': 3600,
        'refresh_token': 'refresh',
        'user': userJson(email: email),
      });

  static http.Response json(Object? body, {int status = 200}) => http.Response(
    jsonEncode(body),
    status,
    headers: {'content-type': 'application/json'},
  );

  /// A GoTrue error: `{"code": status, "error_code": code, "msg": ...}`.
  static http.Response authError(int status, String code) =>
      json({'code': status, 'error_code': code, 'msg': code}, status: status);

  static http.Response postgrestError(int status, String code) => json({
    'code': code,
    'message': code,
    'details': null,
    'hint': null,
  }, status: status);

  /// Signs the client in through the real password grant, then forgets the requests.
  Future<void> signIn() async {
    await client.auth.signInWithPassword(
      email: 'dip@example.com',
      password: 'secret',
    );
    requests.clear();
  }
}
