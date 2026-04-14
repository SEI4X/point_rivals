import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:point_rivals/app/dependencies/app_dependencies.dart';
import 'package:point_rivals/app/session/app_session_controller.dart';
import 'package:point_rivals/app/settings/app_settings_controller.dart';
import 'package:point_rivals/core/l10n/l10n.dart';
import 'package:point_rivals/core/routing/app_router.dart';
import 'package:point_rivals/core/widgets/app_shimmer.dart';
import 'package:point_rivals/core/widgets/app_snack_bar.dart';
import 'package:point_rivals/features/profile/domain/profile_models.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isNameDirty = false;
  bool _isSavingProfile = false;
  bool _isUploadingAvatar = false;
  bool _isUpdatingNotifications = false;
  final _imagePicker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_isSavingProfile || !_formKey.currentState!.validate()) {
      return;
    }

    final l10n = context.l10n;
    final session = AppSessionScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final profile = session.currentUser;
    if (profile == null) {
      return;
    }

    setState(() => _isSavingProfile = true);
    try {
      await session.updateProfile(
        displayName: _nameController.text.trim(),
        avatarUrl: profile.avatarUrl,
      );

      if (mounted) {
        setState(() => _isNameDirty = false);
        showAppSnackBarOnMessenger(
          messenger: messenger,
          message: l10n.settingsProfileSaved,
        );
      }
    } on Object {
      if (mounted) {
        showAppSnackBarOnMessenger(
          messenger: messenger,
          message: l10n.settingsProfileSaveError,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingProfile = false);
      }
    }
  }

  Future<void> _setNotificationsEnabled(bool enabled) async {
    if (_isUpdatingNotifications) {
      return;
    }

    final l10n = context.l10n;
    final user = AppSessionScope.of(context).currentUser;
    final messenger = ScaffoldMessenger.of(context);
    if (user == null) {
      return;
    }

    setState(() => _isUpdatingNotifications = true);
    try {
      final repository = AppDependenciesScope.of(
        context,
      ).notificationRepository;
      var shouldEnable = enabled;
      if (enabled) {
        shouldEnable = await repository.requestPermission();
        if (shouldEnable) {
          await repository.registerDeviceToken(user.id);
        }
      }

      await repository.setNotificationsEnabled(
        userId: user.id,
        enabled: shouldEnable,
      );
    } on Object {
      if (mounted) {
        showAppSnackBarOnMessenger(
          messenger: messenger,
          message: l10n.settingsNotificationsError,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdatingNotifications = false);
      }
    }
  }

  Future<void> _changeAvatar() async {
    if (_isUploadingAvatar) {
      return;
    }

    final l10n = context.l10n;
    final session = AppSessionScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final mediaRepository = AppDependenciesScope.of(
      context,
    ).profileMediaRepository;
    final profile = session.currentUser;
    if (profile == null) {
      return;
    }

    final XFile? image;
    try {
      image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 88,
      );
    } on Object {
      if (mounted) {
        showAppSnackBarOnMessenger(
          messenger: messenger,
          message: l10n.settingsPhotoPermissionDenied,
        );
      }
      return;
    }

    if (image == null) {
      return;
    }

    final bytes = await image.readAsBytes();
    if (!mounted) {
      return;
    }

    setState(() => _isUploadingAvatar = true);
    try {
      final avatarUrl = await mediaRepository.uploadAvatar(
        userId: profile.id,
        bytes: bytes,
        fileName: image.name,
        contentType: image.mimeType,
      );
      await session.updateProfile(
        displayName: _nameController.text.trim().isEmpty
            ? profile.displayName
            : _nameController.text.trim(),
        avatarUrl: avatarUrl,
      );
    } on Object {
      if (mounted) {
        showAppSnackBarOnMessenger(
          messenger: messenger,
          message: l10n.settingsAvatarError,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
      }
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final profile = AppSessionScope.of(context).currentUser;
    if (profile == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _DeleteAccountDialog(),
    );
    if (confirmed != true || !mounted) {
      return;
    }

    final l10n = context.l10n;
    final dependencies = AppDependenciesScope.of(context);
    final session = AppSessionScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    try {
      await dependencies.notificationRepository.unregisterDeviceToken(
        profile.id,
      );
      await session.softDeleteAccount();
      if (mounted) {
        router.go(AppRoutes.onboarding);
      }
    } on Object {
      if (mounted) {
        showAppSnackBarOnMessenger(
          messenger: messenger,
          message: l10n.settingsDeleteError,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AppSessionController session = AppSessionScope.of(context);
    final AppSettingsController settings = AppSettingsScope.of(context);
    final profile = session.currentUser;

    if (profile == null) {
      return const Scaffold(
        body: SafeArea(
          minimum: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: AppSkeletonList(),
        ),
      );
    }

    if (!_isNameDirty) {
      _nameController.text = profile.displayName;
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.settingsTitle),
        actions: [
          TextButton(
            onPressed: _isSavingProfile ? null : _saveProfile,
            child: _isSavingProfile
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
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _ProfileCard(
                profile: profile,
                nameController: _nameController,
                isUploadingAvatar: _isUploadingAvatar,
                onChangeAvatar: _changeAvatar,
                onNameChanged: () => setState(() => _isNameDirty = true),
                onSubmitted: _saveProfile,
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.brightness_auto_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            l10n.settingsTheme,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SegmentedButton<AppThemePreference>(
                        segments: [
                          ButtonSegment<AppThemePreference>(
                            value: AppThemePreference.system,
                            label: Text(l10n.settingsThemeSystem),
                          ),
                          ButtonSegment<AppThemePreference>(
                            value: AppThemePreference.light,
                            label: Text(l10n.settingsThemeLight),
                          ),
                          ButtonSegment<AppThemePreference>(
                            value: AppThemePreference.dark,
                            label: Text(l10n.settingsThemeDark),
                          ),
                        ],
                        selected: {settings.themePreference},
                        onSelectionChanged: (selection) async {
                          await settings.setThemePreference(selection.single);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                  value: profile.notificationsEnabled,
                  onChanged: _isUpdatingNotifications
                      ? null
                      : _setNotificationsEnabled,
                  secondary: _isUpdatingNotifications
                      ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.notifications_rounded),
                  title: Text(l10n.settingsNotifications),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                      ),
                      leading: const Icon(Icons.logout_rounded),
                      title: Text(l10n.settingsSignOut),
                      onTap: () async {
                        await AppDependenciesScope.of(context)
                            .notificationRepository
                            .unregisterDeviceToken(profile.id);
                        await session.signOut();
                        if (context.mounted) {
                          context.go(AppRoutes.onboarding);
                        }
                      },
                    ),
                    const Divider(indent: 14, endIndent: 14),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                      ),
                      leading: Icon(
                        Icons.delete_forever_rounded,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      title: Text(
                        l10n.settingsDeleteAccount,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      subtitle: Text(l10n.settingsDeleteWarning),
                      onTap: _confirmDeleteAccount,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.profile,
    required this.nameController,
    required this.isUploadingAvatar,
    required this.onChangeAvatar,
    required this.onNameChanged,
    required this.onSubmitted,
  });

  final UserProfile profile;
  final TextEditingController nameController;
  final bool isUploadingAvatar;
  final VoidCallback onChangeAvatar;
  final VoidCallback onNameChanged;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Semantics(
              button: true,
              label: l10n.settingsAvatarAction,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: isUploadingAvatar ? null : onChangeAvatar,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: colors.surfaceContainerHigh,
                      backgroundImage: profile.avatarUrl == null
                          ? null
                          : NetworkImage(profile.avatarUrl!),
                      foregroundColor: colors.primary,
                      child: profile.avatarUrl == null
                          ? const Icon(Icons.person_rounded, size: 30)
                          : null,
                    ),
                    PositionedDirectional(
                      end: -2,
                      bottom: -2,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: isUploadingAvatar
                              ? SizedBox.square(
                                  dimension: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colors.onPrimary,
                                  ),
                                )
                              : Icon(
                                  Icons.photo_camera_rounded,
                                  size: 14,
                                  color: colors.onPrimary,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l10n.onboardingNameLabel,
                  prefixIcon: const Icon(Icons.badge_rounded),
                ),
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.settingsProfileNameRequired;
                  }

                  return null;
                },
                onChanged: (_) => onNameChanged(),
                onFieldSubmitted: (_) => onSubmitted(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  static const int _delaySeconds = 10;
  Timer? _timer;
  int _remainingSeconds = _delaySeconds;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        return;
      }

      setState(() {
        _remainingSeconds = (_remainingSeconds - 1).clamp(0, _delaySeconds);
      });

      if (_remainingSeconds == 0) {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canConfirm = _remainingSeconds == 0;

    return AlertDialog(
      title: Text(l10n.settingsDeleteTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.settingsDeleteBody),
          const SizedBox(height: 14),
          if (!canConfirm)
            Chip(
              avatar: const Icon(Icons.timer_rounded, size: 18),
              label: Text(l10n.settingsDeleteCountdown(_remainingSeconds)),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: canConfirm ? () => Navigator.of(context).pop(true) : null,
          child: Text(l10n.commonConfirm),
        ),
      ],
    );
  }
}
