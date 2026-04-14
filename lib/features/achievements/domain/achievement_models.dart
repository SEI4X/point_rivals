enum AchievementId {
  firstWager,
  fiveWagers,
  twentyFiveWagers,
  hundredWagers,
  firstWin,
  fiveWins,
  twentyFiveWins,
  hundredWins,
  hundredChips,
  thousandChips,
  tenThousandChips,
  levelTwo,
  levelFive,
  levelTen,
  levelTwentyFive,
}

enum AchievementRequirementKind {
  totalWagers,
  correctWagers,
  earnedChips,
  level,
}

final class AchievementDefinition {
  const AchievementDefinition({
    required this.id,
    required this.requirementKind,
    required this.targetValue,
    required this.rank,
  });

  final AchievementId id;
  final AchievementRequirementKind requirementKind;
  final int targetValue;
  final int rank;
}

final class AchievementStats {
  const AchievementStats({
    required this.totalWagers,
    required this.correctWagers,
    required this.totalTokensEarned,
    required this.level,
  });

  final int totalWagers;
  final int correctWagers;
  final int totalTokensEarned;
  final int level;
}

final class AchievementCardModel {
  const AchievementCardModel({
    required this.definition,
    required this.progressValue,
    this.isStoredEarned = false,
  });

  final AchievementDefinition definition;
  final int progressValue;
  final bool isStoredEarned;

  AchievementId get id => definition.id;

  int get targetValue => definition.targetValue;

  bool get isCurrentlyEarned => progressValue >= targetValue;

  bool get isEarned => isStoredEarned || isCurrentlyEarned;

  double get progressFraction {
    if (isEarned) {
      return 1;
    }
    if (targetValue <= 0) {
      return 0;
    }

    return (progressValue / targetValue).clamp(0, 1);
  }
}
