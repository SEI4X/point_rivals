import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:point_rivals/app/dependencies/app_dependencies.dart';
import 'package:point_rivals/app/session/app_session_controller.dart';
import 'package:point_rivals/core/l10n/l10n.dart';
import 'package:point_rivals/core/routing/app_router.dart';
import 'package:point_rivals/core/widgets/app_snack_bar.dart';
import 'package:point_rivals/features/groups/domain/group_models.dart';
import 'package:point_rivals/features/wagers/domain/wager_constraints.dart';
import 'package:point_rivals/features/wagers/domain/wager_models.dart';

class CreateWagerPage extends StatefulWidget {
  const CreateWagerPage({required this.groupId, super.key});

  final String groupId;

  @override
  State<CreateWagerPage> createState() => _CreateWagerPageState();
}

class _CreateWagerPageState extends State<CreateWagerPage> {
  final _formKey = GlobalKey<FormState>();
  final _conditionController = TextEditingController();
  final _leftLabelController = TextEditingController();
  final _rightLabelController = TextEditingController();
  final _rewardCoinsController = TextEditingController(
    text: WagerConstraints.defaultRewardCoins.toString(),
  );

  WagerType _type = WagerType.yesNo;
  final Set<String> _selectedParticipantIds = {};
  bool _isSaving = false;

  @override
  void dispose() {
    _conditionController.dispose();
    _leftLabelController.dispose();
    _rightLabelController.dispose();
    _rewardCoinsController.dispose();
    super.dispose();
  }

  Future<void> _save(List<GroupMember> members) async {
    if (_isSaving || !_formKey.currentState!.validate()) {
      return;
    }

    final l10n = context.l10n;
    final user = AppSessionScope.of(context).currentUser;
    if (user == null) {
      return;
    }
    final selectedParticipants = members
        .where((member) => _selectedParticipantIds.contains(member.userId))
        .toList();

    if (_type == WagerType.participantVsParticipant &&
        selectedParticipants.length != 2) {
      _showError(l10n.createWagerParticipantsRequired);
      return;
    }

    final draft = _buildDraft(l10n, selectedParticipants, user.id);
    if (draft == null) {
      _showError(l10n.createWagerOptionLabelRequired);
      return;
    }

    setState(() => _isSaving = true);
    try {
      await AppDependenciesScope.of(context).wagerRepository.createWager(draft);
      if (mounted) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(AppRoutes.group(widget.groupId));
        }
      }
    } on Object {
      if (mounted) {
        _showError(l10n.createWagerError);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  WagerDraft? _buildDraft(
    AppLocalizations l10n,
    List<GroupMember> selectedParticipants,
    String creatorUserId,
  ) {
    final labels = switch (_type) {
      WagerType.yesNo => (l10n.wagerOptionYes, l10n.wagerOptionNo),
      WagerType.participantVsParticipant => (
        selectedParticipants[0].displayName,
        selectedParticipants[1].displayName,
      ),
      WagerType.custom => (
        _leftLabelController.text.trim(),
        _rightLabelController.text.trim(),
      ),
    };

    if (labels.$1.isEmpty || labels.$2.isEmpty) {
      return null;
    }

    return WagerDraft(
      groupId: widget.groupId,
      creatorUserId: creatorUserId,
      condition: _conditionController.text.trim(),
      type: _type,
      leftOption: WagerOption(side: WagerSide.left, label: labels.$1),
      rightOption: WagerOption(side: WagerSide.right, label: labels.$2),
      rewardCoins:
          int.tryParse(_rewardCoinsController.text.trim()) ??
          WagerConstraints.defaultRewardCoins,
      excludedUserIds: _selectedParticipantIds,
    );
  }

  void _showError(String message) {
    showAppSnackBar(context: context, message: message);
  }

  void _setType(WagerType type) {
    setState(() {
      _type = type;
      if (type == WagerType.participantVsParticipant &&
          _selectedParticipantIds.length > 2) {
        final firstTwo = _selectedParticipantIds.take(2).toSet();
        _selectedParticipantIds
          ..clear()
          ..addAll(firstTwo);
      }
    });
  }

  void _toggleParticipant(GroupMember member, bool selected) {
    setState(() {
      if (selected) {
        if (_type == WagerType.participantVsParticipant &&
            _selectedParticipantIds.length >= 2) {
          return;
        }

        _selectedParticipantIds.add(member.userId);
      } else {
        _selectedParticipantIds.remove(member.userId);
      }
    });
  }

  (String, String)? _previewLabels(
    AppLocalizations l10n,
    List<GroupMember> members,
  ) {
    final selectedParticipants = members
        .where((member) => _selectedParticipantIds.contains(member.userId))
        .toList();

    return switch (_type) {
      WagerType.yesNo => (l10n.wagerOptionYes, l10n.wagerOptionNo),
      WagerType.participantVsParticipant =>
        selectedParticipants.length == 2
            ? (
                selectedParticipants[0].displayName,
                selectedParticipants[1].displayName,
              )
            : null,
      WagerType.custom =>
        _leftLabelController.text.trim().isNotEmpty &&
                _rightLabelController.text.trim().isNotEmpty
            ? (
                _leftLabelController.text.trim(),
                _rightLabelController.text.trim(),
              )
            : null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final dependencies = AppDependenciesScope.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.createWagerTitle),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: StreamBuilder<List<GroupMember>>(
          stream: dependencies.groupRepository.watchMembers(widget.groupId),
          builder: (context, snapshot) {
            final members = snapshot.data ?? const <GroupMember>[];
            final previewLabels = _previewLabels(l10n, members);

            return Form(
              key: _formKey,
              child: ListView(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: TextFormField(
                        controller: _conditionController,
                        minLines: 2,
                        maxLines: 4,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          labelText: l10n.createWagerConditionLabel,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.createWagerConditionRequired;
                          }

                          if (value.trim().length >
                              WagerConstraints.maxConditionLength) {
                            return l10n.createWagerConditionTooLong(
                              WagerConstraints.maxConditionLength,
                            );
                          }

                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: TextFormField(
                        controller: _rewardCoinsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n.createWagerRewardCoinsLabel,
                          helperText: l10n.createWagerRewardCoinsHelper,
                        ),
                        validator: (value) {
                          final amount = int.tryParse(value?.trim() ?? '');
                          if (amount == null || amount <= 0) {
                            return l10n.wagerStakeAmountInvalid;
                          }

                          if (amount > WagerConstraints.maxRewardCoins) {
                            return l10n.createWagerRewardCoinsTooHigh(
                              WagerConstraints.maxRewardCoins,
                            );
                          }

                          return null;
                        },
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _WagerTypeCard(type: _type, onChanged: _setType),
                  const SizedBox(height: 12),
                  _ParticipantsCard(
                    type: _type,
                    members: members,
                    selectedParticipantIds: _selectedParticipantIds,
                    onChanged: _toggleParticipant,
                  ),
                  if (_type == WagerType.custom) ...[
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _leftLabelController,
                              decoration: InputDecoration(
                                labelText: l10n.createWagerLeftLabel,
                                prefixIcon: const Icon(
                                  Icons.arrow_back_rounded,
                                ),
                              ),
                              validator: (value) {
                                if (_type == WagerType.custom &&
                                    (value == null || value.trim().isEmpty)) {
                                  return l10n.createWagerOptionLabelRequired;
                                }

                                if (value != null &&
                                    value.trim().length >
                                        WagerConstraints.maxOptionLabelLength) {
                                  return l10n.createWagerOptionLabelTooLong(
                                    WagerConstraints.maxOptionLabelLength,
                                  );
                                }

                                return null;
                              },
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _rightLabelController,
                              decoration: InputDecoration(
                                labelText: l10n.createWagerRightLabel,
                                prefixIcon: const Icon(
                                  Icons.arrow_forward_rounded,
                                ),
                              ),
                              validator: (value) {
                                if (_type == WagerType.custom &&
                                    (value == null || value.trim().isEmpty)) {
                                  return l10n.createWagerOptionLabelRequired;
                                }

                                if (value != null &&
                                    value.trim().length >
                                        WagerConstraints.maxOptionLabelLength) {
                                  return l10n.createWagerOptionLabelTooLong(
                                    WagerConstraints.maxOptionLabelLength,
                                  );
                                }

                                return null;
                              },
                              onChanged: (_) => setState(() {}),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _OutcomePreview(labels: previewLabels),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _isSaving ? null : () => _save(members),
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

class _WagerTypeCard extends StatelessWidget {
  const _WagerTypeCard({required this.type, required this.onChanged});

  final WagerType type;
  final ValueChanged<WagerType> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final helper = switch (type) {
      WagerType.yesNo => l10n.createWagerTypeHintYesNo,
      WagerType.participantVsParticipant =>
        l10n.createWagerTypeHintParticipants,
      WagerType.custom => l10n.createWagerTypeHintCustom,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tune_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  l10n.createWagerType,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  avatar: const Icon(Icons.rule_rounded, size: 18),
                  label: Text(l10n.createWagerTypeYesNo),
                  selected: type == WagerType.yesNo,
                  showCheckmark: false,
                  onSelected: (_) => onChanged(WagerType.yesNo),
                ),
                ChoiceChip(
                  avatar: const Icon(Icons.group_rounded, size: 18),
                  label: Text(l10n.createWagerTypeParticipants),
                  selected: type == WagerType.participantVsParticipant,
                  showCheckmark: false,
                  onSelected: (_) =>
                      onChanged(WagerType.participantVsParticipant),
                ),
                ChoiceChip(
                  avatar: const Icon(Icons.edit_note_rounded, size: 18),
                  label: Text(l10n.createWagerTypeCustom),
                  selected: type == WagerType.custom,
                  showCheckmark: false,
                  onSelected: (_) => onChanged(WagerType.custom),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              helper,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParticipantsCard extends StatelessWidget {
  const _ParticipantsCard({
    required this.type,
    required this.members,
    required this.selectedParticipantIds,
    required this.onChanged,
  });

  final WagerType type;
  final List<GroupMember> members;
  final Set<String> selectedParticipantIds;
  final void Function(GroupMember member, bool selected) onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isPairMode = type == WagerType.participantVsParticipant;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_pin_circle_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.createWagerExcludedParticipants,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Chip(
                  label: Text(
                    l10n.createWagerSelectedParticipants(
                      selectedParticipantIds.length,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.createWagerParticipantsHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            if (members.isEmpty)
              Text(
                l10n.createWagerNoMembers,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final member in members)
                    FilterChip(
                      showCheckmark: false,
                      avatar: CircleAvatar(
                        backgroundImage: member.avatarUrl == null
                            ? null
                            : NetworkImage(member.avatarUrl!),
                        child: member.avatarUrl == null
                            ? const Icon(Icons.person_rounded, size: 16)
                            : null,
                      ),
                      label: Text(member.displayName),
                      selected: selectedParticipantIds.contains(member.userId),
                      onSelected:
                          isPairMode &&
                              selectedParticipantIds.length >= 2 &&
                              !selectedParticipantIds.contains(member.userId)
                          ? null
                          : (selected) => onChanged(member, selected),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _OutcomePreview extends StatelessWidget {
  const _OutcomePreview({required this.labels});

  final (String, String)? labels;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final labels = this.labels;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.createWagerPreview,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.createWagerPreviewHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            Chip(
              avatar: const Icon(Icons.savings_rounded, size: 16),
              label: Text(l10n.createWagerRewardPreview),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: null,
                    child: Text(labels?.$1 ?? l10n.createWagerLeftLabel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: null,
                    child: Text(labels?.$2 ?? l10n.createWagerRightLabel),
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
