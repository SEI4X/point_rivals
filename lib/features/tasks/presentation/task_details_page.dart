import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:point_rivals/app/dependencies/app_dependencies.dart';
import 'package:point_rivals/app/session/app_session_controller.dart';
import 'package:point_rivals/core/formatters/app_date_formatter.dart';
import 'package:point_rivals/core/l10n/l10n.dart';
import 'package:point_rivals/core/widgets/app_refresh_indicator.dart';
import 'package:point_rivals/core/widgets/app_shimmer.dart';
import 'package:point_rivals/core/widgets/app_snack_bar.dart';
import 'package:point_rivals/features/groups/domain/group_models.dart';
import 'package:point_rivals/features/tasks/domain/task_models.dart';

class TaskDetailsPage extends StatefulWidget {
  const TaskDetailsPage({
    required this.groupId,
    required this.taskId,
    super.key,
  });

  final String groupId;
  final String taskId;

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  bool _isUpdating = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dependencies = AppDependenciesScope.of(context);
    final userId = AppSessionScope.of(context).currentUser?.id;
    final refreshRevision = AppRefreshScope.revisionOf(context);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.taskDetailsTitle),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: StreamBuilder<List<GroupMember>>(
          key: ValueKey('task-members-${widget.groupId}-$refreshRevision'),
          stream: dependencies.groupRepository.watchMembers(widget.groupId),
          builder: (context, membersSnapshot) {
            final membersById = {
              for (final member
                  in membersSnapshot.data ?? const <GroupMember>[])
                member.userId: member,
            };
            final currentMember = userId == null ? null : membersById[userId];
            final isAdmin = currentMember?.role == GroupMemberRole.admin;

            return StreamBuilder<RivalTask>(
              key: ValueKey(
                'task-${widget.groupId}-${widget.taskId}-$refreshRevision',
              ),
              stream: dependencies.taskRepository.watchTask(
                groupId: widget.groupId,
                taskId: widget.taskId,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text(l10n.authGenericError));
                }

                final task = snapshot.data;
                return AppLoadingSwitcher(
                  isLoading: task == null,
                  loading: const AppSkeletonList(itemCount: 3),
                  child: task == null
                      ? const SizedBox.shrink()
                      : _TaskDetailsContent(
                          task: task,
                          assignee: task.assignedUserId == null
                              ? null
                              : membersById[task.assignedUserId],
                          canAssignSelf:
                              userId != null && task.canAssignSelf(userId),
                          isAdmin: isAdmin,
                          isUpdating: _isUpdating,
                          onAssignSelf: userId == null
                              ? null
                              : () => unawaited(_assignSelf(userId)),
                          onComplete: isAdmin
                              ? () => unawaited(_completeTask(userId!))
                              : null,
                        ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _assignSelf(String userId) async {
    if (_isUpdating) {
      return;
    }

    final l10n = context.l10n;
    setState(() => _isUpdating = true);
    try {
      await AppDependenciesScope.of(context).taskRepository.assignTaskToSelf(
        groupId: widget.groupId,
        taskId: widget.taskId,
        userId: userId,
      );
    } on Object {
      if (mounted) {
        showAppSnackBar(context: context, message: l10n.taskAssignError);
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  Future<void> _completeTask(String adminUserId) async {
    if (_isUpdating) {
      return;
    }

    final l10n = context.l10n;
    setState(() => _isUpdating = true);
    try {
      await AppDependenciesScope.of(context).taskRepository.completeTask(
        groupId: widget.groupId,
        taskId: widget.taskId,
        adminUserId: adminUserId,
      );
      if (mounted) {
        showAppSnackBar(context: context, message: l10n.taskCompleteSuccess);
      }
    } on Object {
      if (mounted) {
        showAppSnackBar(context: context, message: l10n.taskCompleteError);
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }
}

class _TaskDetailsContent extends StatelessWidget {
  const _TaskDetailsContent({
    required this.task,
    required this.assignee,
    required this.canAssignSelf,
    required this.isAdmin,
    required this.isUpdating,
    required this.onAssignSelf,
    required this.onComplete,
  });

  final RivalTask task;
  final GroupMember? assignee;
  final bool canAssignSelf;
  final bool isAdmin;
  final bool isUpdating;
  final VoidCallback? onAssignSelf;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;

    return AppRefreshIndicator(
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        task.status == TaskStatus.completed
                            ? Icons.verified_rounded
                            : Icons.assignment_rounded,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 10),
                      Chip(
                        label: Text(
                          task.status == TaskStatus.completed
                              ? l10n.taskStatusCompleted
                              : l10n.taskStatusActive,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      task.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        label: Text(l10n.taskRewardPoints(task.rewardPoints)),
                      ),
                      Chip(
                        label: Text(
                          task.dueAt == null
                              ? l10n.taskNoDueDate
                              : l10n.taskDueDate(
                                  formatAppDateTime(context, task.dueAt),
                                ),
                        ),
                      ),
                      Chip(
                        label: Text(
                          l10n.wagerCreatedAt(
                            formatAppDateTime(context, task.createdAt),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
              leading: CircleAvatar(
                backgroundImage: assignee?.avatarUrl == null
                    ? null
                    : NetworkImage(assignee!.avatarUrl!),
                child: assignee?.avatarUrl == null
                    ? const Icon(Icons.person_outline_rounded)
                    : null,
              ),
              title: Text(l10n.taskAssignee),
              subtitle: Text(assignee?.displayName ?? l10n.taskUnassigned),
            ),
          ),
          if (canAssignSelf) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: isUpdating ? null : onAssignSelf,
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: Text(l10n.taskAssignSelf),
            ),
          ],
          if (isAdmin && task.status == TaskStatus.active) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: isUpdating || task.assignedUserId == null
                  ? null
                  : onComplete,
              icon: const Icon(Icons.verified_rounded),
              label: Text(l10n.taskCompleteAction),
            ),
          ],
        ],
      ),
    );
  }
}
