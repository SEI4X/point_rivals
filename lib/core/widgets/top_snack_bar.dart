import 'dart:async';

import 'package:flutter/material.dart';

OverlayEntry? _activeTopSnackBar;
String? _activeTopSnackBarMessage;

void showTopSnackBar({
  required BuildContext context,
  required String message,
  required IconData icon,
  required Color iconColor,
  VoidCallback? onTap,
  Duration duration = const Duration(seconds: 4),
}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) {
    return;
  }

  if (_activeTopSnackBar?.mounted == true &&
      _activeTopSnackBarMessage == message) {
    return;
  }

  _activeTopSnackBar?.remove();
  _activeTopSnackBar = null;
  _activeTopSnackBarMessage = null;

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) {
      return _TopSnackBar(
        message: message,
        icon: icon,
        iconColor: iconColor,
        onTap: () {
          _removeTopSnackBar(entry);
          onTap?.call();
        },
      );
    },
  );

  _activeTopSnackBar = entry;
  _activeTopSnackBarMessage = message;
  overlay.insert(entry);
  unawaited(
    Future<void>.delayed(duration).then((_) {
      _removeTopSnackBar(entry);
    }),
  );
}

void _removeTopSnackBar(OverlayEntry entry) {
  if (entry.mounted) {
    entry.remove();
  }

  if (identical(_activeTopSnackBar, entry)) {
    _activeTopSnackBar = null;
    _activeTopSnackBarMessage = null;
  }
}

class _TopSnackBar extends StatelessWidget {
  const _TopSnackBar({
    required this.message,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  final String message;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final topPadding = MediaQuery.paddingOf(context).top;

    return PositionedDirectional(
      top: topPadding + 10,
      start: 14,
      end: 14,
      child: SafeArea(
        bottom: false,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 360),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Opacity(
                opacity: value.clamp(0, 1).toDouble(),
                child: Transform.translate(
                  offset: Offset(0, -16 * (1 - value)),
                  child: Transform.scale(
                    scale: 0.96 + (0.04 * value),
                    child: child,
                  ),
                ),
              );
            },
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(18),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.inverseSurface,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 28,
                      offset: const Offset(0, 12),
                      color: colors.shadow.withValues(alpha: 0.18),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(icon, color: iconColor, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colors.onInverseSurface),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: colors.onInverseSurface,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
