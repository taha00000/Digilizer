import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eway/core/error/failures.dart';
import 'package:eway/features/dashboard/data/datasources/dashboard_datasource.dart';
import 'package:eway/features/dashboard/data/datasources/dashboard_mock_datasource.dart';
import 'package:eway/features/dashboard/data/models/dashboard_summary_model.dart';
import 'package:eway/features/dashboard/data/repositories/dashboard_repository_impl.dart';

class _ThrowingDataSource implements DashboardDataSource {
  _ThrowingDataSource(this.error);
  final Object error;

  @override
  Future<DashboardSummaryModel> getSummary() async => throw error;
}

DioException _dio(DioExceptionType type, {int? status}) => DioException(
      requestOptions: RequestOptions(path: '/dashboard/summary'),
      type: type,
      response: status == null
          ? null
          : Response<dynamic>(
              requestOptions: RequestOptions(path: '/dashboard/summary'),
              statusCode: status,
            ),
    );

void main() {
  test('returns the summary from the datasource', () async {
    final repo = DashboardRepositoryImpl(DashboardMockDataSource());
    final res = await repo.getSummary();

    expect(res.isRight(), isTrue);
    res.fold(
      (_) => fail('expected a summary'),
      (s) {
        expect(s.achievementPct, 58);
        expect(s.topBrands.first.name, 'Vlep');
        expect(s.salesMix.length, 4);
      },
    );
  });

  group('error mapping', () {
    test('connection problems become NetworkFailure', () async {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.connectionError,
      ]) {
        final repo = DashboardRepositoryImpl(_ThrowingDataSource(_dio(type)));
        final res = await repo.getSummary();
        res.fold(
          (f) => expect(f, isA<NetworkFailure>(), reason: '$type'),
          (_) => fail('expected a failure for $type'),
        );
      }
    });

    test('401 becomes AuthFailure', () async {
      final repo = DashboardRepositoryImpl(
        _ThrowingDataSource(_dio(DioExceptionType.badResponse, status: 401)),
      );
      final res = await repo.getSummary();
      res.fold((f) => expect(f, isA<AuthFailure>()), (_) => fail('expected'));
    });

    test('500 becomes ServerFailure', () async {
      final repo = DashboardRepositoryImpl(
        _ThrowingDataSource(_dio(DioExceptionType.badResponse, status: 500)),
      );
      final res = await repo.getSummary();
      res.fold((f) => expect(f, isA<ServerFailure>()), (_) => fail('expected'));
    });

    test('an unexpected error becomes ServerFailure', () async {
      final repo =
          DashboardRepositoryImpl(_ThrowingDataSource(Exception('boom')));
      final res = await repo.getSummary();
      res.fold((f) => expect(f, isA<ServerFailure>()), (_) => fail('expected'));
    });
  });
}
