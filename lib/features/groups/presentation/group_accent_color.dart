import 'package:flutter/material.dart';
import 'package:point_rivals/features/groups/domain/group_accent_colors.dart';
import 'package:point_rivals/features/groups/domain/group_models.dart';

extension GroupAccentColor on RivalGroup {
  Color get accentColor => Color(accentColorValue);
}

Color onGroupAccentColor(Color color) {
  return color.computeLuminance() > 0.55 ? Colors.black : Colors.white;
}

ThemeData groupAccentTheme(BuildContext context, Color accentColor) {
  final baseTheme = Theme.of(context);
  final textTheme = baseTheme.textTheme;
  final onAccentColor = onGroupAccentColor(accentColor);
  final colorScheme = baseTheme.colorScheme.copyWith(
    primary: accentColor,
    onPrimary: onAccentColor,
    primaryContainer: accentColor,
    onPrimaryContainer: onAccentColor,
  );
  final radius = BorderRadius.circular(18);

  return baseTheme.copyWith(
    colorScheme: colorScheme,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        foregroundColor: onAccentColor,
        backgroundColor: accentColor,
        disabledBackgroundColor: colorScheme.surfaceContainerHighest,
        disabledForegroundColor: colorScheme.onSurfaceVariant,
        textStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(borderRadius: radius),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        foregroundColor: accentColor,
        side: BorderSide(color: colorScheme.outline),
        textStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(borderRadius: radius),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accentColor,
        textStyle: textTheme.labelMedium,
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: accentColor,
        minimumSize: const Size.square(40),
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      highlightElevation: 0,
      backgroundColor: accentColor,
      foregroundColor: onAccentColor,
      shape: RoundedRectangleBorder(borderRadius: radius),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        backgroundColor: colorScheme.surfaceContainer,
        foregroundColor: colorScheme.onSurfaceVariant,
        selectedBackgroundColor: accentColor,
        selectedForegroundColor: onAccentColor,
        side: BorderSide(color: colorScheme.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: radius),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(0, 34),
        visualDensity: VisualDensity.compact,
        textStyle: textTheme.labelMedium,
      ),
    ),
    listTileTheme: baseTheme.listTileTheme.copyWith(iconColor: accentColor),
    progressIndicatorTheme: baseTheme.progressIndicatorTheme.copyWith(
      color: accentColor,
      linearTrackColor: colorScheme.surfaceContainerHighest,
      circularTrackColor: colorScheme.surfaceContainerHighest,
    ),
  );
}

List<Color> groupAccentColorOptions() {
  return GroupAccentColors.values.map(Color.new).toList(growable: false);
}
