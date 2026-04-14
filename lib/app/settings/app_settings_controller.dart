import 'package:flutter/material.dart';
import 'package:point_rivals/features/profile/domain/profile_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsController extends ChangeNotifier {
  AppSettingsController._({
    required AppThemePreference initialThemePreference,
    SharedPreferencesAsync? preferences,
  }) : _themePreference = initialThemePreference,
       _preferences = preferences;

  factory AppSettingsController.memory({
    AppThemePreference initialThemePreference = AppThemePreference.dark,
  }) {
    return AppSettingsController._(
      initialThemePreference: initialThemePreference,
    );
  }

  static const String _themePreferenceKey = 'themePreference';

  final SharedPreferencesAsync? _preferences;
  AppThemePreference _themePreference;

  AppThemePreference get themePreference => _themePreference;

  ThemeMode get themeMode => switch (_themePreference) {
    AppThemePreference.system => ThemeMode.system,
    AppThemePreference.light => ThemeMode.light,
    AppThemePreference.dark => ThemeMode.dark,
  };

  static Future<AppSettingsController> load() async {
    final preferences = SharedPreferencesAsync();
    final storedTheme = await preferences.getString(_themePreferenceKey);

    return AppSettingsController._(
      initialThemePreference: _themePreferenceFromStorage(storedTheme),
      preferences: preferences,
    );
  }

  Future<void> setThemePreference(AppThemePreference preference) async {
    if (_themePreference == preference) {
      return;
    }

    _themePreference = preference;
    notifyListeners();
    await _preferences?.setString(_themePreferenceKey, preference.name);
  }

  static AppThemePreference _themePreferenceFromStorage(String? value) {
    return AppThemePreference.values.firstWhere(
      (preference) => preference.name == value,
      orElse: () => AppThemePreference.dark,
    );
  }
}

class AppSettingsScope extends InheritedNotifier<AppSettingsController> {
  const AppSettingsScope({
    required AppSettingsController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static AppSettingsController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AppSettingsScope>();
    assert(scope != null, 'AppSettingsScope is missing from the widget tree.');

    return scope!.notifier!;
  }
}
