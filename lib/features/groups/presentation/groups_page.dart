import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:point_rivals/app/dependencies/app_dependencies.dart';
import 'package:point_rivals/app/session/app_session_controller.dart';
import 'package:point_rivals/core/l10n/l10n.dart';
import 'package:point_rivals/core/routing/app_router.dart';
import 'package:point_rivals/core/widgets/app_refresh_indicator.dart';
import 'package:point_rivals/core/widgets/app_snack_bar.dart';
import 'package:point_rivals/features/groups/domain/group_models.dart';
import 'package:point_rivals/features/profile/domain/profile_models.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final session = AppSessionScope.of(context);
    final dependencies = AppDependenciesScope.of(context);
    final user = session.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            tooltip: l10n.groupsSearchTooltip,
            onPressed: () => _showGroupActions(context),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 16),
        child: user == null
            ? const Center(child: CircularProgressIndicator())
            : StreamBuilder<List<RivalGroup>>(
                stream: dependencies.groupRepository.watchMyGroups(user.id),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    assert(() {
                      debugPrint('Groups stream failed: ${snapshot.error}');
                      debugPrintStack(stackTrace: snapshot.stackTrace);
                      return true;
                    }());

                    return const _GroupsError();
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final groups = snapshot.data!;
                  return AppRefreshIndicator(
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 20),
                      children: [
                        _DashboardHeader(user: user),
                        const SizedBox(height: 16),
                        if (groups.isEmpty)
                          const _GroupsEmptyState()
                        else ...[
                          Text(
                            l10n.groupsTitle,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 10),
                          for (final group in groups) ...[
                            _GroupTile(group: group),
                            const SizedBox(height: 12),
                          ],
                        ],
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _showGroupActions(BuildContext context) {
    final l10n = context.l10n;

    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          minimum: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.search_rounded),
                title: Text(l10n.joinGroupPreviewButton),
                onTap: () {
                  Navigator.of(context).pop();
                  unawaited(_showJoinGroupSheet(context));
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_circle_outline_rounded),
                title: Text(l10n.groupsCreateTooltip),
                onTap: () {
                  Navigator.of(context).pop();
                  unawaited(context.push(AppRoutes.createGroup));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showJoinGroupSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => const _JoinGroupSheet(),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.user});

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final String displayName = user.displayName.isEmpty
        ? context.l10n.profileUnnamed
        : user.displayName;

    return Row(
      children: [
        CircleAvatar(
          radius: 17,
          backgroundColor: colors.surfaceContainerHigh,
          backgroundImage: user.avatarUrl == null
              ? null
              : NetworkImage(user.avatarUrl!),
          foregroundColor: colors.primary,
          child: user.avatarUrl == null
              ? const Icon(Icons.person_rounded, size: 18)
              : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        _HeaderBadge(
          icon: Icons.casino_rounded,
          text: user.totalWagers.toString(),
          color: colors.tertiary,
        ),
        const SizedBox(width: 8),
        _HeaderBadge(
          icon: Icons.stars_rounded,
          text: user.xp.toString(),
          color: colors.primary,
        ),
      ],
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  const _HeaderBadge({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 3),
        Text(text, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _JoinGroupSheet extends StatefulWidget {
  const _JoinGroupSheet();

  @override
  State<_JoinGroupSheet> createState() => _JoinGroupSheetState();
}

class _JoinGroupSheetState extends State<_JoinGroupSheet> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _preview() async {
    if (_isLoading || !_formKey.currentState!.validate()) {
      return;
    }

    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _isLoading = true;
    });

    try {
      final group = await AppDependenciesScope.of(
        context,
      ).groupRepository.previewGroupByInviteCode(_codeController.text.trim());

      if (mounted) {
        Navigator.of(context).pop();
        unawaited(context.push(AppRoutes.group(group.id), extra: group));
      }
    } on Object {
      if (mounted) {
        showAppSnackBarOnMessenger(
          messenger: messenger,
          message: l10n.joinGroupError,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _scanQr() async {
    final code = await context.push<String>(AppRoutes.joinGroupScanner);
    if (code == null || !mounted) {
      return;
    }

    _codeController.text = code;
    await _preview();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return SafeArea(
      minimum: EdgeInsets.only(
        left: 20,
        top: 8,
        right: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.joinGroupTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _codeController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(labelText: l10n.joinGroupCodeLabel),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.joinGroupCodeRequired;
                }

                return null;
              },
              onFieldSubmitted: (_) => _preview(),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _scanQr,
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: Text(l10n.joinGroupScanQr),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _isLoading ? null : _preview,
              child: _isLoading
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.joinGroupPreviewButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupsEmptyState extends StatelessWidget {
  const _GroupsEmptyState();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.group_add_rounded,
                  size: 38,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.groupsEmptyTitle,
                  textAlign: TextAlign.center,
                  style: textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.groupsEmptyBody,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GroupsError extends StatelessWidget {
  const _GroupsError();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Text(
              l10n.groupsLoadError,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({required this.group});

  final RivalGroup group;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        onTap: () => context.push(AppRoutes.group(group.id)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      group.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetricChip(
                    icon: Icons.group_rounded,
                    label: l10n.groupsMembersCount(group.memberCount),
                  ),
                  _MetricChip(
                    icon: Icons.local_fire_department_rounded,
                    label: l10n.groupsActiveWagersCount(group.activeWagerCount),
                  ),
                  _MetricChip(
                    icon: Icons.stars_rounded,
                    label: l10n.groupsMyBalance(group.myTokenBalance),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      avatar: Icon(icon, size: 16),
      label: Text(label),
    );
  }
}
