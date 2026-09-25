import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RefreshTokenUseCase {
  final AuthRepository repository;

  RefreshTokenUseCase(this.repository);

  Future<User> call() async {
    return await repository.refreshToken();
  }
}
