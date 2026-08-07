import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// One cached server response, keyed by the logical request it answers.
///
/// Deliberately a key/value store of JSON rather than typed tables per screen:
/// the client's data structure is still unconfirmed, so typed columns would be
/// rewritten the moment the real API lands. This shape survives that change,
/// and the same `fromJson` that parses a live response parses the cached one.
///
/// TODO(real-api): once the schema is fixed, promote the hot paths (dashboard
/// summary, visit list) to typed tables so they can be queried and partially
/// updated rather than replaced wholesale.
class CachedResponses extends Table {
  /// Logical request key, e.g. `dashboard.summary` or `calls.today`.
  TextColumn get key => text()();

  /// The response body, as returned by the API.
  TextColumn get payload => text()();

  /// When this copy was written, used to show "last updated" and to expire.
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [CachedResponses])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_open());

  /// Test constructor — pass `NativeDatabase.memory()`.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  Future<CachedResponse?> read(String key) {
    return (select(cachedResponses)..where((t) => t.key.equals(key)))
        .getSingleOrNull();
  }

  Future<void> write(String key, String payload) {
    return into(cachedResponses).insertOnConflictUpdate(
      CachedResponsesCompanion.insert(
        key: key,
        payload: payload,
        updatedAt: DateTime.now(),
      ),
    );
  }

  /// Wipes every cached response. Called on sign-out so the next user cannot
  /// see the previous user's data.
  Future<void> clearAll() => delete(cachedResponses).go();
}

QueryExecutor _open() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'eway_cache.sqlite'));
    // TODO(real-api): swap NativeDatabase for sqlcipher_flutter_libs and key
    // the database before any real patient//customer data is cached
    // (report §7). The dependency is already listed in pubspec.
    return NativeDatabase.createInBackground(file);
  });
}
