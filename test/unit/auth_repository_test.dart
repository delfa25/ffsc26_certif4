import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ffsc26_certif4/core/errors/exceptions.dart';
import 'package:ffsc26_certif4/core/errors/failures.dart';
import 'package:ffsc26_certif4/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:ffsc26_certif4/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ffsc26_certif4/features/auth/data/models/user_model.dart';
import 'package:ffsc26_certif4/features/auth/data/repositories/auth_repository_impl.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}
class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  const tUserModel = UserModel(
    id: 1,
    username: 'emilys',
    email: 'emily.johnson@x.dummyjson.com',
    firstName: 'Emily',
    lastName: 'Johnson',
    gender: 'female',
    image: 'https://dummyjson.com/icon/emilys/128',
    accessToken: 'test_token',
    refreshToken: 'test_refresh_token',
  );

  group('AuthRepositoryImpl - login', () {
    test('devrait retourner User et sauvegarder en local lors d\'une connexion réussie', () async {
      when(() => mockRemoteDataSource.login('emilys', 'emilyspass'))
          .thenAnswer((_) async => tUserModel);
      when(() => mockLocalDataSource.saveUser(tUserModel))
          .thenAnswer((_) async => {});

      final result = await repository.login('emilys', 'emilyspass');

      expect(result.id, equals(tUserModel.id));
      expect(result.username, equals(tUserModel.username));
      verify(() => mockRemoteDataSource.login('emilys', 'emilyspass')).called(1);
      verify(() => mockLocalDataSource.saveUser(tUserModel)).called(1);
    });

    test('devrait lever AuthFailure lorsque le serveur renvoie une ServerException', () async {
      when(() => mockRemoteDataSource.login('wrong', 'wrong'))
          .thenThrow(ServerException(message: 'Identifiants invalides'));

      expect(
        () => repository.login('wrong', 'wrong'),
        throwsA(isA<AuthFailure>()),
      );
    });

    test('devrait lever AuthFailure lors d\'une exception inattendue', () async {
      when(() => mockRemoteDataSource.login('emilys', 'emilyspass'))
          .thenThrow(Exception('Erreur réseau inconnue'));

      expect(
        () => repository.login('emilys', 'emilyspass'),
        throwsA(isA<AuthFailure>()),
      );
    });
  });

  group('AuthRepositoryImpl - register', () {
    test('devrait retourner User et sauvegarder en local lors d\'une inscription réussie', () async {
      when(() => mockRemoteDataSource.register('emilys', 'emily@test.com', 'pass123'))
          .thenAnswer((_) async => tUserModel);
      when(() => mockLocalDataSource.saveUser(tUserModel))
          .thenAnswer((_) async => {});

      final result = await repository.register('emilys', 'emily@test.com', 'pass123');

      expect(result.id, equals(tUserModel.id));
      verify(() => mockRemoteDataSource.register('emilys', 'emily@test.com', 'pass123')).called(1);
      verify(() => mockLocalDataSource.saveUser(tUserModel)).called(1);
    });

    test('devrait lever AuthFailure lors d\'un échec de register', () async {
      when(() => mockRemoteDataSource.register('any', 'any@test.com', 'pass'))
          .thenThrow(ServerException(message: 'Email déjà utilisé'));

      expect(
        () => repository.register('any', 'any@test.com', 'pass'),
        throwsA(isA<AuthFailure>()),
      );
    });
  });

  group('AuthRepositoryImpl - getSavedUser', () {
    test('devrait retourner l\'utilisateur mis en cache locale', () async {
      when(() => mockLocalDataSource.getSavedUser())
          .thenAnswer((_) async => tUserModel);

      final result = await repository.getSavedUser();

      expect(result, equals(tUserModel));
      verify(() => mockLocalDataSource.getSavedUser()).called(1);
    });

    test('devrait retourner null si aucun utilisateur n\'est sauvegardé', () async {
      when(() => mockLocalDataSource.getSavedUser())
          .thenAnswer((_) async => null);

      final result = await repository.getSavedUser();

      expect(result, isNull);
      verify(() => mockLocalDataSource.getSavedUser()).called(1);
    });
  });

  group('AuthRepositoryImpl - logout', () {
    test('devrait supprimer les informations de l\'utilisateur en local', () async {
      when(() => mockLocalDataSource.clearUser())
          .thenAnswer((_) async => {});

      await repository.logout();

      verify(() => mockLocalDataSource.clearUser()).called(1);
    });
  });

  group('AuthRepositoryImpl - refreshToken', () {
    test('devrait renouveler le token et mettre à jour la persistance locale', () async {
      when(() => mockLocalDataSource.getRefreshToken())
          .thenAnswer((_) async => 'old_refresh_token');
      when(() => mockRemoteDataSource.refreshToken('old_refresh_token'))
          .thenAnswer((_) async => {
                'accessToken': 'new_access_token',
                'refreshToken': 'new_refresh_token',
              });
      when(() => mockLocalDataSource.saveTokens(
            accessToken: 'new_access_token',
            refreshToken: 'new_refresh_token',
          )).thenAnswer((_) async => {});
      when(() => mockLocalDataSource.getSavedUser())
          .thenAnswer((_) async => tUserModel.copyWithTokens(
                accessToken: 'new_access_token',
                refreshToken: 'new_refresh_token',
              ));

      final result = await repository.refreshToken();

      expect(result.accessToken, equals('new_access_token'));
      expect(result.refreshToken, equals('new_refresh_token'));
      verify(() => mockLocalDataSource.getRefreshToken()).called(1);
      verify(() => mockRemoteDataSource.refreshToken('old_refresh_token')).called(1);
      verify(() => mockLocalDataSource.saveTokens(
            accessToken: 'new_access_token',
            refreshToken: 'new_refresh_token',
          )).called(1);
    });

    test('devrait lever AuthFailure si aucun refresh token n\'est stocké en local', () async {
      when(() => mockLocalDataSource.getRefreshToken())
          .thenAnswer((_) async => null);

      expect(
        () => repository.refreshToken(),
        throwsA(isA<AuthFailure>()),
      );
    });

    test('devrait lever AuthFailure si le serveur distant échoue lors du refresh', () async {
      when(() => mockLocalDataSource.getRefreshToken())
          .thenAnswer((_) async => 'expired_refresh_token');
      when(() => mockRemoteDataSource.refreshToken('expired_refresh_token'))
          .thenThrow(ServerException(message: 'Token invalide ou expiré'));

      expect(
        () => repository.refreshToken(),
        throwsA(isA<AuthFailure>()),
      );
    });
  });
}
