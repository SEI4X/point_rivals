import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:point_rivals/app/dependencies/app_dependencies.dart';
import 'package:point_rivals/app/session/app_session_controller.dart';
import 'package:point_rivals/core/l10n/l10n.dart';
import 'package:point_rivals/core/routing/app_router.dart';
import 'package:point_rivals/core/widgets/app_snack_bar.dart';
import 'package:point_rivals/features/groups/domain/group_models.dart';
import 'package:point_rivals/features/tasks/domain/task_constraints.dart';
import 'package:point_rivals/features/tasks/domain/task_models.dart';

class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({required this.groupId, super.key});

  final String groupId;

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rewardPointsController = TextEditingController(
    text: TaskConstraints.defaultRewardPoints.toString(),
  );

  String? _assignedUserId;
  DateTime? _dueAt;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _rewardPointsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving || !_formKey.currentState!.validate()) {
      return;
    }

    final l10n = context.l10n;
    final user = AppSessionScope.of(context).currentUser;
    if (user == null) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      final draft = TaskDraft(
        groupId: widget.groupId,
        creatorUserId: user.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        assignedUserId: _assignedUserId,
        rewardPoints:
            int.tryParse(_rewardPointsController.text.trim()) ??
            TaskConstraints.defaultRewardPoints,
        dueAt: _dueAt,
      );
      await AppDependenciesScope.of(context).taskRepository.createTask(draft);
      if (mounted) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(AppRoutes.group(widget.groupId));
        }
      }
    } on Object {
      if (mounted) {
        showAppSnackBar(context: context, message: l10n.createTaskError);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _selectDueDate() async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _dueAt ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 3),
    );
    if (selectedDate == null) {
      return;
    }

    setState(() => _dueAt = selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dependencies = AppDependenciesScope.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.createTaskTitle),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: StreamBuilder<List<GroupMember>>(
          stream: dependencies.groupRepository.watchMembers(widget.groupId),
          builder: (context, snapshot) {
            final members = snapshot.data ?? const <GroupMember>[];

            return Form(
              key: _formKey,
              child: ListView(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _titleController,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: l10n.createTaskTitleLabel,
                            ),
                            validator: (value) {
                              final title = value?.trim() ?? '';
                              if (title.isEmpty) {
                                return l10n.createTaskTitleRequired;
                              }

                              if (title.length >
                                  TaskConstraints.maxTitleLength) {
                                return l10n.createTaskTitleTooLong(
                                  TaskConstraints.maxTitleLength,
                                );
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _descriptionController,
                            minLines: 3,
                            maxLines: 5,
                            textInputAction: TextInputAction.newline,
                            decoration: InputDecoration(
                              labelText: l10n.createTaskDescriptionLabel,
                            ),
                            validator: (value) {
                              final description = value?.trim() ?? '';
                              if (description.length >
                                  TaskConstraints.maxDescriptionLength) {
                                return l10n.createTaskDescriptionTooLong(
                                  TaskConstraints.maxDescriptionLength,
                                );
                              }

                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          DropdownButtonFormField<String?>(
                            initialValue: _assignedUserId,
                            decoration: InputDecoration(
                              labelText: l10n.createTaskAssigneeLabel,
                            ),
                            items: [
                              DropdownMenuItem<String?>(
                                child: Text(l10n.createTaskUnassigned),
                              ),
                              for (final member in members)
                                DropdownMenuItem<String?>(
                                  value: member.userId,
                                  child: Text(member.displayName),
                                ),
                            ],
                            onChanged: (value) {
                              setState(() => _assignedUserId = value);
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _rewardPointsController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: l10n.createTaskRewardPointsLabel,
                              helperText: l10n.createTaskRewardPointsHelper,
                            ),
                            validator: (value) {
                              final amount = int.tryParse(value?.trim() ?? '');
                              if (amount == null || amount <= 0) {
                                return l10n.wagerStakeAmountInvalid;
                              }

                              if (amount > TaskConstraints.maxRewardPoints) {
                                return l10n.createTaskRewardPointsTooHigh(
                                  TaskConstraints.maxRewardPoints,
                                );
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _selectDueDate,
                            icon: const Icon(Icons.event_rounded),
                            label: Text(
                              _dueAt == null
                                  ? l10n.createTaskDueDateAction
                                  : l10n.createTaskDueDateValue(
                                      MaterialLocalizations.of(
                                        context,
                                      ).formatMediumDate(_dueAt!),
                                    ),
                            ),
                          ),
                          if (_dueAt != null)
                            TextButton(
                              onPressed: () => setState(() => _dueAt = null),
                              child: Text(l10n.createTaskClearDueDate),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.commonSave),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
