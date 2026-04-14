import 'package:flutter/material.dart';
import 'package:point_rivals/core/l10n/l10n.dart';
import 'package:point_rivals/features/achievements/domain/achievement_models.dart';
import 'package:point_rivals/features/achievements/presentation/achievement_badge.dart';
import 'package:point_rivals/features/achievements/presentation/achievement_text.dart';

Future<void> showAchievementDetailSheet({
  required BuildContext context,
  required AchievementCardModel card,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    useRootNavigator: true,
    builder: (context) => _AchievementDetailSheet(card: card),
  );
}

class _AchievementDetailSheet extends StatefulWidget {
  const _AchievementDetailSheet({required this.card});

  final AchievementCardModel card;

  @override
  State<_AchievementDetailSheet> createState() =>
      _AchievementDetailSheetState();
}

class _AchievementDetailSheetState extends State<_AchievementDetailSheet> {
  bool _hasAppeared = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      setState(() => _hasAppeared = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final card = widget.card;

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: AnimatedOpacity(
        opacity: _hasAppeared ? 1 : 0,
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
        child: AnimatedScale(
          scale: _hasAppeared ? 1 : 0.94,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.86, end: 1),
                duration: const Duration(milliseconds: 1100),
                curve: Curves.elasticOut,
                builder: (context, scale, child) {
                  return Transform.scale(scale: scale, child: child);
                },
                child: AchievementBadge(
                  card: card,
                  style: AchievementBadgeStyle.compact,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                card.id.title(l10n),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                card.id.description(l10n),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 420),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: Chip(
                  key: ValueKey(card.isEarned),
                  avatar: Icon(
                    card.isEarned
                        ? Icons.lock_open_rounded
                        : Icons.lock_outline_rounded,
                    size: 18,
                  ),
                  label: Text(
                    card.isEarned
                        ? l10n.achievementStatusUnlocked
                        : l10n.achievementProgress(
                            card.progressValue.clamp(0, card.targetValue),
                            card.targetValue,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
