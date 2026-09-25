import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getSavedUser();
  Future<void> clearUser();
  Future<String?> getAccessToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences prefs;

  AuthLocalDataSourceImpl({required this.prefs});

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      if (user.accessToken != null) {
        await prefs.setString(AppConstants.keyAccessToken, user.accessToken!);
      }
      if (user.refreshToken != null) {
        await prefs.setString(AppConstants.keyRefreshToken, user.refreshToken!);
      }
      final jsonString = jsonEncode(user.toJson());
      await prefs.setString(AppConstants.keyUserData, jsonString);
    } catch (e) {
      throw CacheException(message: 'Impossible de sauvegarder l\'utilisateur en local');
    }
  }

  @override
  Future<UserModel?> getSavedUser() async {
    final jsonString = prefs.getString(AppConstants.keyUserData);
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
        final token = prefs.getString(AppConstants.keyAccessToken);
        final refreshToken = prefs.getString(AppConstants.keyRefreshToken);
        return UserModel.fromJson(jsonMap).copyWithTokens(
          accessToken: token,
          refreshToken: refreshToken,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> clearUser() async {
    await prefs.remove(AppConstants.keyAccessToken);
    await prefs.remove(AppConstants.keyRefreshToken);
    await prefs.remove(AppConstants.keyUserData);
  }

  @override
  Future<String?> getAccessToken() async {
    return prefs.getString(AppConstants.keyAccessToken);
  }
}
