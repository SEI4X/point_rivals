import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:point_rivals/features/profile/domain/profile_models.dart';

abstract final class UserProfileMapper {
  static UserProfile fromFirestore({
    required String id,
    required Map<String, Object?> data,
  }) {
    return UserProfile(
      id: id,
      displayName: _string(data['displayName']) ?? '',
      avatarUrl: _string(data['avatarUrl']),
      isActive: _bool(data['isActive']) ?? true,
      xp: _int(data['xp']),
      totalWagers: _int(data['totalWagers']),
      correctWagers: _int(data['correctWagers']),
      totalTokensEarned: _int(data['totalTokensEarned']),
      notificationsEnabled: _bool(data['notificationsEnabled']) ?? false,
      themePreference: _themePreference(data['themePreference']),
    );
  }

  static Map<String, Object?> toFirestore(UserProfile profile) {
    return {
      'displayName': profile.displayName,
      'avatarUrl': profile.avatarUrl,
      'isActive': profile.isActive,
      'xp': profile.xp,
      'totalWagers': profile.totalWagers,
      'correctWagers': profile.correctWagers,
      'totalTokensEarned': profile.totalTokensEarned,
      'notificationsEnabled': profile.notificationsEnabled,
      'themePreference': profile.themePreference.name,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static Map<String, Object?> newUserFirestoreData({
    required String displayName,
    required String? avatarUrl,
  }) {
    return {
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'isActive': true,
      'xp': 0,
      'totalWagers': 0,
      'correctWagers': 0,
      'totalTokensEarned': 0,
      'notificationsEnabled': false,
      'themePreference': AppThemePreference.system.name,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static String? _string(Object? value) => value is String ? value : null;

  static bool? _bool(Object? value) => value is bool ? value : null;

  static int _int(Object? value) => value is int ? value : 0;

  static AppThemePreference _themePreference(Object? value) {
    return AppThemePreference.values.firstWhere(
      (preference) => preference.name == value,
      orElse: () => AppThemePreference.system,
    );
  }
}
