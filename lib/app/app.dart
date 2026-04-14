import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:point_rivals/app/android_foreground_notifications.dart';
import 'package:point_rivals/app/dependencies/app_dependencies.dart';
import 'package:point_rivals/app/session/app_session_controller.dart';
import 'package:point_rivals/app/settings/app_settings_controller.dart';
import 'package:point_rivals/app/theme/app_theme.dart';
import 'package:point_rivals/core/firebase/firebase_contracts.dart';
import 'package:point_rivals/core/l10n/l10n.dart';
import 'package:point_rivals/core/routing/app_router.dart';
import 'package:point_rivals/core/widgets/app_refresh_indicator.dart';
import 'package:point_rivals/core/widgets/top_snack_bar.dart';

class PointRivalsApp extends StatefulWidget {
  PointRivalsApp({
    super.key,
    this.locale,
    AppDependencies? dependencies,
    this.sessionController,
    AppSettingsController? settingsController,
    this.enableAndroidForegroundNotifications = true,
  }) : dependencies = dependencies ?? AppDependencies.memory(),
       settingsController =
           settingsController ?? AppSettingsController.memory();

  final Locale? locale;
  final AppDependencies dependencies;
  final AppSessionController? sessionController;
  final AppSettingsController settingsController;
  final bool enableAndroidForegroundNotifications;

  @override
  State<PointRivalsApp> createState() => _PointRivalsAppState();
}

class _PointRivalsAppState extends State<PointRivalsApp> {
  late final AppSessionController _sessionController;
  late final GoRouter _router;
  StreamSubscription<String>? _notificationOpenSubscription;
  StreamSubscription<IncomingNotification>? _foregroundNotificationSubscription;
  AndroidForegroundNotifications? _androidForegroundNotifications;
  String? _registeredNotificationUserId;

  @override
  void initState() {
    super.initState();
    _sessionController =
        widget.sessionController ??
        AppSessionController(
          authRepository: widget.dependencies.authRepository,
        );
    _sessionController.addListener(_syncNotificationRegistration);
    _sessionController.start();
    _router = createAppRouter(_sessionController);
    _notificationOpenSubscription = widget.dependencies.notificationRepository
        .notificationGroupOpenRequests()
        .listen(_openGroup);
    _foregroundNotificationSubscription = widget
        .dependencies
        .notificationRepository
        .foregroundNotifications()
        .listen(_showForegroundNotification);
    if (widget.enableAndroidForegroundNotifications) {
      _androidForegroundNotifications = AndroidForegroundNotifications();
      unawaited(
        _androidForegroundNotifications?.initialize(onOpenGroup: _openGroup),
      );
    }
    unawaited(_openInitialNotificationGroup());
  }

  @override
  void dispose() {
    _sessionController.removeListener(_syncNotificationRegistration);
    if (widget.sessionController == null) {
      _sessionController.dispose();
    }
    unawaited(_notificationOpenSubscription?.cancel());
    unawaited(_foregroundNotificationSubscription?.cancel());
    _router.dispose();
    super.dispose();
  }

  Future<void> _openInitialNotificationGroup() async {
    final groupId = await widget.dependencies.notificationRepository
        .initialNotificationGroupId();
    if (groupId != null) {
      _openGroup(groupId);
    }
  }

  void _openGroup(String groupId) {
    _router.go(AppRoutes.group(groupId));
  }

  void _showForegroundNotification(IncomingNotification notification) {
    final context = _router.routerDelegate.navigatorKey.currentContext;
    if (context == null) {
      return;
    }

    unawaited(
      _androidForegroundNotifications?.show(
        notification: notification,
        channelName: context.l10n.notificationChannelName,
        onOpenGroup: _openGroup,
      ),
    );

    final message = notification.body.isEmpty
        ? notification.title
        : notification.body;
    showTopSnackBar(
      context: context,
      message: message,
      icon: Icons.notifications_active_rounded,
      iconColor: Theme.of(context).colorScheme.primary,
      onTap: notification.groupId == null
          ? null
          : () => _openGroup(notification.groupId!),
    );
  }

  void _syncNotificationRegistration() {
    final user = _sessionController.currentUser;
    if (user == null || !user.notificationsEnabled) {
      _registeredNotificationUserId = null;
      return;
    }

    if (_registeredNotificationUserId == user.id) {
      return;
    }

    _registeredNotificationUserId = user.id;
    unawaited(_registerNotificationToken(user.id));
  }

  Future<void> _registerNotificationToken(String userId) async {
    try {
      await widget.dependencies.notificationRepository.registerDeviceToken(
        userId,
      );
    } on Object catch (error, stackTrace) {
      if (_registeredNotificationUserId == userId) {
        _registeredNotificationUserId = null;
      }
      debugPrint('Notification token registration failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppSettingsScope(
      controller: widget.settingsController,
      child: AppDependenciesScope(
        dependencies: widget.dependencies,
        child: AppSessionScope(
          controller: _sessionController,
          child: AnimatedBuilder(
            animation: widget.settingsController,
            builder: (context, child) {
              return AppRefreshScope(
                child: MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  locale: widget.locale,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  onGenerateTitle: (context) => context.l10n.appTitle,
                  routerConfig: _router,
                  supportedLocales: AppLocalizations.supportedLocales,
                  theme: AppTheme.light(),
                  darkTheme: AppTheme.dark(),
                  themeMode: widget.settingsController.themeMode,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
