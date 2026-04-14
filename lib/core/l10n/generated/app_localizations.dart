import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// Application title.
  ///
  /// In en, this message translates to:
  /// **'Point Rivals'**
  String get appTitle;

  /// Home screen app bar title.
  ///
  /// In en, this message translates to:
  /// **'Point Rivals'**
  String get homeTitle;

  /// Primary message on the home screen.
  ///
  /// In en, this message translates to:
  /// **'Ready for the next match'**
  String get homeHeadline;

  /// Supporting message on the home screen.
  ///
  /// In en, this message translates to:
  /// **'Build every feature in small, tested layers.'**
  String get homeBody;

  /// Bottom navigation label for groups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get navGroups;

  /// Bottom navigation label for profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// Onboarding headline.
  ///
  /// In en, this message translates to:
  /// **'Tasks and wagers for points'**
  String get onboardingTitle;

  /// Onboarding body explaining the app.
  ///
  /// In en, this message translates to:
  /// **'Create group tasks, assign owners, finish them for points, and keep friendly wagers for match-day calls.'**
  String get onboardingBody;

  /// Notice explaining wagers are not money.
  ///
  /// In en, this message translates to:
  /// **'Points stay inside each group. Admins judge completed tasks and wager results.'**
  String get onboardingGameNotice;

  /// Apple sign-in button.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get onboardingAppleButton;

  /// Google sign-in button.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get onboardingGoogleButton;

  /// Name input label.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get onboardingNameLabel;

  /// Avatar selection action.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get onboardingPhotoAction;

  /// Notification permission action.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get onboardingNotificationsAction;

  /// Onboarding next button.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// Final onboarding action.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get onboardingStart;

  /// Onboarding authorization step title.
  ///
  /// In en, this message translates to:
  /// **'Save your wins'**
  String get onboardingAuthTitle;

  /// Onboarding authorization step body.
  ///
  /// In en, this message translates to:
  /// **'Sign in so your groups, tasks, points, and XP stay synced.'**
  String get onboardingAuthBody;

  /// Onboarding notifications step title.
  ///
  /// In en, this message translates to:
  /// **'Stay in the loop'**
  String get onboardingNotificationsTitle;

  /// Onboarding notifications step body.
  ///
  /// In en, this message translates to:
  /// **'Get a heads-up when a task is assigned to you or a wager is resolved.'**
  String get onboardingNotificationsBody;

  /// Onboarding task signal text.
  ///
  /// In en, this message translates to:
  /// **'Create a task, pick points, and assign an owner.'**
  String get onboardingTaskSignal;

  /// Onboarding admin judge signal text.
  ///
  /// In en, this message translates to:
  /// **'Admins confirm done work and settle wagers.'**
  String get onboardingJudgeSignal;

  /// Onboarding auth signal text.
  ///
  /// In en, this message translates to:
  /// **'Your points, groups, and wins follow your account.'**
  String get onboardingAuthSignal;

  /// Onboarding notification signal text.
  ///
  /// In en, this message translates to:
  /// **'Assigned tasks arrive as notifications.'**
  String get onboardingNotifySignal;

  /// Groups screen title.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groupsTitle;

  /// Tooltip for group search/join action.
  ///
  /// In en, this message translates to:
  /// **'Find or create group'**
  String get groupsSearchTooltip;

  /// Tooltip for create group action.
  ///
  /// In en, this message translates to:
  /// **'Create group'**
  String get groupsCreateTooltip;

  /// Number of members in a group.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {{count} member} other {{count} members}}'**
  String groupsMembersCount(int count);

  /// Number of active wagers in a group.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {{count} active wager} other {{count} active wagers}}'**
  String groupsActiveWagersCount(int count);

  /// Current user's group chip balance.
  ///
  /// In en, this message translates to:
  /// **'My chips: {amount}'**
  String groupsMyBalance(int amount);

  /// Another member's group chip balance.
  ///
  /// In en, this message translates to:
  /// **'Chips: {amount}'**
  String groupsMemberBalance(int amount);

  /// Empty state title for user's group list.
  ///
  /// In en, this message translates to:
  /// **'No groups yet'**
  String get groupsEmptyTitle;

  /// Empty state body for user's group list.
  ///
  /// In en, this message translates to:
  /// **'Create a group or join one with an invite code.'**
  String get groupsEmptyBody;

  /// Error message shown when the user's group list cannot load.
  ///
  /// In en, this message translates to:
  /// **'Groups could not be loaded. Please try again.'**
  String get groupsLoadError;

  /// Join group dialog title.
  ///
  /// In en, this message translates to:
  /// **'Join a group'**
  String get joinGroupTitle;

  /// Invite code input label.
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get joinGroupCodeLabel;

  /// Scan QR action.
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get joinGroupScanQr;

  /// Preview group action from invite code.
  ///
  /// In en, this message translates to:
  /// **'Find'**
  String get joinGroupPreviewButton;

  /// Join group button.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get joinGroupJoinButton;

  /// Profile screen title.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// Error shown when a public profile cannot load.
  ///
  /// In en, this message translates to:
  /// **'Profile could not be loaded. Please try again.'**
  String get profileLoadError;

  /// Empty state shown when a public profile does not exist.
  ///
  /// In en, this message translates to:
  /// **'Profile was not found.'**
  String get profileNotFound;

  /// Fallback display name when a user has not entered a name.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get profileUnnamed;

  /// Current global XP level.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String profileLevel(int level);

  /// XP progress in current level.
  ///
  /// In en, this message translates to:
  /// **'{current} / {target} XP'**
  String profileXpProgress(int current, int target);

  /// Short label for a user's group chip balance.
  ///
  /// In en, this message translates to:
  /// **'Chips'**
  String get profileChips;

  /// Short label for a user's XP.
  ///
  /// In en, this message translates to:
  /// **'XP'**
  String get profileXp;

  /// Profile total wagers label.
  ///
  /// In en, this message translates to:
  /// **'Total wagers'**
  String get profileTotalWagers;

  /// Profile correct wagers label.
  ///
  /// In en, this message translates to:
  /// **'Correct wagers'**
  String get profileCorrectWagers;

  /// Profile total group chips earned label.
  ///
  /// In en, this message translates to:
  /// **'Chips earned'**
  String get profileTotalEarned;

  /// Profile action to open current user's wagers.
  ///
  /// In en, this message translates to:
  /// **'My wagers'**
  String get profileMyWagers;

  /// Profile action to open current user's activity feed.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get profileActivity;

  /// Activity feed screen title.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activityTitle;

  /// Empty state for the activity feed.
  ///
  /// In en, this message translates to:
  /// **'No activity yet.'**
  String get activityEmpty;

  /// Activity title for a new wager.
  ///
  /// In en, this message translates to:
  /// **'New wager'**
  String get activityNewWagerTitle;

  /// Activity title for a won wager.
  ///
  /// In en, this message translates to:
  /// **'You won {amount} chips'**
  String activityResolvedWonTitle(int amount);

  /// Activity title for a resolved wager without payout.
  ///
  /// In en, this message translates to:
  /// **'Wager resolved'**
  String get activityResolvedTitle;

  /// Activity title for a completed task.
  ///
  /// In en, this message translates to:
  /// **'Task completed'**
  String get activityTaskCompletedTitle;

  /// Activity title for a cancelled wager.
  ///
  /// In en, this message translates to:
  /// **'Wager cancelled'**
  String get activityCancelledTitle;

  /// Activity card action hint.
  ///
  /// In en, this message translates to:
  /// **'Open group'**
  String get activityOpenGroup;

  /// Activity creation time.
  ///
  /// In en, this message translates to:
  /// **'Created {value}'**
  String activityCreatedAt(String value);

  /// Activity completion time.
  ///
  /// In en, this message translates to:
  /// **'Completed {value}'**
  String activityCompletedAt(String value);

  /// My wagers screen title.
  ///
  /// In en, this message translates to:
  /// **'My wagers'**
  String get myWagersTitle;

  /// Empty state for current user's wagers.
  ///
  /// In en, this message translates to:
  /// **'No wagers yet.'**
  String get myWagersEmpty;

  /// Active section in my wagers.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get myWagersActive;

  /// History section in my wagers.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get myWagersHistory;

  /// Current user's wager stake amount.
  ///
  /// In en, this message translates to:
  /// **'Staked {amount}'**
  String myWagersStake(int amount);

  /// Settings screen title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Theme setting label.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// System theme option.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// Light theme option.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// Dark theme option.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// Notifications setting label.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// Profile settings saved message.
  ///
  /// In en, this message translates to:
  /// **'Profile updated.'**
  String get settingsProfileSaved;

  /// Profile settings save error.
  ///
  /// In en, this message translates to:
  /// **'Profile was not updated. Please try again.'**
  String get settingsProfileSaveError;

  /// Validation error for missing profile name.
  ///
  /// In en, this message translates to:
  /// **'Enter your name.'**
  String get settingsProfileNameRequired;

  /// Change profile photo action.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get settingsAvatarAction;

  /// Profile photo update error.
  ///
  /// In en, this message translates to:
  /// **'Photo was not updated. Please try again.'**
  String get settingsAvatarError;

  /// Message shown when photo library permission is denied.
  ///
  /// In en, this message translates to:
  /// **'Allow photo access to choose a profile picture.'**
  String get settingsPhotoPermissionDenied;

  /// Notifications setting update error.
  ///
  /// In en, this message translates to:
  /// **'Notifications were not updated. Please try again.'**
  String get settingsNotificationsError;

  /// Sign out action.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get settingsSignOut;

  /// Delete account action.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get settingsDeleteAccount;

  /// Soft-delete warning text.
  ///
  /// In en, this message translates to:
  /// **'Account deletion is available after a 10-second confirmation delay.'**
  String get settingsDeleteWarning;

  /// Delete account confirmation title.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get settingsDeleteTitle;

  /// Delete account confirmation body.
  ///
  /// In en, this message translates to:
  /// **'Your account will be hidden and you will be signed out. This action is delayed for safety.'**
  String get settingsDeleteBody;

  /// Delete account countdown label.
  ///
  /// In en, this message translates to:
  /// **'You can confirm in {seconds} s'**
  String settingsDeleteCountdown(int seconds);

  /// Delete account error.
  ///
  /// In en, this message translates to:
  /// **'Account was not deleted. Please try again.'**
  String get settingsDeleteError;

  /// Group participant count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {{count} participant} other {{count} participants}}'**
  String groupMembers(int count);

  /// Group leaderboard title for the current calendar month.
  ///
  /// In en, this message translates to:
  /// **'Leaders (current month)'**
  String get groupMonthLeaders;

  /// Short label for the monthly leaderboard tab.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get groupMonthTab;

  /// All-time group leaderboard title.
  ///
  /// In en, this message translates to:
  /// **'All-time leaders'**
  String get groupAllTimeLeaders;

  /// Short label for the all-time leaderboard tab.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get groupAllTimeTab;

  /// Archive button label.
  ///
  /// In en, this message translates to:
  /// **'Wager archive'**
  String get groupWagerArchive;

  /// Active wagers section title.
  ///
  /// In en, this message translates to:
  /// **'Active wagers'**
  String get groupActiveWagers;

  /// Group work switcher wagers tab.
  ///
  /// In en, this message translates to:
  /// **'Wagers'**
  String get groupWagersTab;

  /// Group work switcher tasks tab.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get groupTasksTab;

  /// Empty state for active wagers list.
  ///
  /// In en, this message translates to:
  /// **'No active wagers yet.'**
  String get groupNoActiveWagers;

  /// Empty state for active task list.
  ///
  /// In en, this message translates to:
  /// **'No active tasks yet.'**
  String get groupNoActiveTasks;

  /// Admin badge label.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get groupAdminBadge;

  /// Create wager action.
  ///
  /// In en, this message translates to:
  /// **'Create wager'**
  String get groupCreateWager;

  /// Create task action.
  ///
  /// In en, this message translates to:
  /// **'Create task'**
  String get groupCreateTask;

  /// Group settings title.
  ///
  /// In en, this message translates to:
  /// **'Group settings'**
  String get groupSettingsTitle;

  /// Group name input label.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get groupNameLabel;

  /// Validation error for missing group name.
  ///
  /// In en, this message translates to:
  /// **'Enter a group name.'**
  String get groupNameRequired;

  /// Title for choosing a group's accent color.
  ///
  /// In en, this message translates to:
  /// **'Group color'**
  String get groupAccentColorTitle;

  /// Short explanation of where the group accent color appears.
  ///
  /// In en, this message translates to:
  /// **'Used for group cards, actions, and highlights.'**
  String get groupAccentColorSubtitle;

  /// Group invite code label.
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get groupInviteCode;

  /// Group invite QR label.
  ///
  /// In en, this message translates to:
  /// **'Invite QR'**
  String get groupInviteQr;

  /// Action that opens the system share sheet for a group invite.
  ///
  /// In en, this message translates to:
  /// **'Share invite'**
  String get groupInviteShareAction;

  /// Action that copies the group invite code.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get groupInviteCopyAction;

  /// Snackbar shown after copying a group invite code.
  ///
  /// In en, this message translates to:
  /// **'Invite code copied.'**
  String get groupInviteCopied;

  /// Text shared through the system share sheet for a group invite.
  ///
  /// In en, this message translates to:
  /// **'Join {groupName} in Point Rivals. Invite code: {inviteCode}'**
  String groupInviteShareText(String groupName, String inviteCode);

  /// Create group failure message.
  ///
  /// In en, this message translates to:
  /// **'Group was not created. Please try again.'**
  String get groupCreateError;

  /// Validation error for missing invite code.
  ///
  /// In en, this message translates to:
  /// **'Enter an invite code.'**
  String get joinGroupCodeRequired;

  /// Join group lookup failure message.
  ///
  /// In en, this message translates to:
  /// **'Group was not found. Check the code and try again.'**
  String get joinGroupError;

  /// Member count shown in join group preview.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {{count} member} other {{count} members}}'**
  String joinGroupMembersPreview(int count);

  /// Join group QR scanner title.
  ///
  /// In en, this message translates to:
  /// **'Scan invite QR'**
  String get joinGroupScanTitle;

  /// Join group QR scanner helper text.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at a group invite QR.'**
  String get joinGroupScanBody;

  /// Invalid join QR error.
  ///
  /// In en, this message translates to:
  /// **'This QR does not contain an invite code.'**
  String get joinGroupInvalidQr;

  /// QR scanner camera error.
  ///
  /// In en, this message translates to:
  /// **'Camera is unavailable. Enter the code instead.'**
  String get joinGroupCameraError;

  /// Group admins section title.
  ///
  /// In en, this message translates to:
  /// **'Admins'**
  String get groupAdmins;

  /// Group participants section title.
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get groupParticipants;

  /// Promote group member action.
  ///
  /// In en, this message translates to:
  /// **'Make admin'**
  String get groupPromoteMember;

  /// Demote group admin action.
  ///
  /// In en, this message translates to:
  /// **'Remove admin'**
  String get groupDemoteMember;

  /// Remove group member action.
  ///
  /// In en, this message translates to:
  /// **'Remove from group'**
  String get groupRemoveMember;

  /// Group member management error.
  ///
  /// In en, this message translates to:
  /// **'Member was not updated. Please try again.'**
  String get groupMemberActionError;

  /// Remove member confirmation title.
  ///
  /// In en, this message translates to:
  /// **'Remove member?'**
  String get groupRemoveMemberTitle;

  /// Remove member confirmation body.
  ///
  /// In en, this message translates to:
  /// **'This member will lose access to the group.'**
  String get groupRemoveMemberBody;

  /// Hint shown for current admin in group settings.
  ///
  /// In en, this message translates to:
  /// **'You cannot change your own admin role.'**
  String get groupSelfAdminHint;

  /// Create wager screen title.
  ///
  /// In en, this message translates to:
  /// **'Create wager'**
  String get createWagerTitle;

  /// Wager condition input label.
  ///
  /// In en, this message translates to:
  /// **'Wager condition'**
  String get createWagerConditionLabel;

  /// Validation error for missing wager condition.
  ///
  /// In en, this message translates to:
  /// **'Enter a wager condition.'**
  String get createWagerConditionRequired;

  /// Validation error for an overly long wager condition.
  ///
  /// In en, this message translates to:
  /// **'Keep the condition under {max} characters.'**
  String createWagerConditionTooLong(int max);

  /// Participants excluded from betting.
  ///
  /// In en, this message translates to:
  /// **'Participants in the wager'**
  String get createWagerExcludedParticipants;

  /// Helper text for wager participants.
  ///
  /// In en, this message translates to:
  /// **'People involved in the outcome cannot place bets.'**
  String get createWagerParticipantsHint;

  /// Selected wager participants count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {No participants selected} one {1 participant selected} other {{count} participants selected}}'**
  String createWagerSelectedParticipants(int count);

  /// Empty participant selector state.
  ///
  /// In en, this message translates to:
  /// **'No members available yet.'**
  String get createWagerNoMembers;

  /// Validation error for participant-vs-participant wager type.
  ///
  /// In en, this message translates to:
  /// **'Choose two participants for this wager type.'**
  String get createWagerParticipantsRequired;

  /// Wager type section label.
  ///
  /// In en, this message translates to:
  /// **'Wager type'**
  String get createWagerType;

  /// Yes/no wager type.
  ///
  /// In en, this message translates to:
  /// **'Yes / No'**
  String get createWagerTypeYesNo;

  /// Participant-vs-participant wager type.
  ///
  /// In en, this message translates to:
  /// **'Participant 1 / Participant 2'**
  String get createWagerTypeParticipants;

  /// Custom wager type.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get createWagerTypeCustom;

  /// Yes/no wager type helper.
  ///
  /// In en, this message translates to:
  /// **'Use this for outcomes with a clear yes or no.'**
  String get createWagerTypeHintYesNo;

  /// Participant wager type helper.
  ///
  /// In en, this message translates to:
  /// **'Choose exactly two people. They will become the two sides and cannot bet.'**
  String get createWagerTypeHintParticipants;

  /// Custom wager type helper.
  ///
  /// In en, this message translates to:
  /// **'Write your own labels for both sides.'**
  String get createWagerTypeHintCustom;

  /// Custom left option label.
  ///
  /// In en, this message translates to:
  /// **'Left button label'**
  String get createWagerLeftLabel;

  /// Custom right option label.
  ///
  /// In en, this message translates to:
  /// **'Right button label'**
  String get createWagerRightLabel;

  /// Validation error for missing custom option labels.
  ///
  /// In en, this message translates to:
  /// **'Enter both button labels.'**
  String get createWagerOptionLabelRequired;

  /// Validation error for overly long wager option labels.
  ///
  /// In en, this message translates to:
  /// **'Keep labels under {max} characters.'**
  String createWagerOptionLabelTooLong(int max);

  /// Create wager outcome preview label.
  ///
  /// In en, this message translates to:
  /// **'Outcome buttons'**
  String get createWagerPreview;

  /// Create wager preview helper text.
  ///
  /// In en, this message translates to:
  /// **'Correct picks earn the reward. Unpopular correct picks earn 1.5x.'**
  String get createWagerPreviewHint;

  /// Input label for the reward earned by correct wager picks.
  ///
  /// In en, this message translates to:
  /// **'Reward coins'**
  String get createWagerRewardCoinsLabel;

  /// Helper text for wager reward amount.
  ///
  /// In en, this message translates to:
  /// **'Correct players earn this amount. Unpopular correct picks earn 1.5x.'**
  String get createWagerRewardCoinsHelper;

  /// Validation error when reward amount is too high.
  ///
  /// In en, this message translates to:
  /// **'Maximum reward is {max} coins.'**
  String createWagerRewardCoinsTooHigh(int max);

  /// Create wager reward preview text.
  ///
  /// In en, this message translates to:
  /// **'Default reward is 10 coins.'**
  String get createWagerRewardPreview;

  /// Create wager stake range helper text.
  ///
  /// In en, this message translates to:
  /// **'Stake range: {min}-{max} chips.'**
  String createWagerStakeRangeHint(int min, int max);

  /// Create wager failure message.
  ///
  /// In en, this message translates to:
  /// **'Wager was not created. Please try again.'**
  String get createWagerError;

  /// Create task screen title.
  ///
  /// In en, this message translates to:
  /// **'Create task'**
  String get createTaskTitle;

  /// Task title input label.
  ///
  /// In en, this message translates to:
  /// **'Task name'**
  String get createTaskTitleLabel;

  /// Validation error for missing task title.
  ///
  /// In en, this message translates to:
  /// **'Enter a task name.'**
  String get createTaskTitleRequired;

  /// Validation error for long task title.
  ///
  /// In en, this message translates to:
  /// **'Keep the name under {max} characters.'**
  String createTaskTitleTooLong(int max);

  /// Optional task description input label.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get createTaskDescriptionLabel;

  /// Validation error for long task description.
  ///
  /// In en, this message translates to:
  /// **'Keep the description under {max} characters.'**
  String createTaskDescriptionTooLong(int max);

  /// Task assignee selector label.
  ///
  /// In en, this message translates to:
  /// **'Assignee'**
  String get createTaskAssigneeLabel;

  /// Create task assignee empty choice.
  ///
  /// In en, this message translates to:
  /// **'No assignee'**
  String get createTaskUnassigned;

  /// Task reward points input label.
  ///
  /// In en, this message translates to:
  /// **'Reward points'**
  String get createTaskRewardPointsLabel;

  /// Task reward helper text.
  ///
  /// In en, this message translates to:
  /// **'The assignee receives these points after admin approval.'**
  String get createTaskRewardPointsHelper;

  /// Validation error when task reward is too high.
  ///
  /// In en, this message translates to:
  /// **'Maximum reward is {max} points.'**
  String createTaskRewardPointsTooHigh(int max);

  /// Create task due date picker action.
  ///
  /// In en, this message translates to:
  /// **'Add due date'**
  String get createTaskDueDateAction;

  /// Selected task due date.
  ///
  /// In en, this message translates to:
  /// **'Due {value}'**
  String createTaskDueDateValue(String value);

  /// Clear task due date action.
  ///
  /// In en, this message translates to:
  /// **'Clear due date'**
  String get createTaskClearDueDate;

  /// Create task failure message.
  ///
  /// In en, this message translates to:
  /// **'Task was not created. Please try again.'**
  String get createTaskError;

  /// Generic save action.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// Generic cancel action.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Generic confirm action.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// Generic retry action.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// Localized sample group name for initial UI state.
  ///
  /// In en, this message translates to:
  /// **'Morning rivals'**
  String get sampleGroupNamePrimary;

  /// Localized sample group name for initial UI state.
  ///
  /// In en, this message translates to:
  /// **'Office dares'**
  String get sampleGroupNameSecondary;

  /// Localized sample profile name for initial UI state.
  ///
  /// In en, this message translates to:
  /// **'Alex'**
  String get sampleProfileName;

  /// Localized sample wager condition for initial UI state.
  ///
  /// In en, this message translates to:
  /// **'Who finishes the workout first?'**
  String get sampleWagerCondition;

  /// Yes wager option.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get wagerOptionYes;

  /// No wager option.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get wagerOptionNo;

  /// Odds multiplier label.
  ///
  /// In en, this message translates to:
  /// **'x{odds}'**
  String wagerOdds(String odds);

  /// Ratio of people staking on each side.
  ///
  /// In en, this message translates to:
  /// **'{left} / {right}'**
  String wagerStakeRatio(int left, int right);

  /// Stake confirmation title.
  ///
  /// In en, this message translates to:
  /// **'Confirm pick'**
  String get wagerConfirmTitle;

  /// Stake amount input label.
  ///
  /// In en, this message translates to:
  /// **'Coins to risk'**
  String get wagerStakeAmountLabel;

  /// Validation error for missing stake amount.
  ///
  /// In en, this message translates to:
  /// **'Enter how many chips to stake.'**
  String get wagerStakeAmountRequired;

  /// Validation error for invalid stake amount.
  ///
  /// In en, this message translates to:
  /// **'Enter a positive whole number.'**
  String get wagerStakeAmountInvalid;

  /// Validation error when stake amount exceeds app limit.
  ///
  /// In en, this message translates to:
  /// **'Maximum stake is {max} chips.'**
  String wagerStakeAmountTooHigh(int max);

  /// Validation error when stake amount exceeds balance.
  ///
  /// In en, this message translates to:
  /// **'You do not have enough chips in this group.'**
  String get wagerStakeInsufficientBalance;

  /// Potential payout shown before placing a stake.
  ///
  /// In en, this message translates to:
  /// **'Reward: {amount} coins'**
  String wagerPotentialPayout(int amount);

  /// Reward amount for correct wager picks.
  ///
  /// In en, this message translates to:
  /// **'{amount} coins'**
  String wagerRewardCoins(int amount);

  /// Explains the 1.5x bonus for choosing the less popular correct outcome.
  ///
  /// In en, this message translates to:
  /// **'Includes unpopular pick bonus.'**
  String get wagerUnderdogBonus;

  /// Badge shown on the wager option selected by the current user.
  ///
  /// In en, this message translates to:
  /// **'Your pick'**
  String get wagerYourChoice;

  /// Wager creation time.
  ///
  /// In en, this message translates to:
  /// **'Created {value}'**
  String wagerCreatedAt(String value);

  /// Wager completion time.
  ///
  /// In en, this message translates to:
  /// **'Completed {value}'**
  String wagerCompletedAt(String value);

  /// Message for excluded or already staked user.
  ///
  /// In en, this message translates to:
  /// **'You cannot stake on this wager.'**
  String get wagerStakeUnavailable;

  /// Generic stake placement error.
  ///
  /// In en, this message translates to:
  /// **'Stake was not placed. Please try again.'**
  String get wagerStakeError;

  /// Admin resolve wager dialog title.
  ///
  /// In en, this message translates to:
  /// **'Confirm result'**
  String get wagerResolveTitle;

  /// Admin resolve wager confirmation body.
  ///
  /// In en, this message translates to:
  /// **'This will close the wager and pay winning stakes.'**
  String get wagerResolveBody;

  /// Admin action to resolve wager with selected side.
  ///
  /// In en, this message translates to:
  /// **'Resolve as {label}'**
  String wagerResolveAs(String label);

  /// Generic wager resolution error.
  ///
  /// In en, this message translates to:
  /// **'Result was not confirmed. Please try again.'**
  String get wagerResolveError;

  /// Cancel wager confirmation title.
  ///
  /// In en, this message translates to:
  /// **'Cancel wager?'**
  String get wagerCancelTitle;

  /// Cancel wager confirmation body.
  ///
  /// In en, this message translates to:
  /// **'All placed chips will be returned and the wager will move to the archive.'**
  String get wagerCancelBody;

  /// Cancel wager admin action.
  ///
  /// In en, this message translates to:
  /// **'Cancel wager'**
  String get wagerCancelAction;

  /// Cancel wager error.
  ///
  /// In en, this message translates to:
  /// **'Wager was not cancelled. Please try again.'**
  String get wagerCancelError;

  /// Stake confirmation explanation.
  ///
  /// In en, this message translates to:
  /// **'Your chips are locked until the admin confirms the result.'**
  String get wagerConfirmBody;

  /// Resolved wager archive screen title.
  ///
  /// In en, this message translates to:
  /// **'Wager archive'**
  String get wagerArchiveTitle;

  /// Wager details screen title.
  ///
  /// In en, this message translates to:
  /// **'Wager details'**
  String get wagerDetailsTitle;

  /// Open wager details action.
  ///
  /// In en, this message translates to:
  /// **'Open details'**
  String get wagerDetailsOpen;

  /// Active wager status.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get wagerDetailsStatusActive;

  /// Resolved wager status.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get wagerDetailsStatusResolved;

  /// Cancelled wager status.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get wagerDetailsStatusCancelled;

  /// Current user's stake section label.
  ///
  /// In en, this message translates to:
  /// **'Your stake'**
  String get wagerDetailsMyStake;

  /// Empty state for wager stakes.
  ///
  /// In en, this message translates to:
  /// **'No one has staked yet.'**
  String get wagerDetailsNoStakes;

  /// Task details screen title.
  ///
  /// In en, this message translates to:
  /// **'Task details'**
  String get taskDetailsTitle;

  /// Active task status.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get taskStatusActive;

  /// Completed task status.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get taskStatusCompleted;

  /// Task reward points label.
  ///
  /// In en, this message translates to:
  /// **'{amount, plural, one {{amount} point} other {{amount} points}}'**
  String taskRewardPoints(int amount);

  /// Task due date label.
  ///
  /// In en, this message translates to:
  /// **'Due {value}'**
  String taskDueDate(String value);

  /// Task without due date label.
  ///
  /// In en, this message translates to:
  /// **'No due date'**
  String get taskNoDueDate;

  /// Task assignee label.
  ///
  /// In en, this message translates to:
  /// **'Assignee'**
  String get taskAssignee;

  /// Task unassigned label.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get taskUnassigned;

  /// Task assigned label.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get taskAssigned;

  /// Self assign task action.
  ///
  /// In en, this message translates to:
  /// **'Assign to me'**
  String get taskAssignSelf;

  /// Task assignment error.
  ///
  /// In en, this message translates to:
  /// **'Task was not assigned. Please try again.'**
  String get taskAssignError;

  /// Admin complete task action.
  ///
  /// In en, this message translates to:
  /// **'Mark complete'**
  String get taskCompleteAction;

  /// Task completion success message.
  ///
  /// In en, this message translates to:
  /// **'Task completed.'**
  String get taskCompleteSuccess;

  /// Task completion error.
  ///
  /// In en, this message translates to:
  /// **'Task was not completed. Please try again.'**
  String get taskCompleteError;

  /// Resolved wager archive empty state.
  ///
  /// In en, this message translates to:
  /// **'No resolved wagers yet.'**
  String get wagerArchiveEmpty;

  /// Search field hint on the wager archive screen.
  ///
  /// In en, this message translates to:
  /// **'Search wagers'**
  String get wagerArchiveSearchHint;

  /// Archive filter for all statuses.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get wagerArchiveFilterAll;

  /// Archive filter for resolved wagers.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get wagerArchiveFilterResolved;

  /// Archive filter for cancelled wagers.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get wagerArchiveFilterCancelled;

  /// Archive sort field label.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get wagerArchiveSortLabel;

  /// Archive sort option that keeps newest wagers first.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get wagerArchiveSortNewest;

  /// Archive sort option by total pool.
  ///
  /// In en, this message translates to:
  /// **'Largest pool'**
  String get wagerArchiveSortLargestPool;

  /// Archive sort option by stake count.
  ///
  /// In en, this message translates to:
  /// **'Most stakes'**
  String get wagerArchiveSortMostStakes;

  /// Archive empty state when filters hide all wagers.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches this search.'**
  String get wagerArchiveFilteredEmpty;

  /// Filtered archive result count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {{count} wager} other {{count} wagers}}'**
  String wagerArchiveResultCount(int count);

  /// Resolved wager winning side.
  ///
  /// In en, this message translates to:
  /// **'Winner: {label}'**
  String wagerArchiveWinner(String label);

  /// Resolved wager total pool.
  ///
  /// In en, this message translates to:
  /// **'Pool: {amount}'**
  String wagerArchiveTotalPool(int amount);

  /// Resolved wager winning side pool.
  ///
  /// In en, this message translates to:
  /// **'Winning side: {amount}'**
  String wagerArchiveWinningPool(int amount);

  /// Resolved wager participant stake list title.
  ///
  /// In en, this message translates to:
  /// **'Participant stakes'**
  String get wagerArchiveStakes;

  /// Participant stake side and amount.
  ///
  /// In en, this message translates to:
  /// **'{label}'**
  String wagerArchiveStakeSide(String label, int amount);

  /// Participant resolved wager payout.
  ///
  /// In en, this message translates to:
  /// **'+{amount}'**
  String wagerArchivePayout(int amount);

  /// Title for group preview after invite lookup.
  ///
  /// In en, this message translates to:
  /// **'Group preview'**
  String get groupPreviewTitle;

  /// Group settings saved message.
  ///
  /// In en, this message translates to:
  /// **'Group updated.'**
  String get groupSaveSuccess;

  /// Group settings save error.
  ///
  /// In en, this message translates to:
  /// **'Group was not updated. Please try again.'**
  String get groupSaveError;

  /// Leave group action.
  ///
  /// In en, this message translates to:
  /// **'Leave group'**
  String get groupLeaveAction;

  /// Leave group confirmation title.
  ///
  /// In en, this message translates to:
  /// **'Leave group?'**
  String get groupLeaveTitle;

  /// Leave group confirmation body.
  ///
  /// In en, this message translates to:
  /// **'You will leave this group. Your resolved wager history stays in the group archive.'**
  String get groupLeaveBody;

  /// Leave group confirmation action.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get groupLeaveConfirm;

  /// Leave group error.
  ///
  /// In en, this message translates to:
  /// **'You cannot leave this group right now.'**
  String get groupLeaveError;

  /// Snackbar for a wager win.
  ///
  /// In en, this message translates to:
  /// **'You won this wager.'**
  String get wagerResultWon;

  /// Snackbar for a wager loss.
  ///
  /// In en, this message translates to:
  /// **'You lost this wager.'**
  String get wagerResultLost;

  /// Top snackbar for a wager win with group name.
  ///
  /// In en, this message translates to:
  /// **'You won in {groupName}.'**
  String wagerResultWonInGroup(String groupName);

  /// Top snackbar for a wager loss with group name.
  ///
  /// In en, this message translates to:
  /// **'You lost in {groupName}.'**
  String wagerResultLostInGroup(String groupName);

  /// Generic sign-in failure message.
  ///
  /// In en, this message translates to:
  /// **'Sign-in did not finish. Please try again.'**
  String get authGenericError;

  /// Achievements section and screen title.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievementsTitle;

  /// Achievements progress summary.
  ///
  /// In en, this message translates to:
  /// **'{earned} of {total} unlocked'**
  String achievementsSubtitle(int earned, int total);

  /// Open all achievements action.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get achievementsViewAll;

  /// Unlocked achievements section title.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get achievementsUnlockedSection;

  /// Nearest locked achievements section title.
  ///
  /// In en, this message translates to:
  /// **'Closest next'**
  String get achievementsNearestSection;

  /// Unlocked achievement status.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get achievementStatusUnlocked;

  /// Top notification shown when a new achievement is unlocked.
  ///
  /// In en, this message translates to:
  /// **'Achievement unlocked: {title}'**
  String achievementUnlockedToast(String title);

  /// Achievement progress value.
  ///
  /// In en, this message translates to:
  /// **'{current} of {target}'**
  String achievementProgress(int current, int target);

  /// Total wager achievement requirement.
  ///
  /// In en, this message translates to:
  /// **'Place {target} wagers'**
  String achievementRequirementTotalWagers(int target);

  /// Correct wager achievement requirement.
  ///
  /// In en, this message translates to:
  /// **'Win {target} wagers'**
  String achievementRequirementCorrectWagers(int target);

  /// Earned chips achievement requirement.
  ///
  /// In en, this message translates to:
  /// **'Earn {target} chips'**
  String achievementRequirementEarnedChips(int target);

  /// Level achievement requirement.
  ///
  /// In en, this message translates to:
  /// **'Reach level {target}'**
  String achievementRequirementLevel(int target);

  /// Achievement title.
  ///
  /// In en, this message translates to:
  /// **'First Move'**
  String get achievementFirstWagerTitle;

  /// Achievement description.
  ///
  /// In en, this message translates to:
  /// **'Place your first wager in any group.'**
  String get achievementFirstWagerDescription;

  /// Achievement title.
  ///
  /// In en, this message translates to:
  /// **'Table Regular'**
  String get achievementFiveWagersTitle;

  /// Achievement description.
  ///
  /// In en, this message translates to:
  /// **'Place 5 wagers.'**
  String get achievementFiveWagersDescription;

  /// Achievement title.
  ///
  /// In en, this message translates to:
  /// **'Risk Reader'**
  String get achievementTwentyFiveWagersTitle;

  /// Achievement description.
  ///
  /// In en, this message translates to:
  /// **'Place 25 wagers.'**
  String get achievementTwentyFiveWagersDescription;

  /// Achievement title.
  ///
  /// In en, this message translates to:
  /// **'Always In'**
  String get achievementHundredWagersTitle;

  /// Achievement description.
  ///
  /// In en, this message translates to:
  /// **'Place 100 wagers.'**
  String get achievementHundredWagersDescription;

  /// Achievement title.
  ///
  /// In en, this message translates to:
  /// **'Called It'**
  String get achievementFirstWinTitle;

  /// Achievement description.
  ///
  /// In en, this message translates to:
  /// **'Win your first wager.'**
  String get achievementFirstWinDescription;

  /// Achievement title.
  ///
  /// In en, this message translates to:
  /// **'Clean Read'**
  String get achievementFiveWinsTitle;

  /// Achievement description.
  ///
  /// In en, this message translates to:
  /// **'Win 5 wagers.'**
  String get achievementFiveWinsDescription;

  /// Achievement title.
  ///
  /// In en, this message translates to:
  /// **'Sharp Eye'**
  String get achievementTwentyFiveWinsTitle;

  /// Achievement description.
  ///
  /// In en, this message translates to:
  /// **'Win 25 wagers.'**
  String get achievementTwentyFiveWinsDescription;

  /// Achievement title.
  ///
  /// In en, this message translates to:
  /// **'Legend Pick'**
  String get achievementHundredWinsTitle;

  /// Achievement description.
  ///
  /// In en, this message translates to:
  /// **'Win 100 wagers.'**
  String get achievementHundredWinsDescription;

  /// Achievement title.
  ///
  /// In en, this message translates to:
  /// **'First Stack'**
  String get achievementHundredChipsTitle;

  /// Achievement description.
  ///
  /// In en, this message translates to:
  /// **'Earn 100 chips across your groups.'**
  String get achievementHundredChipsDescription;

  /// Achievement title.
  ///
  /// In en, this message translates to:
  /// **'Chip Collector'**
  String get achievementThousandChipsTitle;

  /// Achievement description.
  ///
  /// In en, this message translates to:
  /// **'Earn 1,000 chips across your groups.'**
  String get achievementThousandChipsDescription;

  /// Achievement title.
  ///
  /// In en, this message translates to:
  /// **'Vault Builder'**
  String get achievementTenThousandChipsTitle;

  /// Achievement description.
  ///
  /// In en, this message translates to:
  /// **'Earn 10,000 chips across your groups.'**
  String get achievementTenThousandChipsDescription;

  /// Achievement title.
  ///
  /// In en, this message translates to:
  /// **'Level Spark'**
  String get achievementLevelTwoTitle;

  /// Achievement description.
  ///
  /// In en, this message translates to:
  /// **'Reach level 2.'**
  String get achievementLevelTwoDescription;

  /// Achievement title.
  ///
  /// In en, this message translates to:
  /// **'Momentum'**
  String get achievementLevelFiveTitle;

  /// Achievement description.
  ///
  /// In en, this message translates to:
  /// **'Reach level 5.'**
  String get achievementLevelFiveDescription;

  /// Achievement title.
  ///
  /// In en, this message translates to:
  /// **'Double Digits'**
  String get achievementLevelTenTitle;

  /// Achievement description.
  ///
  /// In en, this message translates to:
  /// **'Reach level 10.'**
  String get achievementLevelTenDescription;

  /// Achievement title.
  ///
  /// In en, this message translates to:
  /// **'Veteran Circle'**
  String get achievementLevelTwentyFiveTitle;

  /// Achievement description.
  ///
  /// In en, this message translates to:
  /// **'Reach level 25.'**
  String get achievementLevelTwentyFiveDescription;

  /// Android notification channel name.
  ///
  /// In en, this message translates to:
  /// **'Point Rivals alerts'**
  String get notificationChannelName;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
