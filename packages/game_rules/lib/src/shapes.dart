import 'dart:convert';

import 'model.dart';

class ShapeCatalog {
  ShapeCatalog.fromJson(Map<String, dynamic> json)
    : _shapes = List.unmodifiable(
        (json['catalog'] as List<dynamic>).map((raw) {
          final shape = raw as Map<String, dynamic>;
          return ShapeDefinition(
            shape['id'] as String,
            shape['weight'] as int,
            (shape['mask'] as List<dynamic>).cast<String>(),
          );
        }),
      ) {
    final ids = <String>{};
    if (_shapes.isEmpty ||
        _shapes.any((shape) {
          final mask = shape.mask;
          final validMask =
              mask.isNotEmpty &&
              mask.length <= 8 &&
              mask.first.isNotEmpty &&
              mask.first.length <= 8 &&
              mask.every(
                (row) =>
                    row.length == mask.first.length &&
                    RegExp(r'^[.#]+$').hasMatch(row),
              ) &&
              mask.any((row) => row.contains('#'));
          return shape.id.isEmpty ||
              !ids.add(shape.id) ||
              shape.weight <= 0 ||
              !validMask;
        })) {
      throw const FormatException(
        'Invalid shape catalog: ids, weights, or masks.',
      );
    }
  }

  factory ShapeCatalog.decode(String source) =>
      ShapeCatalog.fromJson(jsonDecode(source) as Map<String, dynamic>);

  final List<ShapeDefinition> _shapes;
  int get totalWeight => _shapes.fold(0, (sum, shape) => sum + shape.weight);
  List<String> get ids => List.unmodifiable(_shapes.map((shape) => shape.id));
  int get weightTotal => totalWeight;
  List<ShapeDefinition> get shapes => List.unmodifiable(_shapes);

  Piece pieceForIndex(int index, {required int color}) {
    if (index < 0 || index >= _shapes.length)
      throw RangeError.index(index, _shapes);
    final shape = _shapes[index];
    return Piece(id: shape.id, mask: shape.mask, color: color);
  }
}

class ShapeDefinition {
  const ShapeDefinition(this.id, this.weight, this.mask);
  final String id;
  final int weight;
  final List<String> mask;
}
