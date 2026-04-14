import 'package:point_rivals/features/achievements/domain/achievement_models.dart';

abstract final class AchievementCatalog {
  static const List<AchievementDefinition> all = [
    AchievementDefinition(
      id: AchievementId.firstWager,
      requirementKind: AchievementRequirementKind.totalWagers,
      targetValue: 1,
      rank: 0,
    ),
    AchievementDefinition(
      id: AchievementId.fiveWagers,
      requirementKind: AchievementRequirementKind.totalWagers,
      targetValue: 5,
      rank: 1,
    ),
    AchievementDefinition(
      id: AchievementId.twentyFiveWagers,
      requirementKind: AchievementRequirementKind.totalWagers,
      targetValue: 25,
      rank: 2,
    ),
    AchievementDefinition(
      id: AchievementId.hundredWagers,
      requirementKind: AchievementRequirementKind.totalWagers,
      targetValue: 100,
      rank: 3,
    ),
    AchievementDefinition(
      id: AchievementId.firstWin,
      requirementKind: AchievementRequirementKind.correctWagers,
      targetValue: 1,
      rank: 4,
    ),
    AchievementDefinition(
      id: AchievementId.fiveWins,
      requirementKind: AchievementRequirementKind.correctWagers,
      targetValue: 5,
      rank: 5,
    ),
    AchievementDefinition(
      id: AchievementId.twentyFiveWins,
      requirementKind: AchievementRequirementKind.correctWagers,
      targetValue: 25,
      rank: 6,
    ),
    AchievementDefinition(
      id: AchievementId.hundredWins,
      requirementKind: AchievementRequirementKind.correctWagers,
      targetValue: 100,
      rank: 7,
    ),
    AchievementDefinition(
      id: AchievementId.hundredChips,
      requirementKind: AchievementRequirementKind.earnedChips,
      targetValue: 100,
      rank: 8,
    ),
    AchievementDefinition(
      id: AchievementId.thousandChips,
      requirementKind: AchievementRequirementKind.earnedChips,
      targetValue: 1000,
      rank: 9,
    ),
    AchievementDefinition(
      id: AchievementId.tenThousandChips,
      requirementKind: AchievementRequirementKind.earnedChips,
      targetValue: 10000,
      rank: 10,
    ),
    AchievementDefinition(
      id: AchievementId.levelTwo,
      requirementKind: AchievementRequirementKind.level,
      targetValue: 2,
      rank: 11,
    ),
    AchievementDefinition(
      id: AchievementId.levelFive,
      requirementKind: AchievementRequirementKind.level,
      targetValue: 5,
      rank: 12,
    ),
    AchievementDefinition(
      id: AchievementId.levelTen,
      requirementKind: AchievementRequirementKind.level,
      targetValue: 10,
      rank: 13,
    ),
    AchievementDefinition(
      id: AchievementId.levelTwentyFive,
      requirementKind: AchievementRequirementKind.level,
      targetValue: 25,
      rank: 14,
    ),
  ];
}
