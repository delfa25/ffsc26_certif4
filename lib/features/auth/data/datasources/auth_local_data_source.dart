import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getSavedUser();
  Future<void> clearUser();
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> saveTokens({required String accessToken, required String refreshToken});
}

/// Implémentation du cache local pour l'authentification avec [Hive] et [SharedPreferences].
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences? prefs;
  final Box? box;

  AuthLocalDataSourceImpl({this.prefs, this.box});

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      if (user.accessToken != null) {
        if (box != null && box!.isOpen) await box!.put(AppConstants.keyAccessToken, user.accessToken!);
        if (prefs != null) await prefs!.setString(AppConstants.keyAccessToken, user.accessToken!);
      }
      if (user.refreshToken != null) {
        if (box != null && box!.isOpen) await box!.put(AppConstants.keyRefreshToken, user.refreshToken!);
        if (prefs != null) await prefs!.setString(AppConstants.keyRefreshToken, user.refreshToken!);
      }
      final jsonString = jsonEncode(user.toJson());
      if (box != null && box!.isOpen) await box!.put(AppConstants.keyUserData, jsonString);
      if (prefs != null) await prefs!.setString(AppConstants.keyUserData, jsonString);
    } catch (e) {
      throw CacheException(message: 'Impossible de sauvegarder l\'utilisateur en local (Hive)');
    }
  }

  @override
  Future<UserModel?> getSavedUser() async {
    String? jsonString;
    if (box != null && box!.isOpen) jsonString = box!.get(AppConstants.keyUserData)?.toString();
    if (jsonString == null && prefs != null) jsonString = prefs!.getString(AppConstants.keyUserData);

    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
        final token = await getAccessToken();
        final refreshToken = await getRefreshToken();
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
    if (box != null && box!.isOpen) {
      await box!.delete(AppConstants.keyAccessToken);
      await box!.delete(AppConstants.keyRefreshToken);
      await box!.delete(AppConstants.keyUserData);
    }
    if (prefs != null) {
      await prefs!.remove(AppConstants.keyAccessToken);
      await prefs!.remove(AppConstants.keyRefreshToken);
      await prefs!.remove(AppConstants.keyUserData);
    }
  }

  @override
  Future<String?> getAccessToken() async {
    if (box != null && box!.isOpen) {
      final token = box!.get(AppConstants.keyAccessToken)?.toString();
      if (token != null && token.isNotEmpty) return token;
    }
    return prefs?.getString(AppConstants.keyAccessToken);
  }

  @override
  Future<String?> getRefreshToken() async {
    if (box != null && box!.isOpen) {
      final token = box!.get(AppConstants.keyRefreshToken)?.toString();
      if (token != null && token.isNotEmpty) return token;
    }
    return prefs?.getString(AppConstants.keyRefreshToken);
  }

  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    if (box != null && box!.isOpen) {
      await box!.put(AppConstants.keyAccessToken, accessToken);
      await box!.put(AppConstants.keyRefreshToken, refreshToken);
    }
    if (prefs != null) {
      await prefs!.setString(AppConstants.keyAccessToken, accessToken);
      await prefs!.setString(AppConstants.keyRefreshToken, refreshToken);
    }
    final user = await getSavedUser();
    if (user != null) {
      final updated = user.copyWithTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      await saveUser(updated);
    }
  }
}
