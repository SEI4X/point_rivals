import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:point_rivals/app/dependencies/app_dependencies.dart';
import 'package:point_rivals/core/l10n/l10n.dart';
import 'package:point_rivals/core/routing/app_router.dart';
import 'package:point_rivals/core/widgets/top_snack_bar.dart';
import 'package:point_rivals/features/achievements/domain/achievement_engine.dart';
import 'package:point_rivals/features/achievements/domain/achievement_models.dart';
import 'package:point_rivals/features/achievements/presentation/achievement_badge.dart';
import 'package:point_rivals/features/achievements/presentation/achievement_detail_sheet.dart';
import 'package:point_rivals/features/achievements/presentation/achievement_text.dart';
import 'package:point_rivals/features/profile/domain/profile_models.dart';

class ProfileAchievementsSection extends StatefulWidget {
  const ProfileAchievementsSection({
    required this.profile,
    this.engine = const AchievementEngine(),
    super.key,
  });

  final UserProfile profile;
  final AchievementEngine engine;

  @override
  State<ProfileAchievementsSection> createState() =>
      _ProfileAchievementsSectionState();
}

class _ProfileAchievementsSectionState
    extends State<ProfileAchievementsSection> {
  String? _lastSyncKey;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncEarnedAchievements();
  }

  @override
  void didUpdateWidget(ProfileAchievementsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncEarnedAchievements();
  }

  void _syncEarnedAchievements() {
    final profile = widget.profile;
    final syncKey =
        '${profile.id}|${profile.xp}|${profile.totalWagers}|'
        '${profile.correctWagers}|${profile.totalTokensEarned}';
    if (_lastSyncKey == syncKey) {
      return;
    }
    _lastSyncKey = syncKey;

    final cards = widget.engine.cardsForProfile(profile);
    unawaited(_syncAndNotify(profile.id, cards));
  }

  Future<void> _syncAndNotify(
    String userId,
    List<AchievementCardModel> cards,
  ) async {
    final repository = AppDependenciesScope.of(context).achievementRepository;
    final newIds = await repository.syncEarnedAchievements(
      userId: userId,
      cards: cards,
    );
    if (!mounted || newIds.isEmpty) {
      return;
    }

    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final title = newIds.first.title(l10n);
    showTopSnackBar(
      context: context,
      message: l10n.achievementUnlockedToast(title),
      icon: Icons.workspace_premium_rounded,
      iconColor: colors.primary,
      onTap: () {
        unawaited(context.push(AppRoutes.achievements));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final repository = AppDependenciesScope.of(context).achievementRepository;

    return StreamBuilder<Set<AchievementId>>(
      stream: repository.watchEarnedAchievements(widget.profile.id),
      builder: (context, snapshot) {
        final earnedIds = snapshot.data ?? const <AchievementId>{};
        final cards = widget.engine.cardsForProfile(
          widget.profile,
          earnedIds: earnedIds,
        );
        final earnedCount = widget.engine.earnedCount(cards);
        final displayedCards = _displayedCards(cards);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.achievementsTitle,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.achievementsSubtitle(earnedCount, cards.length),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    unawaited(context.push(AppRoutes.achievements));
                  },
                  child: Text(l10n.achievementsViewAll),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 158,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final card = displayedCards[index];
                  return SizedBox(
                    width: 136,
                    child: AchievementBadge(
                      card: card,
                      style: AchievementBadgeStyle.compact,
                      onTap: () {
                        unawaited(
                          showAchievementDetailSheet(
                            context: context,
                            card: card,
                          ),
                        );
                      },
                    ),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemCount: displayedCards.length,
              ),
            ),
          ],
        );
      },
    );
  }

  List<AchievementCardModel> _displayedCards(List<AchievementCardModel> cards) {
    final nearest = widget.engine.nearestLocked(cards);
    if (nearest.isNotEmpty) {
      return nearest;
    }

    return cards.where((card) => card.isEarned).take(5).toList();
  }
}
