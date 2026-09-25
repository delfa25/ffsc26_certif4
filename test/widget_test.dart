import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ffsc26_certif4/features/auth/presentation/screens/login_screen.dart';
import 'package:ffsc26_certif4/features/auth/presentation/providers/auth_provider.dart';
import 'package:ffsc26_certif4/features/auth/domain/usecases/login_usecase.dart';
import 'package:ffsc26_certif4/features/auth/domain/usecases/register_usecase.dart';
import 'package:ffsc26_certif4/features/auth/domain/usecases/logout_usecase.dart';
import 'package:ffsc26_certif4/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:ffsc26_certif4/features/auth/domain/repositories/auth_repository.dart';
import 'package:ffsc26_certif4/features/auth/domain/entities/user.dart';
import 'package:provider/provider.dart';

class DummyAuthRepository implements AuthRepository {
  @override
  Future<User> login(String username, String password) async => const User(
        id: 1,
        username: 'emilys',
        email: 'emily@dummy.com',
        firstName: 'Emily',
        lastName: 'Johnson',
        gender: 'female',
        image: '',
      );

  @override
  Future<User> register(String username, String email, String password) async => const User(
        id: 2,
        username: 'newUser',
        email: 'new@dummy.com',
        firstName: 'New',
        lastName: 'User',
        gender: 'male',
        image: '',
      );

  @override
  Future<User?> getSavedUser() async => null;

  @override
  Future<void> logout() async {}
}

void main() {
  testWidgets('LoginScreen displays title and fields', (WidgetTester tester) async {
    final repo = DummyAuthRepository();
    final authProvider = AuthProvider(
      loginUseCase: LoginUseCase(repo),
      registerUseCase: RegisterUseCase(repo),
      logoutUseCase: LogoutUseCase(repo),
      getCurrentUserUseCase: GetCurrentUserUseCase(repo),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: authProvider,
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    expect(find.text('Connexion'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
