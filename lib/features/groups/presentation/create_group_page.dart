import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:point_rivals/app/dependencies/app_dependencies.dart';
import 'package:point_rivals/app/session/app_session_controller.dart';
import 'package:point_rivals/core/l10n/l10n.dart';
import 'package:point_rivals/core/routing/app_router.dart';
import 'package:point_rivals/core/widgets/app_snack_bar.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isSaving = false;

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
    final session = AppSessionScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final user = session.currentUser;
    if (user == null) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      final group = await AppDependenciesScope.of(context).groupRepository
          .createGroup(name: _nameController.text.trim(), owner: user);

      if (mounted) {
        context.pushReplacement(AppRoutes.group(group.id));
      }
    } on Object {
      if (mounted) {
        showAppSnackBarOnMessenger(
          messenger: messenger,
          message: l10n.groupCreateError,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.groupsCreateTooltip),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(labelText: l10n.groupNameLabel),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.groupNameRequired;
                  }

                  return null;
                },
                onFieldSubmitted: (_) => _save(),
              ),
              const Spacer(),
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
        ),
      ),
    );
  }
}
