import 'package:flutter_test/flutter_test.dart';
import 'package:point_rivals/features/achievements/domain/achievement_engine.dart';
import 'package:point_rivals/features/achievements/domain/achievement_models.dart';
import 'package:point_rivals/features/profile/domain/profile_models.dart';

void main() {
  const engine = AchievementEngine();

  UserProfile profile({
    int xp = 0,
    int totalWagers = 0,
    int correctWagers = 0,
    int totalTokensEarned = 0,
  }) {
    return UserProfile(
      id: 'user-1',
      displayName: 'Alex',
      avatarUrl: null,
      isActive: true,
      xp: xp,
      totalWagers: totalWagers,
      correctWagers: correctWagers,
      totalTokensEarned: totalTokensEarned,
      notificationsEnabled: false,
      themePreference: AppThemePreference.system,
    );
  }

  test('builds achievement cards from profile statistics', () {
    final cards = engine.cardsForProfile(
      profile(xp: 35, totalWagers: 5, correctWagers: 1, totalTokensEarned: 120),
    );

    final firstWager = cards.firstWhere(
      (card) => card.id == AchievementId.firstWager,
    );
    final fiveWagers = cards.firstWhere(
      (card) => card.id == AchievementId.fiveWagers,
    );
    final levelTwo = cards.firstWhere(
      (card) => card.id == AchievementId.levelTwo,
    );

    expect(firstWager.isEarned, isTrue);
    expect(fiveWagers.isEarned, isTrue);
    expect(levelTwo.isEarned, isTrue);
  });

  test('orders nearest locked achievements by progress', () {
    final cards = engine.cardsForProfile(profile(totalWagers: 4));

    final nearest = engine.nearestLocked(cards, limit: 1);

    expect(nearest.single.id, AchievementId.fiveWagers);
  });

  test('counts earned achievements', () {
    final cards = engine.cardsForProfile(profile(totalWagers: 1));

    expect(engine.earnedCount(cards), 1);
  });

  test('keeps stored achievements unlocked across devices', () {
    final cards = engine.cardsForProfile(
      profile(),
      earnedIds: {AchievementId.fiveWagers},
    );
    final fiveWagers = cards.firstWhere(
      (card) => card.id == AchievementId.fiveWagers,
    );

    expect(fiveWagers.isEarned, isTrue);
    expect(fiveWagers.isCurrentlyEarned, isFalse);
  });
}
