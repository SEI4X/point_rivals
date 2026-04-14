import 'package:flutter_test/flutter_test.dart';
import 'package:point_rivals/app/dependencies/app_dependencies.dart';
import 'package:point_rivals/app/session/app_session_controller.dart';
import 'package:point_rivals/features/profile/domain/profile_models.dart';

void main() {
  test('starts with an existing active user from auth state', () async {
    final repository = MemoryAuthRepository(
      initialProfile: const UserProfile(
        id: 'user-1',
        displayName: 'Alex',
        avatarUrl: null,
        isActive: true,
        xp: 0,
        totalWagers: 0,
        correctWagers: 0,
        totalTokensEarned: 0,
        notificationsEnabled: false,
        themePreference: AppThemePreference.system,
      ),
    );
    final controller = AppSessionController(authRepository: repository);

    controller.start();
    await pumpEventQueue();

    expect(controller.isLoading, isFalse);
    expect(controller.isSignedIn, isTrue);
    expect(controller.currentUser?.id, 'user-1');

    controller.dispose();
  });

  test('signs in and signs out through auth repository', () async {
    final controller = AppSessionController(
      authRepository: MemoryAuthRepository(),
    );

    controller.start();
    await pumpEventQueue();

    expect(controller.isSignedIn, isFalse);

    await controller.signInWithGoogle();

    expect(controller.isSignedIn, isTrue);
    expect(controller.currentUser?.id, 'memory-user');

    await controller.signOut();

    expect(controller.isSignedIn, isFalse);
    expect(controller.currentUser, isNull);

    controller.dispose();
  });
}
