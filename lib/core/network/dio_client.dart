import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_config.dart';
import '../services/token_store.dart';

/// Builds the shared Dio instance. Interceptors (auth, error, logging) live
/// here so cross-cutting concerns stay in ONE place — see the Technical
/// Development Report §6.
///
/// NOTE: only used once [AppConfig.useMockData] is false. Until the real
/// endpoints arrive the *MockDataSource classes are used instead.
class DioClient {
  /// [readToken] is called per-request so a token refreshed mid-session is
  /// picked up without rebuilding the client.
  static Dio create({required Future<String?> Function() readToken}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        contentType: 'application/json',
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (e, handler) {
          // TODO(real-api): on 401, refresh the token and retry once, then
          // sign the user out if the refresh fails (report §6.1).
          handler.next(e);
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }

    // TODO(real-api): add a retry interceptor with exponential backoff.
    return dio;
  }
}

final dioProvider = Provider<Dio>((ref) {
  final tokens = ref.watch(tokenStoreProvider);
  return DioClient.create(readToken: tokens.read);
});
