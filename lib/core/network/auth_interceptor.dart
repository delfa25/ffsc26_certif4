import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart' as dio;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

/// [AuthInterceptor] implémente un intercepteur HTTP basé sur [http.BaseClient] du package `http`.
/// Il réalise l'injection automatique du jeton Bearer JWT dans l'en-tête `Authorization`
/// et implémente la gestion automatique du Refresh Token en interceptant les erreurs HTTP 401.
class AuthInterceptor extends http.BaseClient {
  final http.Client _inner;
  final SharedPreferences prefs;

  AuthInterceptor({
    http.Client? client,
    required this.prefs,
  }) : _inner = client ?? http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // 1. Intercepteur: Injection automatique du token d'authentification JWT
    final token = prefs.getString(AppConstants.keyAccessToken);
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.headers['Content-Type'] ??= 'application/json';
    request.headers['Accept'] ??= 'application/json';

    // Envoi de la requête
    http.StreamedResponse response = await _inner.send(request);

    // 2. Gestion du Refresh Token en cas d'erreur HTTP 401 Unauthorized
    if (response.statusCode == 401) {
      final refreshToken = prefs.getString(AppConstants.keyRefreshToken);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          final refreshResponse = await _inner.post(
            Uri.parse('${AppConstants.baseUrl}/auth/refresh'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'refreshToken': refreshToken,
              'expiresInMins': 60,
            }),
          );

          if (refreshResponse.statusCode == 200) {
            final data = jsonDecode(refreshResponse.body) as Map<String, dynamic>;
            final newAccessToken = data['accessToken']?.toString();
            final newRefreshToken = data['refreshToken']?.toString();

            if (newAccessToken != null) {
              await prefs.setString(AppConstants.keyAccessToken, newAccessToken);
            }
            if (newRefreshToken != null) {
              await prefs.setString(AppConstants.keyRefreshToken, newRefreshToken);
            }

            // Cloner et rejouer la requête d'origine avec le nouveau jeton
            final retryRequest = _cloneRequest(request, newAccessToken ?? '');
            return await _inner.send(retryRequest);
          } else {
            await prefs.remove(AppConstants.keyAccessToken);
            await prefs.remove(AppConstants.keyRefreshToken);
            await prefs.remove(AppConstants.keyUserData);
          }
        } catch (_) {
          await prefs.remove(AppConstants.keyAccessToken);
          await prefs.remove(AppConstants.keyRefreshToken);
          await prefs.remove(AppConstants.keyUserData);
        }
      }
    }

    return response;
  }

  http.BaseRequest _cloneRequest(http.BaseRequest original, String newAccessToken) {
    http.BaseRequest request;
    if (original is http.Request) {
      request = http.Request(original.method, original.url)
        ..bodyBytes = original.bodyBytes;
    } else {
      request = http.Request(original.method, original.url);
    }
    request.headers.addAll(original.headers);
    if (newAccessToken.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $newAccessToken';
    }
    return request;
  }
}

/// [AuthDioInterceptor] pour compatibilité avec le client Dio.
class AuthDioInterceptor extends dio.Interceptor {
  final SharedPreferences prefs;
  final dio.Dio dioClient;

  AuthDioInterceptor({required this.prefs, required this.dioClient});

  @override
  void onRequest(dio.RequestOptions options, dio.RequestInterceptorHandler handler) {
    final token = prefs.getString(AppConstants.keyAccessToken);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(dio.DioException err, dio.ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = prefs.getString(AppConstants.keyRefreshToken);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          final refreshDio = dio.Dio(
            dio.BaseOptions(
              baseUrl: AppConstants.baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          );

          final response = await refreshDio.post(
            '/auth/refresh',
            data: {
              'refreshToken': refreshToken,
              'expiresInMins': 60,
            },
            options: dio.Options(headers: {'Content-Type': 'application/json'}),
          );

          if (response.statusCode == 200 && response.data != null) {
            final newAccessToken = response.data['accessToken'];
            final newRefreshToken = response.data['refreshToken'];

            if (newAccessToken != null) {
              await prefs.setString(AppConstants.keyAccessToken, newAccessToken.toString());
            }
            if (newRefreshToken != null) {
              await prefs.setString(AppConstants.keyRefreshToken, newRefreshToken.toString());
            }

            final requestOptions = err.requestOptions;
            requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            
            final retryResponse = await dioClient.fetch(requestOptions);
            return handler.resolve(retryResponse);
          }
        } catch (_) {
          await prefs.remove(AppConstants.keyAccessToken);
          await prefs.remove(AppConstants.keyRefreshToken);
          await prefs.remove(AppConstants.keyUserData);
        }
      }
    }
    handler.next(err);
  }
}
