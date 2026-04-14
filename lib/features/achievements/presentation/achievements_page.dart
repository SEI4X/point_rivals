import 'dart:async';

import 'package:flutter/material.dart';
import 'package:point_rivals/app/dependencies/app_dependencies.dart';
import 'package:point_rivals/app/session/app_session_controller.dart';
import 'package:point_rivals/core/l10n/l10n.dart';
import 'package:point_rivals/core/widgets/app_refresh_indicator.dart';
import 'package:point_rivals/features/achievements/domain/achievement_engine.dart';
import 'package:point_rivals/features/achievements/domain/achievement_models.dart';
import 'package:point_rivals/features/achievements/presentation/achievement_badge.dart';
import 'package:point_rivals/features/achievements/presentation/achievement_detail_sheet.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  static const AchievementEngine _engine = AchievementEngine();
  String? _lastSyncKey;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncEarnedAchievements();
  }

  void _syncEarnedAchievements() {
    final profile = AppSessionScope.of(context).currentUser;
    if (profile == null) {
      return;
    }

    final syncKey =
        '${profile.id}|${profile.xp}|${profile.totalWagers}|'
        '${profile.correctWagers}|${profile.totalTokensEarned}';
    if (_lastSyncKey == syncKey) {
      return;
    }
    _lastSyncKey = syncKey;

    final repository = AppDependenciesScope.of(context).achievementRepository;
    final cards = _engine.cardsForProfile(profile);
    unawaited(
      repository.syncEarnedAchievements(userId: profile.id, cards: cards),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final profile = AppSessionScope.of(context).currentUser;
    final repository = AppDependenciesScope.of(context).achievementRepository;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.achievementsTitle)),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: StreamBuilder<Set<AchievementId>>(
          stream: profile == null
              ? const Stream<Set<AchievementId>>.empty()
              : repository.watchEarnedAchievements(profile.id),
          builder: (context, snapshot) {
            final earnedIds = snapshot.data ?? const <AchievementId>{};
            final cards = profile == null
                ? const <AchievementCardModel>[]
                : _engine.cardsForProfile(profile, earnedIds: earnedIds);
            final earnedCards = cards.where((card) => card.isEarned).toList();
            final lockedCards = cards.where((card) => !card.isEarned).toList()
              ..sort((left, right) {
                final progressComparison = right.progressFraction.compareTo(
                  left.progressFraction,
                );
                if (progressComparison != 0) {
                  return progressComparison;
                }

                return left.definition.rank.compareTo(right.definition.rank);
              });
            final earnedCount = _engine.earnedCount(cards);

            return AppRefreshIndicator(
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.achievementsTitle,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.achievementsSubtitle(
                              earnedCount,
                              cards.length,
                            ),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (earnedCards.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    _SectionTitle(title: l10n.achievementsUnlockedSection),
                    const SizedBox(height: 10),
                    _AchievementGrid(cards: earnedCards),
                  ],
                  if (lockedCards.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    _SectionTitle(title: l10n.achievementsNearestSection),
                    const SizedBox(height: 10),
                    _AchievementGrid(cards: lockedCards),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AchievementGrid extends StatelessWidget {
  const _AchievementGrid({required this.cards});

  final List<AchievementCardModel> cards;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: cards.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.82,
      ),
      itemBuilder: (context, index) {
        final card = cards[index];
        return AchievementBadge(
          card: card,
          style: AchievementBadgeStyle.expanded,
          onTap: () {
            unawaited(showAchievementDetailSheet(context: context, card: card));
          },
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge);
  }
}
