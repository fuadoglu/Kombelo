import 'dart:convert';
import 'dart:io';

import 'package:game_rules/game_rules.dart';
import 'package:test/test.dart';

final root = Directory.current.parent.parent;
final rules = jsonDecode(
  File('${root.path}/contracts/game-v1.json').readAsStringSync(),
) as Map<String, dynamic>;
final vectors = jsonDecode(
  File('${root.path}/contracts/game-v1-vectors.json').readAsStringSync(),
) as Map<String, dynamic>;

void main() {
  group('v1 contracts', () {
    test('xorshift golden vector', () {
      final rng = VersionedRng();
      var state = 1;
      for (final expected in vectors['rngSeed1'] as List<dynamic>) {
        state = rng.next(state);
        expect(state, expected);
      }
    });

    test('score and line clear vectors', () {
      for (final raw in vectors['cases'] as List<dynamic>) {
        final item = raw as Map<String, dynamic>;
        if (item['error'] != null) continue;
        final board = (item['board'] as List<dynamic>)
            .join()
            .split('')
            .map((cell) => cell == '#' ? 0 : -1)
            .toList();
        final piece = Piece(
          id: 'fixture',
          mask: (item['piece'] as List<dynamic>).cast<String>(),
          color: 1,
        );
        final state = GameState(
          board: board,
          tray: [piece, null, null],
          score: 0,
          chain: item['chain'] as int,
          best: 0,
          rng: 1,
        );
        final result = const RulesEngine().play(
          state,
          Placement(0, item['row'] as int, item['col'] as int),
          refill: [piece, piece, piece],
          refillRng: 2,
        );
        final expected = item['expected'] as Map<String, dynamic>;
        expect(
          result.clearedLines,
          (expected['rows'] as List).length + (expected['cols'] as List).length,
          reason: item['id'] as String,
        );
        expect(
          result.clearedCells.length,
          expected['distinctCleared'],
          reason: item['id'] as String,
        );
        expect(
          result.state.chain,
          expected['chain'],
          reason: item['id'] as String,
        );
        expect(
          result.state.score,
          expected['delta'],
          reason: item['id'] as String,
        );
      }
    });

    test('weighted generator consumes exactly two values per slot', () {
      final catalog = ShapeCatalog.fromJson(rules);
      final generated = PieceGenerator(catalog).drawTray(1);
      expect(generated.pieces, hasLength(3));
      expect(generated.rng, 2005365029);
      expect(generated.pieces.map((piece) => piece.id), ['el3', 'zag4', 'tee4']);
      expect(generated.pieces.map((piece) => piece.rotation), [1, 1, 2]);
      expect(generated.pieces.map((piece) => piece.color), [1, 4, 4]);
    });

    test('illegal placement leaves immutable game state untouched', () {
      final state = GameState(
        board: List.filled(64, -1),
        tray: [
          Piece(id: 'dot', mask: ['#'], color: 0),
          null,
          null,
        ],
        score: 0,
        chain: 0,
        best: 0,
        rng: 21,
      );
      expect(
        () => const RulesEngine().play(state, const Placement(0, 0, 8)),
        throwsA(isA<InvalidMove>()),
      );
      expect(state.score, 0);
      expect(state.rng, 21);
      expect(state.board.every((cell) => cell == -1), isTrue);
    });

    test('overlap and bounds errors from the contract are rejected', () {
      for (final raw in vectors['cases'] as List<dynamic>) {
        final item = raw as Map<String, dynamic>;
        if (item['error'] == null) continue;
        final board = (item['board'] as List<dynamic>)
            .join()
            .split('')
            .map((cell) => cell == '#' ? 0 : -1)
            .toList();
        final piece = Piece(
          id: 'fixture',
          mask: (item['piece'] as List<dynamic>).cast<String>(),
          color: 1,
        );
        final state = GameState(
          board: board,
          tray: [piece, null, null],
          score: 0,
          chain: 0,
          best: 0,
          rng: 1,
        );
        expect(
          () => const RulesEngine().play(
            state,
            Placement(0, item['row'] as int, item['col'] as int),
          ),
          throwsA(isA<InvalidMove>()),
          reason: item['id'] as String,
        );
      }
    });
  });

  test('catalog shape ids match the versioned rules contract', () {
    final catalog = rules['catalog'] as List<dynamic>;
    expect(
      catalog.map((shape) => (shape as Map)['id']),
      containsAll([
        'dot',
        'bar2',
        'bar3',
        'bar4',
        'bar5',
        'square2',
        'square3',
        'el3',
        'el5',
        'tee4',
        'zig4',
        'zag4',
      ]),
    );
  });
}
