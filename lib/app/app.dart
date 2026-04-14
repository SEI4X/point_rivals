import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:point_rivals/app/dependencies/app_dependencies.dart';
import 'package:point_rivals/app/session/app_session_controller.dart';
import 'package:point_rivals/app/settings/app_settings_controller.dart';
import 'package:point_rivals/app/theme/app_theme.dart';
import 'package:point_rivals/app/wagers/wager_result_listener.dart';
import 'package:point_rivals/core/l10n/l10n.dart';
import 'package:point_rivals/core/routing/app_router.dart';

class PointRivalsApp extends StatefulWidget {
  PointRivalsApp({
    super.key,
    this.locale,
    AppDependencies? dependencies,
    this.sessionController,
    AppSettingsController? settingsController,
  }) : dependencies = dependencies ?? AppDependencies.memory(),
       settingsController =
           settingsController ?? AppSettingsController.memory();

  final Locale? locale;
  final AppDependencies dependencies;
  final AppSessionController? sessionController;
  final AppSettingsController settingsController;

  @override
  State<PointRivalsApp> createState() => _PointRivalsAppState();
}

class _PointRivalsAppState extends State<PointRivalsApp> {
  late final AppSessionController _sessionController;
  late final GoRouter _router;
  StreamSubscription<String>? _notificationOpenSubscription;

  @override
  void initState() {
    super.initState();
    _sessionController =
        widget.sessionController ??
        AppSessionController(
          authRepository: widget.dependencies.authRepository,
        );
    _sessionController.start();
    _router = createAppRouter(_sessionController);
    _notificationOpenSubscription = widget.dependencies.notificationRepository
        .notificationGroupOpenRequests()
        .listen(_openGroup);
    unawaited(_openInitialNotificationGroup());
  }

  @override
  void dispose() {
    if (widget.sessionController == null) {
      _sessionController.dispose();
    }
    unawaited(_notificationOpenSubscription?.cancel());
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
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                locale: widget.locale,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                onGenerateTitle: (context) => context.l10n.appTitle,
                routerConfig: _router,
                builder: (context, child) {
                  return WagerResultListener(
                    child: child ?? const SizedBox.shrink(),
                  );
                },
                supportedLocales: AppLocalizations.supportedLocales,
                theme: AppTheme.light(),
                darkTheme: AppTheme.dark(),
                themeMode: widget.settingsController.themeMode,
              );
            },
          ),
        ),
      ),
    );
  }
}
