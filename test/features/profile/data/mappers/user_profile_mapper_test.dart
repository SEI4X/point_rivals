import 'package:flutter_test/flutter_test.dart';
import 'package:point_rivals/features/profile/data/mappers/user_profile_mapper.dart';
import 'package:point_rivals/features/profile/domain/profile_models.dart';

void main() {
  test('maps Firestore data to user profile with safe defaults', () {
    final profile = UserProfileMapper.fromFirestore(
      id: 'user-1',
      data: const {
        'displayName': 'Alex',
        'isActive': true,
        'xp': 245,
        'totalWagers': 42,
        'correctWagers': 29,
        'totalTokensEarned': 3160,
        'notificationsEnabled': true,
        'themePreference': 'dark',
      },
    );

    expect(profile.id, 'user-1');
    expect(profile.displayName, 'Alex');
    expect(profile.themePreference, AppThemePreference.dark);
    expect(profile.correctWagerRate, closeTo(0.69, 0.01));
  });
}
