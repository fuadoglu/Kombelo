import 'package:game_rules/game_rules.dart';

void main() {
  const rng = VersionedRng();
  print('seed 1 -> ${rng.next(1)}');
}
