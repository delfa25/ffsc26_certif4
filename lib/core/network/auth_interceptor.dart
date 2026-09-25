import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class AuthInterceptor extends Interceptor {
  final SharedPreferences prefs;
  final Dio dio;

  AuthInterceptor({required this.prefs, required this.dio});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = prefs.getString(AppConstants.keyAccessToken);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = prefs.getString(AppConstants.keyRefreshToken);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          // Attempt token refresh
          final response = await dio.post(
            '${AppConstants.baseUrl}/auth/refresh',
            data: {
              'refreshToken': refreshToken,
              'expiresInMins': 60,
            },
            options: Options(headers: {'Content-Type': 'application/json'}),
          );

          if (response.statusCode == 200 && response.data != null) {
            final newAccessToken = response.data['accessToken'];
            final newRefreshToken = response.data['refreshToken'];

            if (newAccessToken != null) {
              await prefs.setString(AppConstants.keyAccessToken, newAccessToken);
            }
            if (newRefreshToken != null) {
              await prefs.setString(AppConstants.keyRefreshToken, newRefreshToken);
            }

            // Retry original request with new token
            final requestOptions = err.requestOptions;
            requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            
            final retryResponse = await dio.fetch(requestOptions);
            return handler.resolve(retryResponse);
          }
        } catch (_) {
          // Clear credentials on failed refresh
          await prefs.remove(AppConstants.keyAccessToken);
          await prefs.remove(AppConstants.keyRefreshToken);
          await prefs.remove(AppConstants.keyUserData);
        }
      }
    }
    handler.next(err);
  }
}
