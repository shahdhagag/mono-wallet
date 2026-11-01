class ServerException implements Exception {
  const ServerException([this.message = 'Server exception occurred']);

  final String message;
}

class CacheException implements Exception {
  const CacheException([this.message = 'Cache exception occurred']);

  final String message;
}