import 'package:flutter_test/flutter_test.dart';
import 'package:kombelo/storage/game_store.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test('snapshot upsert is atomic and can be restored', () async {
    final store = await GameStore.open(
      databaseFactory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    addTearDown(store.close);
    final state = {
      'board': List<int>.filled(64, -1),
      'tray': [
        {
          'id': 'dot',
          'mask': ['#'],
          'color': 2,
          'rotation': 0,
        },
        null,
        null,
      ],
      'score': 99,
      'chain': 3,
      'best': 99,
      'rng': 21,
      'moveCount': 1,
    };

    await store.save({'state': state, 'best': 99}, rulesVersion: 1);
    await store.save({
      'state': {...state, 'score': 100},
      'best': 100,
    }, rulesVersion: 1);
    final saved = await store.load();
    expect(saved?['rulesVersion'], 1);
    expect(saved?['state']['score'], 100);
    expect(saved?['best'], 100);
  });
}
