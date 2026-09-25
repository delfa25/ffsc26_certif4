import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<User> login(String username, String password) async {
    try {
      final userModel = await remoteDataSource.login(username, password);
      await localDataSource.saveUser(userModel);
      return userModel;
    } on ServerException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw const AuthFailure('Échec de connexion. Vérifiez vos identifiants ou votre réseau.');
    }
  }

  @override
  Future<User> register(String username, String email, String password) async {
    try {
      final userModel = await remoteDataSource.register(username, email, password);
      await localDataSource.saveUser(userModel);
      return userModel;
    } on ServerException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw const AuthFailure('Échec de l\'inscription. Réessayez.');
    }
  }

  @override
  Future<User?> getSavedUser() async {
    return await localDataSource.getSavedUser();
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearUser();
  }

  @override
  Future<User> refreshToken() async {
    try {
      final currentRefreshToken = await localDataSource.getRefreshToken();
      if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
        throw const AuthFailure('Aucun jeton de rafraîchissement trouvé en local.');
      }
      final tokens = await remoteDataSource.refreshToken(currentRefreshToken);
      final newAccessToken = tokens['accessToken'] ?? '';
      final newRefreshToken = tokens['refreshToken'] ?? currentRefreshToken;

      await localDataSource.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      final savedUser = await localDataSource.getSavedUser();
      if (savedUser != null) {
        return savedUser;
      }
      return User(
        id: 0,
        username: '',
        email: '',
        firstName: '',
        lastName: '',
        gender: '',
        image: '',
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );
    } on ServerException catch (e) {
      throw AuthFailure(e.message);
    } on AuthFailure {
      rethrow;
    } catch (e) {
      throw const AuthFailure('Échec du rafraîchissement du jeton de session.');
    }
  }
}
