class Piece {
  Piece({
    required this.id,
    required List<String> mask,
    required this.color,
    this.rotation = 0,
  }) : mask = List.unmodifiable(mask) {
    if (mask.isEmpty ||
        mask.any((row) => row.length != mask.first.length) ||
        !mask.any((row) => row.contains('#'))) {
      throw ArgumentError.value(
        mask,
        'mask',
        'must be a non-empty rectangular piece',
      );
    }
  }

  final String id;
  final List<String> mask;
  final int color;
  final int rotation;
  int get width => mask.first.length;
  int get height => mask.length;
  int get cellCount =>
      mask.fold(0, (sum, row) => sum + '#'.allMatches(row).length);
  bool hasCell(int row, int col) => mask[row][col] == '#';
}

class GameState {
  GameState({
    required List<int> board,
    required List<Piece?> tray,
    required this.score,
    required this.chain,
    required this.best,
    required this.rng,
    this.moveCount = 0,
  }) : board = List.unmodifiable(board),
       tray = List.unmodifiable(tray) {
    if (board.length != 64 ||
        tray.length != 3 ||
        board.any((cell) => cell < -1 || cell > 4)) {
      throw ArgumentError('Expected a 64-cell board and three tray slots.');
    }
  }

  final List<int> board; // -1 is empty, 0–4 are cosmetic palette indices.
  final List<Piece?> tray;
  final int score;
  final int chain;
  final int best;
  final int rng;
  final int moveCount;

  bool canPlace(Piece piece, int row, int col) {
    if (row < 0 || col < 0 || row + piece.height > 8 || col + piece.width > 8)
      return false;
    for (var y = 0; y < piece.height; y++) {
      for (var x = 0; x < piece.width; x++) {
        if (piece.hasCell(y, x) && board[(row + y) * 8 + col + x] >= 0)
          return false;
      }
    }
    return true;
  }

  GameState copyWith({
    List<int>? board,
    List<Piece?>? tray,
    int? score,
    int? chain,
    int? best,
    int? rng,
    int? moveCount,
  }) => GameState(
    board: board ?? this.board,
    tray: tray ?? this.tray,
    score: score ?? this.score,
    chain: chain ?? this.chain,
    best: best ?? this.best,
    rng: rng ?? this.rng,
    moveCount: moveCount ?? this.moveCount,
  );

  bool get hasLegalMove {
    for (final piece in tray.whereType<Piece>()) {
      for (var row = 0; row <= 8 - piece.height; row++) {
        for (var col = 0; col <= 8 - piece.width; col++) {
          if (canPlace(piece, row, col)) return true;
        }
      }
    }
    return false;
  }
}

class Placement {
  const Placement(this.slot, this.row, this.col);
  final int slot;
  final int row;
  final int col;
}
