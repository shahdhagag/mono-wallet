import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignInUseCase {
  const SignInUseCase(this.repository);

  final AuthRepository repository;

  Future<User> call({required String email, required String password}) {
    return repository.signIn(email: email, password: password);
  }
}