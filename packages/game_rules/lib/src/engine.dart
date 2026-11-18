import 'dart:math' as math;

import 'model.dart';

class MoveResult {
  const MoveResult(
    this.state, {
    this.clearedCells = const [],
    this.clearedLines = 0,
  });
  final GameState state;
  final List<int> clearedCells;
  final int clearedLines;
}

class InvalidMove implements Exception {
  const InvalidMove(this.reason);
  final String reason;
  @override
  String toString() => 'InvalidMove($reason)';
}

class RulesEngine {
  const RulesEngine({this.maxMoves});
  final int? maxMoves;

  MoveResult play(
    GameState state,
    Placement move, {
    List<Piece>? refill,
    int? refillRng,
  }) {
    if (maxMoves != null && state.moveCount >= maxMoves!)
      throw const InvalidMove('move_cap');
    if (move.slot < 0 || move.slot >= 3) throw const InvalidMove('slot');
    if (state.moveCount < 0) throw const InvalidMove('move_count');
    final piece = state.tray[move.slot];
    if (piece == null) throw const InvalidMove('used_slot');
    if (!state.canPlace(piece, move.row, move.col))
      throw const InvalidMove('placement');

    final board = List<int>.of(state.board);
    for (var y = 0; y < piece.height; y++) {
      for (var x = 0; x < piece.width; x++) {
        if (piece.hasCell(y, x))
          board[(move.row + y) * 8 + move.col + x] = piece.color;
      }
    }
    final rows = <int>{};
    final cols = <int>{};
    for (var row = 0; row < 8; row++) {
      if (List<int>.generate(
        8,
        (col) => board[row * 8 + col],
      ).every((cell) => cell >= 0))
        rows.add(row);
    }
    for (var col = 0; col < 8; col++) {
      if (List<int>.generate(
        8,
        (row) => board[row * 8 + col],
      ).every((cell) => cell >= 0))
        cols.add(col);
    }
    final cleared = <int>{};
    for (final row in rows) {
      for (var col = 0; col < 8; col++) {
        cleared.add(row * 8 + col);
      }
    }
    for (final col in cols) {
      for (var row = 0; row < 8; row++) {
        cleared.add(row * 8 + col);
      }
    }
    for (final index in cleared) {
      board[index] = -1;
    }

    final lines = rows.length + cols.length;
    final chain = lines == 0 ? 0 : state.chain + 1;
    final delta =
        piece.cellCount +
        10 * lines +
        5 * lines * (lines - 1) +
        (lines == 0 ? 0 : 3 * math.min(9, chain - 1));
    var tray = List<Piece?>.of(state.tray)..[move.slot] = null;
    var rng = state.rng;
    if (tray.every((item) => item == null)) {
      if (refill == null || refill.length != 3 || refillRng == null) {
        throw const InvalidMove('refill_required');
      }
      tray = List<Piece?>.of(refill);
      if (!tray.every((item) => item != null))
        throw const InvalidMove('refill');
      rng = refillRng & 0xffffffff;
    }
    final next = GameState(
      board: board,
      tray: tray,
      score: state.score + delta.toInt(),
      chain: chain,
      best: math.max(state.best, state.score + delta.toInt()),
      rng: rng,
      moveCount: state.moveCount + 1,
    );
    return MoveResult(
      next,
      clearedCells: cleared.toList()..sort(),
      clearedLines: lines,
    );
  }
}
