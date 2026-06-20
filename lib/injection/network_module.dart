import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// Base URL for all API calls.
const String kBaseUrl = 'https://api.rt-rw-digital.example.com/v1';

@module
abstract class NetworkModule {
  @lazySingleton
  Dio get dio => Dio(
        BaseOptions(
          baseUrl: kBaseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
}
