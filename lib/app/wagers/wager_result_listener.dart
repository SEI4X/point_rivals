import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:point_rivals/app/dependencies/app_dependencies.dart';
import 'package:point_rivals/app/session/app_session_controller.dart';
import 'package:point_rivals/core/l10n/l10n.dart';
import 'package:point_rivals/core/routing/app_router.dart';
import 'package:point_rivals/core/widgets/top_snack_bar.dart';
import 'package:point_rivals/features/groups/domain/group_models.dart';
import 'package:point_rivals/features/wagers/domain/wager_models.dart';

class WagerResultListener extends StatefulWidget {
  const WagerResultListener({required this.child, super.key});

  final Widget child;

  @override
  State<WagerResultListener> createState() => _WagerResultListenerState();
}

class _WagerResultListenerState extends State<WagerResultListener> {
  StreamSubscription<List<RivalGroup>>? _groupsSubscription;
  final Map<String, StreamSubscription<List<Wager>>> _wagerSubscriptions = {};
  final Map<String, Set<String>?> _knownResolvedWagerIds = {};
  final Map<String, String> _groupNamesById = {};
  String? _userId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userId = AppSessionScope.of(context).currentUser?.id;
    if (userId == _userId) {
      return;
    }

    _userId = userId;
    _resetSubscriptions();

    if (userId == null) {
      return;
    }

    _groupsSubscription = AppDependenciesScope.of(
      context,
    ).groupRepository.watchMyGroups(userId).listen(_syncGroupSubscriptions);
  }

  @override
  void dispose() {
    _resetSubscriptions();
    super.dispose();
  }

  void _resetSubscriptions() {
    unawaited(_groupsSubscription?.cancel());
    _groupsSubscription = null;
    for (final subscription in _wagerSubscriptions.values) {
      unawaited(subscription.cancel());
    }
    _wagerSubscriptions.clear();
    _knownResolvedWagerIds.clear();
    _groupNamesById.clear();
  }

  void _syncGroupSubscriptions(List<RivalGroup> groups) {
    final userId = _userId;
    if (userId == null) {
      return;
    }

    final groupIds = groups.map((group) => group.id).toSet();
    _groupNamesById
      ..clear()
      ..addEntries(groups.map((group) => MapEntry(group.id, group.name)));
    final staleIds = _wagerSubscriptions.keys
        .where((groupId) => !groupIds.contains(groupId))
        .toList();
    for (final groupId in staleIds) {
      unawaited(_wagerSubscriptions.remove(groupId)?.cancel());
      _knownResolvedWagerIds.remove(groupId);
    }

    for (final groupId in groupIds) {
      _wagerSubscriptions.putIfAbsent(groupId, () {
        return AppDependenciesScope.of(context).wagerRepository
            .watchResolvedWagers(groupId)
            .listen((wagers) => _handleResolvedWagers(groupId, userId, wagers));
      });
    }
  }

  void _handleResolvedWagers(
    String groupId,
    String userId,
    List<Wager> wagers,
  ) {
    final knownIds = _knownResolvedWagerIds[groupId];
    _knownResolvedWagerIds[groupId] = wagers.map((wager) => wager.id).toSet();
    if (knownIds == null || !mounted) {
      return;
    }

    for (final wager in wagers) {
      if (knownIds.contains(wager.id) || !wager.hasStakeFrom(userId)) {
        continue;
      }

      final stake = wager.stakes.firstWhere((item) => item.userId == userId);
      final won = stake.side == wager.winningSide;
      final l10n = context.l10n;
      final groupName = _groupNamesById[groupId] ?? l10n.groupsTitle;
      showTopSnackBar(
        context: context,
        message: won
            ? l10n.wagerResultWonInGroup(groupName)
            : l10n.wagerResultLostInGroup(groupName),
        icon: won ? Icons.verified_rounded : Icons.info_rounded,
        iconColor: won
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.secondary,
        onTap: () => context.push(AppRoutes.group(groupId)),
      );
      break;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
