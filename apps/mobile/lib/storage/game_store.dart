import 'dart:convert';

import 'package:sqflite_common/sqlite_api.dart';

import 'database_factory_stub.dart'
    if (dart.library.io) 'database_factory_io.dart'
    if (dart.library.js_interop) 'database_factory_web.dart';

class GameStore {
  GameStore._(this._database);
  final Database _database;

  static Future<GameStore> open({
    DatabaseFactory? databaseFactory,
    String? path,
  }) async {
    final factory = databaseFactory ?? createDatabaseFactory();
    final databasePathValue = path ?? await databasePath();
    final database = await factory.openDatabase(
      databasePathValue,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE game_snapshots (
              id INTEGER PRIMARY KEY CHECK (id = 1),
              revision INTEGER NOT NULL,
              rules_version INTEGER NOT NULL,
              payload TEXT NOT NULL
            )
          ''');
        },
      ),
    );
    return GameStore._(database);
  }

  Future<Map<String, dynamic>?> load() async {
    final rows = await _database.query(
      'game_snapshots',
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return {
      'rulesVersion': rows.single['rules_version'],
      ...jsonDecode(rows.single['payload'] as String) as Map<String, dynamic>,
    };
  }

  Future<void> save(
    Map<String, Object?> payload, {
    required int rulesVersion,
  }) async {
    await _database.transaction((transaction) async {
      final rows = await transaction.query(
        'game_snapshots',
        columns: ['revision'],
        where: 'id = ?',
        whereArgs: [1],
        limit: 1,
      );
      final revision = rows.isEmpty ? 1 : (rows.single['revision'] as int) + 1;
      await transaction.insert('game_snapshots', {
        'id': 1,
        'revision': revision,
        'rules_version': rulesVersion,
        'payload': jsonEncode(payload),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<void> close() => _database.close();
}
