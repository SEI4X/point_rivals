import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:point_rivals/app/app.dart';
import 'package:point_rivals/app/dependencies/app_dependencies.dart';
import 'package:point_rivals/features/profile/domain/profile_models.dart';

void main() {
  testWidgets('renders the English onboarding by default', (tester) async {
    await tester.pumpWidget(
      PointRivalsApp(enableAndroidForegroundNotifications: false),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tasks and wagers for points'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('renders the Russian onboarding when locale is Russian', (
    tester,
  ) async {
    await tester.pumpWidget(
      PointRivalsApp(
        locale: const Locale('ru'),
        enableAndroidForegroundNotifications: false,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Задания и ставки за баллы'), findsOneWidget);
    expect(find.text('Дальше'), findsOneWidget);
  });

  testWidgets('renders signed-in tabs', (tester) async {
    const profile = UserProfile(
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
    );

    await tester.pumpWidget(
      PointRivalsApp(
        enableAndroidForegroundNotifications: false,
        dependencies: AppDependencies(
          authRepository: MemoryAuthRepository(initialProfile: profile),
          groupRepository: MemoryGroupRepository(),
          wagerRepository: MemoryWagerRepository(),
          taskRepository: MemoryTaskRepository(),
          notificationRepository: MemoryNotificationRepository(),
          profileMediaRepository: MemoryProfileMediaRepository(),
          activityRepository: MemoryActivityRepository(),
          publicProfileRepository: MemoryPublicProfileRepository(),
          achievementRepository: MemoryAchievementRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(find.text('Groups'), findsWidgets);
    expect(find.text('No groups yet'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.person_outline_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsWidgets);
    expect(find.text('Alex'), findsOneWidget);
  });
}
