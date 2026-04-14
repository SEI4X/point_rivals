# Point Rivals Implementation Plan

Point Rivals is a real Firebase-backed Flutter product where people play with group-local points, not money. Users create groups, join by code or QR, create wagers, place point bets, and earn global XP from participation and outcomes.

## Product Vocabulary

- **Group tokens**: group-local points used for wagers. They never leave the group and are not money.
- **XP**: global profile progression from level 1 to 100.
- **Wager**: a group event with two possible sides.
- **Stake**: a user's committed group tokens on one wager side.
- **Admin**: a group member allowed to confirm outcomes and manage members.

## Phase 1: Foundation

- Feature-first layered structure for onboarding, groups, wagers, profile, and settings.
- Light, dark, and system theme support.
- Localized navigation and first screens in English and Russian.
- Firebase dependencies and service boundaries.
- Domain models for users, groups, wagers, stakes, odds, XP, and settings.
- Unit tests for pure domain rules.

## Phase 2: Firebase Integration

- Configure Firebase with FlutterFire CLI.
- Add Firebase initialization in app bootstrap.
- Implement AuthRepository with Apple and Google sign-in.
- Implement Firestore repositories for groups, memberships, wagers, stakes, and profiles.
- Add Firebase Messaging permission and token registration.
- Add soft-delete account flow with `isActive = false`.

## Phase 3: Onboarding

- Explain the game and that it is not money.
- Apple Auth and Google Auth.
- Name entry and avatar selection.
- Notification permission request.
- Route authenticated users to groups.

## Phase 4: Groups

- All groups screen with group tiles: name, members, active wagers, my token balance.
- Join by invite code or QR.
- Create group flow.
- Group detail screen with members, admins, top 3 leaders by week/all-time, active wagers, archive.
- Group settings for admins.

## Phase 5: Wagers

- Create wager flow with condition, excluded participants, type, and custom labels.
- Active wager list with side buttons, odds, participant ratio, and confirmation.
- Admin outcome confirmation.
- Archive with resolved wagers.

## Phase 6: Profile And Settings

- Profile stats: avatar, name, level, XP progress, total wagers, correct wagers, accuracy, total earned tokens.
- Settings: name, theme mode, notifications, sign out, soft-delete with 10-second confirmation delay.

## Phase 7: Hardening

- Firestore security rules.
- Offline and retry behavior.
- Analytics-free privacy review unless analytics is explicitly added.
- Push notification flows.
- Integration tests for critical journeys.
- Release configuration for iOS and Android.

## Required Quality Gates

- No user-facing strings outside ARB files.
- `flutter analyze` passes.
- `flutter test` passes.
- New behavior has unit tests.
- UI state changes have widget tests.
