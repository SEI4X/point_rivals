import 'package:point_rivals/core/l10n/l10n.dart';
import 'package:point_rivals/features/achievements/domain/achievement_models.dart';

extension AchievementText on AchievementId {
  String title(AppLocalizations l10n) {
    return switch (this) {
      AchievementId.firstWager => l10n.achievementFirstWagerTitle,
      AchievementId.fiveWagers => l10n.achievementFiveWagersTitle,
      AchievementId.twentyFiveWagers => l10n.achievementTwentyFiveWagersTitle,
      AchievementId.hundredWagers => l10n.achievementHundredWagersTitle,
      AchievementId.firstWin => l10n.achievementFirstWinTitle,
      AchievementId.fiveWins => l10n.achievementFiveWinsTitle,
      AchievementId.twentyFiveWins => l10n.achievementTwentyFiveWinsTitle,
      AchievementId.hundredWins => l10n.achievementHundredWinsTitle,
      AchievementId.hundredChips => l10n.achievementHundredChipsTitle,
      AchievementId.thousandChips => l10n.achievementThousandChipsTitle,
      AchievementId.tenThousandChips => l10n.achievementTenThousandChipsTitle,
      AchievementId.levelTwo => l10n.achievementLevelTwoTitle,
      AchievementId.levelFive => l10n.achievementLevelFiveTitle,
      AchievementId.levelTen => l10n.achievementLevelTenTitle,
      AchievementId.levelTwentyFive => l10n.achievementLevelTwentyFiveTitle,
    };
  }

  String description(AppLocalizations l10n) {
    return switch (this) {
      AchievementId.firstWager => l10n.achievementFirstWagerDescription,
      AchievementId.fiveWagers => l10n.achievementFiveWagersDescription,
      AchievementId.twentyFiveWagers =>
        l10n.achievementTwentyFiveWagersDescription,
      AchievementId.hundredWagers => l10n.achievementHundredWagersDescription,
      AchievementId.firstWin => l10n.achievementFirstWinDescription,
      AchievementId.fiveWins => l10n.achievementFiveWinsDescription,
      AchievementId.twentyFiveWins => l10n.achievementTwentyFiveWinsDescription,
      AchievementId.hundredWins => l10n.achievementHundredWinsDescription,
      AchievementId.hundredChips => l10n.achievementHundredChipsDescription,
      AchievementId.thousandChips => l10n.achievementThousandChipsDescription,
      AchievementId.tenThousandChips =>
        l10n.achievementTenThousandChipsDescription,
      AchievementId.levelTwo => l10n.achievementLevelTwoDescription,
      AchievementId.levelFive => l10n.achievementLevelFiveDescription,
      AchievementId.levelTen => l10n.achievementLevelTenDescription,
      AchievementId.levelTwentyFive =>
        l10n.achievementLevelTwentyFiveDescription,
    };
  }
}

String achievementRequirementText(
  AppLocalizations l10n,
  AchievementRequirementKind kind,
  int target,
) {
  return switch (kind) {
    AchievementRequirementKind.totalWagers =>
      l10n.achievementRequirementTotalWagers(target),
    AchievementRequirementKind.correctWagers =>
      l10n.achievementRequirementCorrectWagers(target),
    AchievementRequirementKind.earnedChips =>
      l10n.achievementRequirementEarnedChips(target),
    AchievementRequirementKind.level => l10n.achievementRequirementLevel(
      target,
    ),
  };
}
