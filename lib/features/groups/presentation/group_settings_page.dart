import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:point_rivals/app/dependencies/app_dependencies.dart';
import 'package:point_rivals/app/session/app_session_controller.dart';
import 'package:point_rivals/core/l10n/l10n.dart';
import 'package:point_rivals/core/routing/app_router.dart';
import 'package:point_rivals/core/widgets/app_snack_bar.dart';
import 'package:point_rivals/features/groups/domain/group_models.dart';
import 'package:point_rivals/features/profile/domain/xp_progression.dart';
import 'package:point_rivals/features/profile/presentation/public_member_profile_page.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class GroupSettingsPage extends StatefulWidget {
  const GroupSettingsPage({required this.groupId, super.key});

  final String groupId;

  @override
  State<GroupSettingsPage> createState() => _GroupSettingsPageState();
}

class _GroupSettingsPageState extends State<GroupSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isNameDirty = false;
  bool _isSaving = false;
  String? _busyMemberId;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving || !_formKey.currentState!.validate()) {
      return;
    }

    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isSaving = true);

    try {
      final repository = AppDependenciesScope.of(context).groupRepository;
      await repository.updateGroupName(
        groupId: widget.groupId,
        name: _nameController.text.trim(),
      );

      if (mounted) {
        setState(() => _isNameDirty = false);
        showAppSnackBarOnMessenger(
          messenger: messenger,
          message: l10n.groupSaveSuccess,
        );
      }
    } on Object {
      if (mounted) {
        showAppSnackBarOnMessenger(
          messenger: messenger,
          message: l10n.groupSaveError,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _updateLeaderboardWindowWeeks(int weeks) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await AppDependenciesScope.of(
        context,
      ).groupRepository.updateGroupLeaderboardWindowWeeks(
        groupId: widget.groupId,
        weeks: weeks,
      );
    } on Object {
      if (mounted) {
        showAppSnackBarOnMessenger(
          messenger: messenger,
          message: l10n.groupSaveError,
        );
      }
    }
  }

  Future<void> _updateMemberRole(
    GroupMember member,
    GroupMemberRole role,
  ) async {
    await _runMemberAction(
      member.userId,
      () => AppDependenciesScope.of(context).groupRepository.updateMemberRole(
        groupId: widget.groupId,
        userId: member.userId,
        role: role,
      ),
    );
  }

  Future<void> _removeMember(GroupMember member) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.groupRemoveMemberTitle),
          content: Text(l10n.groupRemoveMemberBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.commonConfirm),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) {
      return;
    }

    await _runMemberAction(
      member.userId,
      () => AppDependenciesScope.of(context).groupRepository.removeMember(
        groupId: widget.groupId,
        userId: member.userId,
      ),
    );
  }

  Future<void> _runMemberAction(
    String userId,
    Future<void> Function() action,
  ) async {
    if (_busyMemberId != null) {
      return;
    }

    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busyMemberId = userId);
    try {
      await action();
    } on Object {
      if (mounted) {
        showAppSnackBarOnMessenger(
          messenger: messenger,
          message: l10n.groupMemberActionError,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busyMemberId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final dependencies = AppDependenciesScope.of(context);
    final user = AppSessionScope.of(context).currentUser;

    if (user == null) {
      return const Scaffold(
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.groupSettingsTitle),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.commonSave),
          ),
        ],
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: StreamBuilder<RivalGroup>(
          stream: dependencies.groupRepository.watchGroup(
            widget.groupId,
            userId: user.id,
          ),
          builder: (context, groupSnapshot) {
            final group = groupSnapshot.data;
            if (group != null && !_isNameDirty) {
              _nameController.text = group.name;
            }

            return StreamBuilder<List<GroupMember>>(
              stream: dependencies.groupRepository.watchMembers(widget.groupId),
              builder: (context, membersSnapshot) {
                final members = membersSnapshot.data ?? const <GroupMember>[];
                final admins = members
                    .where((member) => member.role == GroupMemberRole.admin)
                    .toList();
                final participants = members
                    .where((member) => member.role == GroupMemberRole.member)
                    .toList();

                return Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: l10n.groupNameLabel,
                              prefixIcon: const Icon(Icons.edit_rounded),
                            ),
                            textInputAction: TextInputAction.done,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return l10n.groupNameRequired;
                              }

                              return null;
                            },
                            onChanged: (_) => setState(() {
                              _isNameDirty = true;
                            }),
                            onFieldSubmitted: (_) => _save(),
                          ),
                        ),
                      ),
                      if (group != null) ...[
                        const SizedBox(height: 16),
                        _LeaderboardWindowCard(
                          group: group,
                          onChanged: _updateLeaderboardWindowWeeks,
                        ),
                        const SizedBox(height: 16),
                        _InviteCard(group: group),
                      ],
                      const SizedBox(height: 16),
                      _MembersSection(
                        title: l10n.groupAdmins,
                        members: admins,
                        emptyLabel: l10n.groupAdmins,
                        currentUserId: user.id,
                        adminCount: admins.length,
                        busyMemberId: _busyMemberId,
                        onPromote: (member) =>
                            _updateMemberRole(member, GroupMemberRole.admin),
                        onDemote: (member) =>
                            _updateMemberRole(member, GroupMemberRole.member),
                        onRemove: _removeMember,
                      ),
                      const SizedBox(height: 16),
                      _MembersSection(
                        title: l10n.groupParticipants,
                        members: participants,
                        emptyLabel: l10n.groupParticipants,
                        currentUserId: user.id,
                        adminCount: admins.length,
                        busyMemberId: _busyMemberId,
                        onPromote: (member) =>
                            _updateMemberRole(member, GroupMemberRole.admin),
                        onDemote: (member) =>
                            _updateMemberRole(member, GroupMemberRole.member),
                        onRemove: _removeMember,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _MembersSection extends StatelessWidget {
  const _MembersSection({
    required this.title,
    required this.members,
    required this.emptyLabel,
    required this.currentUserId,
    required this.adminCount,
    required this.busyMemberId,
    required this.onPromote,
    required this.onDemote,
    required this.onRemove,
  });

  final String title;
  final List<GroupMember> members;
  final String emptyLabel;
  final String currentUserId;
  final int adminCount;
  final String? busyMemberId;
  final ValueChanged<GroupMember> onPromote;
  final ValueChanged<GroupMember> onDemote;
  final ValueChanged<GroupMember> onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (members.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
                child: Text(
                  emptyLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              for (final member in members)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                  leading: _MemberAvatar(member: member),
                  title: Text(member.displayName),
                  subtitle: Text(
                    '${l10n.profileLevel(const XpProgression().levelForXp(member.xp))} · '
                    '${member.userId == currentUserId ? l10n.groupSelfAdminHint : context.l10n.groupsMyBalance(member.tokenBalance)}',
                  ),
                  onTap: () => context.push(
                    AppRoutes.memberProfile(member.userId),
                    extra: PublicMemberProfile(member: member),
                  ),
                  trailing: _MemberActions(
                    member: member,
                    isCurrentUser: member.userId == currentUserId,
                    canDemoteAdmin: adminCount > 1,
                    isBusy: busyMemberId == member.userId,
                    onPromote: onPromote,
                    onDemote: onDemote,
                    onRemove: onRemove,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _InviteCard extends StatelessWidget {
  const _InviteCard({required this.group});

  final RivalGroup group;

  Future<void> _copyCode(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    await Clipboard.setData(ClipboardData(text: group.inviteCode));

    if (!context.mounted) {
      return;
    }

    showAppSnackBarOnMessenger(
      messenger: messenger,
      message: l10n.groupInviteCopied,
    );
  }

  Future<void> _shareInvite(BuildContext context) async {
    final l10n = context.l10n;
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    final qrFile = await _qrCodeFile();

    await SharePlus.instance.share(
      ShareParams(
        title: group.name,
        subject: group.name,
        text: l10n.groupInviteShareText(group.name, group.inviteCode),
        files: [
          XFile(
            qrFile.path,
            mimeType: 'image/png',
            name: 'point-rivals-${group.inviteCode}.png',
          ),
        ],
        sharePositionOrigin: origin,
      ),
    );
  }

  Future<File> _qrCodeFile() async {
    final painter = QrPainter(
      data: group.inviteCode,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.M,
      gapless: true,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: Color(0xFF0B0C0D),
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: Color(0xFF0B0C0D),
      ),
    );
    final byteData = await painter.toImageData(1024);
    if (byteData == null) {
      throw StateError('Invite QR image data is empty.');
    }

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/point-rivals-${group.inviteCode}.png');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.qr_code_rounded, color: colors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.groupInviteQr,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: QrImageView(
                    data: group.inviteCode,
                    size: 168,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.circle,
                      color: Colors.black,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.circle,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.groupInviteCode,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(color: colors.onSurfaceVariant),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            group.inviteCode,
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(letterSpacing: 0),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.numbers_rounded, color: colors.primary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _copyCode(context),
                    icon: const Icon(Icons.copy_rounded),
                    label: Text(l10n.groupInviteCopyAction),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _shareInvite(context),
                    icon: const Icon(Icons.ios_share_rounded),
                    label: Text(l10n.groupInviteShareAction),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardWindowCard extends StatelessWidget {
  const _LeaderboardWindowCard({required this.group, required this.onChanged});

  final RivalGroup group;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final weeks = group.leaderboardWindowWeeks.clamp(1, 52);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.groupLeaderboardWindowTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.groupLeaderboardWindowBody,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<int>(
              segments: [
                ButtonSegment(
                  value: 1,
                  label: Text(l10n.groupLeaderboardWindowWeeks(1)),
                ),
                ButtonSegment(
                  value: 2,
                  label: Text(l10n.groupLeaderboardWindowWeeks(2)),
                ),
                ButtonSegment(
                  value: 4,
                  label: Text(l10n.groupLeaderboardWindowWeeks(4)),
                ),
              ],
              selected: {weeks == 1 || weeks == 2 || weeks == 4 ? weeks : 1},
              onSelectionChanged: (selection) => onChanged(selection.single),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberActions extends StatelessWidget {
  const _MemberActions({
    required this.member,
    required this.isCurrentUser,
    required this.canDemoteAdmin,
    required this.isBusy,
    required this.onPromote,
    required this.onDemote,
    required this.onRemove,
  });

  final GroupMember member;
  final bool isCurrentUser;
  final bool canDemoteAdmin;
  final bool isBusy;
  final ValueChanged<GroupMember> onPromote;
  final ValueChanged<GroupMember> onDemote;
  final ValueChanged<GroupMember> onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (isBusy) {
      return const SizedBox.square(
        dimension: 22,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (isCurrentUser) {
      return Chip(label: Text(l10n.groupAdminBadge));
    }

    return PopupMenuButton<_MemberAction>(
      icon: const Icon(Icons.more_horiz_rounded),
      onSelected: (action) {
        switch (action) {
          case _MemberAction.promote:
            onPromote(member);
            break;
          case _MemberAction.demote:
            onDemote(member);
            break;
          case _MemberAction.remove:
            onRemove(member);
            break;
        }
      },
      itemBuilder: (context) {
        return [
          if (member.role == GroupMemberRole.member)
            PopupMenuItem(
              value: _MemberAction.promote,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.admin_panel_settings_rounded),
                title: Text(l10n.groupPromoteMember),
              ),
            ),
          if (member.role == GroupMemberRole.admin && canDemoteAdmin)
            PopupMenuItem(
              value: _MemberAction.demote,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.remove_moderator_rounded),
                title: Text(l10n.groupDemoteMember),
              ),
            ),
          PopupMenuItem(
            value: _MemberAction.remove,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.person_remove_rounded,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                l10n.groupRemoveMember,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
        ];
      },
    );
  }
}

enum _MemberAction { promote, demote, remove }

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({required this.member});

  final GroupMember member;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return CircleAvatar(
      backgroundColor: member.role == GroupMemberRole.admin
          ? colors.primary.withValues(alpha: 0.14)
          : colors.surfaceContainerHigh,
      backgroundImage: member.avatarUrl == null
          ? null
          : NetworkImage(member.avatarUrl!),
      foregroundColor: member.role == GroupMemberRole.admin
          ? colors.primary
          : colors.onSurfaceVariant,
      child: member.avatarUrl == null ? const Icon(Icons.person_rounded) : null,
    );
  }
}
