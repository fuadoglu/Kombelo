class VersionedRng {
  const VersionedRng();

  static const int mask = 0xffffffff;
  static const int zeroReplacement = 1831565813;

  int next(int state) {
    var value = state == 0 ? zeroReplacement : state & mask;
    value = (value ^ ((value << 13) & mask)) & mask;
    value = (value ^ (value >> 17)) & mask;
    value = (value ^ ((value << 5) & mask)) & mask;
    return value;
  }
}
