import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'auth_interceptor.dart';

/// [ApiClient] gère l'ensemble des appels réseau via le package officiel [http] et [Dio].
/// Il configure l'[AuthInterceptor] pour l'injection du token d'authentification Bearer
/// et le traitement automatique des expirations de session (Refresh Token).
class ApiClient {
  final http.Client client;
  final Dio dio;
  final SharedPreferences prefs;

  ApiClient({
    required SharedPreferences prefs,
    Dio? dioClient,
    http.Client? httpClient,
  })  : prefs = prefs,
        client = AuthInterceptor(client: httpClient, prefs: prefs),
        dio = dioClient ?? Dio() {
    dio.options.baseUrl = AppConstants.baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);
    dio.interceptors.add(AuthDioInterceptor(prefs: prefs, dioClient: dio));
  }

  /// Requête GET via [http]
  Future<dynamic> get(String endpoint) async {
    final uri = Uri.parse(endpoint.startsWith('http') ? endpoint : '${AppConstants.baseUrl}$endpoint');
    final response = await client.get(uri);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }
    throw Exception('Erreur HTTP ${response.statusCode}: ${response.body}');
  }

  /// Requête POST via [http]
  Future<dynamic> post(String endpoint, {Map<String, dynamic>? data}) async {
    final uri = Uri.parse(endpoint.startsWith('http') ? endpoint : '${AppConstants.baseUrl}$endpoint');
    final response = await client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: data != null ? jsonEncode(data) : null,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }
    throw Exception('Erreur HTTP ${response.statusCode}: ${response.body}');
  }
}
