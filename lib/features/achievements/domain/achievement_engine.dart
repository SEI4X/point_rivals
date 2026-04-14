import 'package:point_rivals/features/achievements/domain/achievement_catalog.dart';
import 'package:point_rivals/features/achievements/domain/achievement_models.dart';
import 'package:point_rivals/features/profile/domain/profile_models.dart';
import 'package:point_rivals/features/profile/domain/xp_progression.dart';

final class AchievementEngine {
  const AchievementEngine({
    this.catalog = AchievementCatalog.all,
    this.xpProgression = const XpProgression(),
  });

  final List<AchievementDefinition> catalog;
  final XpProgression xpProgression;

  AchievementStats statsForProfile(UserProfile profile) {
    return AchievementStats(
      totalWagers: profile.totalWagers,
      correctWagers: profile.correctWagers,
      totalTokensEarned: profile.totalTokensEarned,
      level: xpProgression.levelForXp(profile.xp),
    );
  }

  List<AchievementCardModel> cardsForProfile(
    UserProfile profile, {
    Set<AchievementId> earnedIds = const {},
  }) {
    return cardsForStats(statsForProfile(profile), earnedIds: earnedIds);
  }

  List<AchievementCardModel> cardsForStats(
    AchievementStats stats, {
    Set<AchievementId> earnedIds = const {},
  }) {
    final cards = catalog.map((definition) {
      return AchievementCardModel(
        definition: definition,
        progressValue: _progressValue(definition.requirementKind, stats),
        isStoredEarned: earnedIds.contains(definition.id),
      );
    }).toList();

    cards.sort((left, right) {
      return left.definition.rank.compareTo(right.definition.rank);
    });

    return cards;
  }

  List<AchievementCardModel> nearestLocked(
    List<AchievementCardModel> cards, {
    int limit = 5,
  }) {
    final locked = cards.where((card) => !card.isEarned).toList();
    locked.sort((left, right) {
      final progressComparison = right.progressFraction.compareTo(
        left.progressFraction,
      );
      if (progressComparison != 0) {
        return progressComparison;
      }

      return left.definition.rank.compareTo(right.definition.rank);
    });

    return locked.take(limit).toList();
  }

  int earnedCount(List<AchievementCardModel> cards) {
    return cards.where((card) => card.isEarned).length;
  }

  int _progressValue(
    AchievementRequirementKind requirementKind,
    AchievementStats stats,
  ) {
    return switch (requirementKind) {
      AchievementRequirementKind.totalWagers => stats.totalWagers,
      AchievementRequirementKind.correctWagers => stats.correctWagers,
      AchievementRequirementKind.earnedChips => stats.totalTokensEarned,
      AchievementRequirementKind.level => stats.level,
    };
  }
}
