import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'auth_interceptor.dart';

class ApiClient {
  final Dio dio;

  ApiClient({required Dio dioClient, required SharedPreferences prefs})
      : dio = dioClient {
    dio.options.baseUrl = AppConstants.baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);
    dio.interceptors.add(AuthInterceptor(prefs: prefs, dio: dio));
  }
}
