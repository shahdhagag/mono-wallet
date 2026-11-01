import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  @override
  Future<User> signIn({required String email, required String password}) async {
    final response = await remoteDataSource.signIn(
      email: email,
      password: password,
    );
    final user = UserModel.fromJson(response);
    await localDataSource.cacheAccessToken('mock-access-token');
    return user;
  }
}