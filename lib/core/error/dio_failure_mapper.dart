import 'package:dio/dio.dart';

import 'failures.dart';

/// Maps a Dio transport error onto the app's typed [Failure]s.
///
/// Shared across features so every repository classifies network problems the
/// same way — a 401 must mean the same thing on Reports as it does on the
/// dashboard.
///
/// TODO(real-api): once Drift is wired, a NetworkFailure should fall back to
/// the cached copy rather than surfacing (report §5, offline-first).
Failure mapDioError(DioException e) {
  return switch (e.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.connectionError =>
      const NetworkFailure(),
    DioExceptionType.badResponse => e.response?.statusCode == 401
        ? const AuthFailure()
        : const ServerFailure(),
    _ => const ServerFailure(),
  };
}
