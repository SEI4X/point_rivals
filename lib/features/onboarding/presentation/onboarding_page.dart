import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:point_rivals/app/dependencies/app_dependencies.dart';
import 'package:point_rivals/app/session/app_session_controller.dart';
import 'package:point_rivals/core/firebase/firebase_contracts.dart';
import 'package:point_rivals/core/l10n/l10n.dart';
import 'package:point_rivals/core/routing/app_router.dart';
import 'package:point_rivals/core/widgets/app_snack_bar.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _pageIndex = 0;
  bool _isSigningIn = false;
  bool _isRequestingNotifications = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    await _pageController.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _signIn(Future<void> Function() signInAction) async {
    if (_isSigningIn) {
      return;
    }

    setState(() => _isSigningIn = true);
    try {
      await signInAction();
      if (mounted) {
        await _next();
      }
    } on AuthCancelledException {
      return;
    } on Object catch (error, stackTrace) {
      assert(() {
        debugPrint('Sign-in failed: $error');
        debugPrintStack(stackTrace: stackTrace);
        return true;
      }());

      if (mounted) {
        showAppSnackBar(
          context: context,
          message: context.l10n.authGenericError,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSigningIn = false);
      }
    }
  }

  Future<void> _requestNotifications() async {
    if (_isRequestingNotifications) {
      return;
    }

    setState(() => _isRequestingNotifications = true);
    final user = AppSessionScope.of(context).currentUser;
    try {
      final repository = AppDependenciesScope.of(
        context,
      ).notificationRepository;
      final granted = await repository.requestPermission();
      if (user != null) {
        if (granted) {
          await repository.registerDeviceToken(user.id);
        }
        await repository.setNotificationsEnabled(
          userId: user.id,
          enabled: granted,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRequestingNotifications = false);
        context.go(AppRoutes.groups);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final session = AppSessionScope.of(context);
    final showAppleSignIn =
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;

    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  l10n.appTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                _StepDot(active: _pageIndex == 0),
                const SizedBox(width: 6),
                _StepDot(active: _pageIndex == 1),
                const SizedBox(width: 6),
                _StepDot(active: _pageIndex == 2),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _pageIndex = index);
                },
                children: [
                  _OnboardingStep(
                    icon: Icons.sports_score_rounded,
                    title: l10n.onboardingTitle,
                    body: l10n.onboardingBody,
                    notice: l10n.onboardingGameNotice,
                    primarySignal: _Signal(
                      color: Theme.of(context).colorScheme.primary,
                      icon: Icons.assignment_rounded,
                      title: '+10',
                      label: l10n.onboardingTaskSignal,
                    ),
                    secondarySignal: _Signal(
                      color: Theme.of(context).colorScheme.secondary,
                      icon: Icons.verified_rounded,
                      title: l10n.groupAdminBadge,
                      label: l10n.onboardingJudgeSignal,
                    ),
                    action: FilledButton(
                      onPressed: _next,
                      child: Text(l10n.onboardingNext),
                    ),
                  ),
                  _OnboardingStep(
                    icon: Icons.lock_rounded,
                    title: l10n.onboardingAuthTitle,
                    body: l10n.onboardingAuthBody,
                    primarySignal: _Signal(
                      color: Theme.of(context).colorScheme.primary,
                      icon: Icons.stars_rounded,
                      title: 'XP',
                      label: l10n.onboardingAuthSignal,
                    ),
                    secondarySignal: _Signal(
                      color: Theme.of(context).colorScheme.secondary,
                      icon: Icons.groups_2_rounded,
                      title: l10n.navGroups,
                      label: l10n.groupsEmptyBody,
                    ),
                    action: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (showAppleSignIn) ...[
                          FilledButton.icon(
                            onPressed: _isSigningIn
                                ? null
                                : () => _signIn(session.signInWithApple),
                            icon: const Icon(Icons.account_circle_rounded),
                            label: Text(l10n.onboardingAppleButton),
                          ),
                          const SizedBox(height: 10),
                        ],
                        OutlinedButton.icon(
                          onPressed: _isSigningIn
                              ? null
                              : () => _signIn(session.signInWithGoogle),
                          icon: const Icon(Icons.g_mobiledata_rounded),
                          label: Text(l10n.onboardingGoogleButton),
                        ),
                      ],
                    ),
                  ),
                  _OnboardingStep(
                    icon: Icons.notifications_active_rounded,
                    title: l10n.onboardingNotificationsTitle,
                    body: l10n.onboardingNotificationsBody,
                    notice: l10n.onboardingGameNotice,
                    primarySignal: _Signal(
                      color: Theme.of(context).colorScheme.primary,
                      icon: Icons.notifications_active_rounded,
                      title: l10n.groupTasksTab,
                      label: l10n.onboardingNotifySignal,
                    ),
                    secondarySignal: _Signal(
                      color: Theme.of(context).colorScheme.secondary,
                      icon: Icons.sports_score_rounded,
                      title: l10n.groupWagersTab,
                      label: l10n.onboardingNotificationsBody,
                    ),
                    action: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FilledButton.icon(
                          onPressed: _isRequestingNotifications
                              ? null
                              : _requestNotifications,
                          icon: const Icon(Icons.notifications_none_rounded),
                          label: Text(l10n.onboardingNotificationsAction),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () => context.go(AppRoutes.groups),
                          child: Text(l10n.onboardingStart),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: active ? 28 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? colors.primary : colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }
}

class _OnboardingStep extends StatelessWidget {
  const _OnboardingStep({
    required this.icon,
    required this.title,
    required this.body,
    required this.action,
    required this.primarySignal,
    required this.secondarySignal,
    this.notice,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? notice;
  final _Signal primarySignal;
  final _Signal secondarySignal;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return TweenAnimationBuilder<double>(
      key: ValueKey(title),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surfaceContainer,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(18),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 36,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: colors.primary,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Icon(
                                icon,
                                color: colors.onPrimary,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          Text(title, style: textTheme.headlineMedium),
                          const SizedBox(height: 12),
                          Text(
                            body,
                            style: textTheme.bodyLarge?.copyWith(
                              color: colors.onSurfaceVariant,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 28),
                          _SignalCard(
                            color: primarySignal.color,
                            icon: primarySignal.icon,
                            title: primarySignal.title,
                            label: primarySignal.label,
                          ),
                          const SizedBox(height: 10),
                          _SignalCard(
                            color: secondarySignal.color,
                            icon: secondarySignal.icon,
                            title: secondarySignal.title,
                            label: secondarySignal.label,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          action,
        ],
      ),
    );
  }
}

final class _Signal {
  const _Signal({
    required this.color,
    required this.icon,
    required this.title,
    required this.label,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String label;
}

class _SignalCard extends StatelessWidget {
  const _SignalCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.label,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
