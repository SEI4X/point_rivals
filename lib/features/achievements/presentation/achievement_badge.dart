import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:point_rivals/core/l10n/l10n.dart';
import 'package:point_rivals/features/achievements/domain/achievement_models.dart';
import 'package:point_rivals/features/achievements/presentation/achievement_text.dart';

enum AchievementBadgeStyle { compact, expanded }

class AchievementBadge extends StatefulWidget {
  const AchievementBadge({
    required this.card,
    required this.style,
    this.onTap,
    super.key,
  });

  final AchievementCardModel card;
  final AchievementBadgeStyle style;
  final VoidCallback? onTap;

  @override
  State<AchievementBadge> createState() => _AchievementBadgeState();
}

class _AchievementBadgeState extends State<AchievementBadge> {
  bool _isPressed = false;
  int _symbolTrigger = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final accent = _accentFor(widget.card.id, colors);
    final isCompact = widget.style == AchievementBadgeStyle.compact;
    final foreground = widget.card.isEarned ? accent : colors.onSurfaceVariant;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.96, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutBack,
      builder: (context, entranceScale, child) {
        return AnimatedScale(
          scale: _isPressed ? 0.98 : entranceScale,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: child,
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _handleTap,
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapCancel: () => setState(() => _isPressed = false),
          child: Padding(
            padding: EdgeInsets.all(isCompact ? 12 : 14),
            child: SizedBox(
              height: isCompact ? 126 : 184,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: foreground.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(isCompact ? 11 : 15),
                        child: TweenAnimationBuilder<double>(
                          key: ValueKey(_symbolTrigger),
                          tween: Tween<double>(begin: 0.82, end: 1),
                          duration: const Duration(milliseconds: 520),
                          curve: Curves.elasticOut,
                          builder: (context, scale, child) {
                            return Transform.scale(scale: scale, child: child);
                          },
                          child: Icon(
                            _iconFor(widget.card.id),
                            color: foreground,
                            size: isCompact ? 28 : 38,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isCompact ? 10 : 12),
                  Text(
                    widget.card.id.title(l10n),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style:
                        (isCompact
                                ? Theme.of(context).textTheme.labelLarge
                                : Theme.of(context).textTheme.titleMedium)
                            ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  if (!isCompact) ...[
                    const SizedBox(height: 6),
                    Text(
                      achievementRequirementText(
                        l10n,
                        widget.card.definition.requirementKind,
                        widget.card.targetValue,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const Spacer(),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: Text(
                      widget.card.isEarned
                          ? l10n.achievementStatusUnlocked
                          : l10n.achievementProgress(
                              widget.card.progressValue.clamp(
                                0,
                                widget.card.targetValue,
                              ),
                              widget.card.targetValue,
                            ),
                      key: ValueKey(widget.card.isEarned),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: 0,
                        end: widget.card.progressFraction,
                      ),
                      duration: const Duration(milliseconds: 520),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return LinearProgressIndicator(
                          minHeight: isCompact ? 6 : 7,
                          value: value,
                          color: foreground,
                          backgroundColor: colors.surfaceContainerHigh,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap() {
    setState(() {
      _isPressed = false;
      _symbolTrigger += 1;
    });
    unawaited(HapticFeedback.selectionClick());
    widget.onTap?.call();
  }

  IconData _iconFor(AchievementId id) {
    return switch (id) {
      AchievementId.firstWager => Icons.flag_rounded,
      AchievementId.fiveWagers => Icons.casino_rounded,
      AchievementId.twentyFiveWagers => Icons.style_rounded,
      AchievementId.hundredWagers => Icons.local_fire_department_rounded,
      AchievementId.firstWin => Icons.check_circle_rounded,
      AchievementId.fiveWins => Icons.verified_rounded,
      AchievementId.twentyFiveWins => Icons.emoji_events_rounded,
      AchievementId.hundredWins => Icons.workspace_premium_rounded,
      AchievementId.hundredChips => Icons.savings_rounded,
      AchievementId.thousandChips => Icons.account_balance_wallet_rounded,
      AchievementId.tenThousandChips => Icons.diamond_rounded,
      AchievementId.levelTwo => Icons.stars_rounded,
      AchievementId.levelFive => Icons.auto_awesome_rounded,
      AchievementId.levelTen => Icons.military_tech_rounded,
      AchievementId.levelTwentyFive => Icons.shield_rounded,
    };
  }

  Color _accentFor(AchievementId id, ColorScheme colors) {
    return switch (id) {
      AchievementId.firstWager ||
      AchievementId.fiveWagers ||
      AchievementId.twentyFiveWagers ||
      AchievementId.hundredWagers => colors.primary,
      AchievementId.firstWin ||
      AchievementId.fiveWins ||
      AchievementId.twentyFiveWins ||
      AchievementId.hundredWins => colors.secondary,
      AchievementId.hundredChips ||
      AchievementId.thousandChips ||
      AchievementId.tenThousandChips => colors.tertiary,
      AchievementId.levelTwo ||
      AchievementId.levelFive ||
      AchievementId.levelTen ||
      AchievementId.levelTwentyFive => colors.primary,
    };
  }
}
