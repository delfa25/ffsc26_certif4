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

  group('AuthRepositoryImpl', () {
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

    test('devrait lever AuthFailure lorsque le serveur renvoie une erreur', () async {
      when(() => mockRemoteDataSource.login('wrong', 'wrong'))
          .thenThrow(ServerException(message: 'Identifiants invalides'));

      expect(
        () => repository.login('wrong', 'wrong'),
        throwsA(isA<AuthFailure>()),
      );
    });
  });
}
