import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/network/api_consumer.dart';

final GetIt serviceLocator = GetIt.instance;

void setupServiceLocator() {
  if (serviceLocator.isRegistered<Dio>()) {
    return;
  }

  serviceLocator.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        baseUrl: 'https://api.example.com',
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
      ),
    ),
  );

  serviceLocator.registerLazySingleton<ApiConsumer>(
    () => DioApiConsumer(serviceLocator<Dio>()),
  );

  // Supabase client — this is our database + auth access point
  serviceLocator.registerLazySingleton<SupabaseClient>(
    () => Supabase.instance.client,
  );
}