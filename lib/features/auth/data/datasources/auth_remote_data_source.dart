class AuthRemoteDataSource {
  const AuthRemoteDataSource();

  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    return <String, dynamic>{
      'id': '1',
      'name': 'Mono Wallet User',
      'email': email,
    };
  }
}