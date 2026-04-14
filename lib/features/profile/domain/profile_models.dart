enum AppThemePreference { system, light, dark }

final class UserProfile {
  const UserProfile({
    required this.id,
    required this.displayName,
    required this.avatarUrl,
    required this.isActive,
    required this.xp,
    required this.totalWagers,
    required this.correctWagers,
    required this.totalTokensEarned,
    required this.notificationsEnabled,
    required this.themePreference,
  });

  final String id;
  final String displayName;
  final String? avatarUrl;
  final bool isActive;
  final int xp;
  final int totalWagers;
  final int correctWagers;
  final int totalTokensEarned;
  final bool notificationsEnabled;
  final AppThemePreference themePreference;

  double get correctWagerRate {
    if (totalWagers == 0) {
      return 0;
    }

    return correctWagers / totalWagers;
  }
}
