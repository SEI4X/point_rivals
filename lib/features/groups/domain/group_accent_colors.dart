abstract final class GroupAccentColors {
  static const int defaultValue = 0xFFFFD426;

  static const List<int> values = [
    defaultValue,
    0xFFFF3B64,
    0xFFFF2D55,
    0xFFFF9F0A,
    0xFFFF6B35,
    0xFFA3E635,
    0xFF34C759,
    0xFF2DD4BF,
    0xFF64D2FF,
    0xFF0A84FF,
    0xFF5E5CE6,
    0xFFBF5AF2,
  ];

  static bool contains(int value) => values.contains(value);

  static int normalize(int? value) {
    if (value == null || !contains(value)) {
      return defaultValue;
    }

    return value;
  }
}
