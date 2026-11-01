import '../domain/entities/user_profile.dart';

class ProfileLocalDataSource {
  const ProfileLocalDataSource();

  Future<UserProfile> getCachedProfile() async {
    return const UserProfile(
      name: 'Mono Wallet User',
      email: 'user@mono.com',
    );
  }
}