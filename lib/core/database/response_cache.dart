import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

/// A cached payload plus how old it is, so the UI can say "showing data from
/// 10 minutes ago" rather than silently presenting stale numbers as live.
class CachedPayload {
  const CachedPayload({required this.json, required this.updatedAt});

  final Map<String, dynamic> json;
  final DateTime updatedAt;

  Duration get age => DateTime.now().difference(updatedAt);
}

/// The offline-first read path: repositories write through on every success
/// and fall back here when the network is unavailable.
///
/// Keys are logical request names — see [CacheKeys].
abstract interface class ResponseCache {
  Future<CachedPayload?> read(String key);
  Future<void> write(String key, Map<String, dynamic> json);
  Future<void> clear();
}

class CacheKeys {
  const CacheKeys._();

  static const dashboardSummary = 'dashboard.summary';
  static const callsToday = 'calls.today';
  static const team = 'team.snapshot';
  static String rep(String code) => 'team.rep.$code';
}

class DriftResponseCache implements ResponseCache {
  const DriftResponseCache(this._db);

  final AppDatabase _db;

  @override
  Future<CachedPayload?> read(String key) async {
    final row = await _db.read(key);
    if (row == null) return null;
    try {
      final decoded = jsonDecode(row.payload);
      if (decoded is! Map<String, dynamic>) return null;
      return CachedPayload(json: decoded, updatedAt: row.updatedAt);
    } on FormatException {
      // A corrupt row must not take the screen down — treat it as a miss.
      return null;
    }
  }

  @override
  Future<void> write(String key, Map<String, dynamic> json) =>
      _db.write(key, jsonEncode(json));

  @override
  Future<void> clear() => _db.clearAll();
}

/// No-op cache, used on platforms without a database and in tests that do not
/// care about caching. Reads always miss, writes are dropped.
class NoopResponseCache implements ResponseCache {
  const NoopResponseCache();

  @override
  Future<CachedPayload?> read(String key) async => null;

  @override
  Future<void> write(String key, Map<String, dynamic> json) async {}

  @override
  Future<void> clear() async {}
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final responseCacheProvider = Provider<ResponseCache>((ref) {
  return DriftResponseCache(ref.watch(appDatabaseProvider));
});
