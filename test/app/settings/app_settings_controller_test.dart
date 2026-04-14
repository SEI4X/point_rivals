import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:point_rivals/app/settings/app_settings_controller.dart';
import 'package:point_rivals/features/profile/domain/profile_models.dart';

void main() {
  test('maps saved theme preference to Flutter theme mode', () async {
    final controller = AppSettingsController.memory();

    expect(controller.themeMode, ThemeMode.dark);

    await controller.setThemePreference(AppThemePreference.light);

    expect(controller.themePreference, AppThemePreference.light);
    expect(controller.themeMode, ThemeMode.light);
  });
}
