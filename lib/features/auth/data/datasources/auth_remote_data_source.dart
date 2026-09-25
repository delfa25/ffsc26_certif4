import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';

import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String username, String password);
  Future<UserModel> register(String username, String email, String password);
  Future<UserModel> getCurrentUser(String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserModel> login(String username, String password) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {
          'username': username,
          'password': password,
          'expiresInMins': 60,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return UserModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException(message: 'Identifiants invalides');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null && e.response?.data['message'] != null) {
        throw ServerException(message: e.response?.data['message'].toString() ?? 'Erreur d\'authentification');
      }
      throw ServerException(message: 'Erreur réseau lors de la connexion: ${e.message}');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> register(String username, String email, String password) async {
    try {
      final response = await dio.post(
        '/users/add',
        data: {
          'username': username,
          'email': email,
          'password': password,
          'firstName': username,
          'lastName': 'User',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = Map<String, dynamic>.from(response.data as Map);
        data['accessToken'] = 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}';
        data['refreshToken'] = 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}';
        return UserModel.fromJson(data);
      } else {
        throw ServerException(message: 'Échec de l\'inscription');
      }
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Erreur serveur lors de l\'inscription');
    }
  }

  @override
  Future<UserModel> getCurrentUser(String token) async {
    try {
      final response = await dio.get(
        '/auth/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data != null) {
        return UserModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException(message: 'Impossible de récupérer l\'utilisateur');
      }
    } catch (e) {
      throw ServerException(message: 'Erreur lors de la récupération du profil');
    }
  }
}
