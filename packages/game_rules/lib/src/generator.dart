import 'model.dart';
import 'rng.dart';
import 'shapes.dart';

class GeneratedTray {
  const GeneratedTray(this.pieces, this.rng);
  final List<Piece> pieces;
  final int rng;
}

class PieceGenerator {
  const PieceGenerator(this.catalog, {this.rng = const VersionedRng()});
  final ShapeCatalog catalog;
  final VersionedRng rng;

  GeneratedTray drawTray(int seed, {int paletteSize = 5}) {
    if (paletteSize <= 0) throw ArgumentError.value(paletteSize, 'paletteSize');
    var value = seed == 0
        ? VersionedRng.zeroReplacement
        : seed & VersionedRng.mask;
    final pieces = <Piece>[];
    for (var slot = 0; slot < 3; slot++) {
      value = rng.next(value);
      var sample = value % catalog.totalWeight;
      var index = 0;
      for (; index < catalog.shapes.length; index++) {
        final shape = catalog.shapes[index];
        if (sample < shape.weight) break;
        sample -= shape.weight;
      }
      final shape = catalog.shapes[index];
      value = rng.next(value);
      final orientations = _rotations(shape.mask);
      final rotation = value % orientations.length;
      value = rng.next(value);
      final color = value % paletteSize;
      pieces.add(
        Piece(
          id: shape.id,
          mask: orientations[rotation],
          color: color,
          rotation: rotation,
        ),
      );
    }
    return GeneratedTray(List.unmodifiable(pieces), value);
  }

  List<List<String>> _rotations(List<String> mask) {
    final result = <List<String>>[];
    var current = List<String>.of(mask);
    for (var turn = 0; turn < 4; turn++) {
      final trimmed = _trim(current);
      if (!result.any((candidate) => _same(candidate, trimmed)))
        result.add(trimmed);
      current = List.generate(
        current.first.length,
        (col) => List.generate(
          current.length,
          (row) => current[current.length - 1 - row][col],
        ).join(),
      );
    }
    return result;
  }

  List<String> _trim(List<String> mask) {
    var top = 0, bottom = mask.length, left = 0, right = mask.first.length;
    while (top < bottom && !mask[top].contains('#')) {
      top++;
    }
    while (bottom > top && !mask[bottom - 1].contains('#')) {
      bottom--;
    }
    while (left < right && mask.every((row) => row[left] != '#')) {
      left++;
    }
    while (right > left && mask.every((row) => row[right - 1] != '#')) {
      right--;
    }
    return List.unmodifiable(
      mask.sublist(top, bottom).map((row) => row.substring(left, right)),
    );
  }

  bool _same(List<String> left, List<String> right) =>
      left.length == right.length &&
      List.generate(
        left.length,
        (row) => left[row] == right[row],
      ).every((same) => same);
}
