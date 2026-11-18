import 'dart:io';

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

  test('committed snapshot survives database close and reopen', () async {
    final directory = await Directory.systemTemp.createTemp(
      'kombelo-store-test-',
    );
    final path = '${directory.path}/game.sqlite';
    try {
      final first = await GameStore.open(
        databaseFactory: databaseFactoryFfi,
        path: path,
      );
      await first.save({
        'state': {
          'board': List<int>.filled(64, -1),
          'tray': [null, null, null],
          'score': 37,
          'chain': 3,
          'best': 37,
          'rng': 962054837,
          'moveCount': 4,
        },
        'best': 37,
      }, rulesVersion: 1);
      await first.close();

      final reopened = await GameStore.open(
        databaseFactory: databaseFactoryFfi,
        path: path,
      );
      final restored = await reopened.load();
      expect(restored?['rulesVersion'], 1);
      expect(restored?['state']['score'], 37);
      expect(restored?['state']['rng'], 962054837);
      expect(restored?['state']['moveCount'], 4);
      await reopened.close();
    } finally {
      await directory.delete(recursive: true);
    }
  });
}
