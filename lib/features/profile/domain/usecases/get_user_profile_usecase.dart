import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class GetUserProfileUseCase {
  const GetUserProfileUseCase(this.repository);

  final ProfileRepository repository;

  Future<UserProfile> call() {
    return repository.getProfile();
  }
}