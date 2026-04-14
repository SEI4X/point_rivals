// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Point Rivals';

  @override
  String get homeTitle => 'Point Rivals';

  @override
  String get homeHeadline => 'Ready for the next match';

  @override
  String get homeBody => 'Build every feature in small, tested layers.';

  @override
  String get navGroups => 'Groups';

  @override
  String get navProfile => 'Profile';

  @override
  String get onboardingTitle => 'Tasks and wagers for points';

  @override
  String get onboardingBody =>
      'Create group tasks, assign owners, finish them for points, and keep friendly wagers for match-day calls.';

  @override
  String get onboardingGameNotice =>
      'Points stay inside each group. Admins judge completed tasks and wager results.';

  @override
  String get onboardingAppleButton => 'Continue with Apple';

  @override
  String get onboardingGoogleButton => 'Continue with Google';

  @override
  String get onboardingNameLabel => 'Name';

  @override
  String get onboardingPhotoAction => 'Add photo';

  @override
  String get onboardingNotificationsAction => 'Allow notifications';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Start';

  @override
  String get onboardingAuthTitle => 'Save your wins';

  @override
  String get onboardingAuthBody =>
      'Sign in so your groups, tasks, points, and XP stay synced.';

  @override
  String get onboardingNotificationsTitle => 'Stay in the loop';

  @override
  String get onboardingNotificationsBody =>
      'Get a heads-up when a task is assigned to you or a wager is resolved.';

  @override
  String get onboardingTaskSignal =>
      'Create a task, pick points, and assign an owner.';

  @override
  String get onboardingJudgeSignal =>
      'Admins confirm done work and settle wagers.';

  @override
  String get onboardingAuthSignal =>
      'Your points, groups, and wins follow your account.';

  @override
  String get onboardingNotifySignal =>
      'Assigned tasks arrive as notifications.';

  @override
  String get groupsTitle => 'Groups';

  @override
  String get groupsSearchTooltip => 'Find or create group';

  @override
  String get groupsCreateTooltip => 'Create group';

  @override
  String groupsMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '$count member',
    );
    return '$_temp0';
  }

  @override
  String groupsActiveWagersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active wagers',
      one: '$count active wager',
    );
    return '$_temp0';
  }

  @override
  String groupsMyBalance(int amount) {
    return 'My chips: $amount';
  }

  @override
  String groupsMemberBalance(int amount) {
    return 'Chips: $amount';
  }

  @override
  String get groupsEmptyTitle => 'No groups yet';

  @override
  String get groupsEmptyBody =>
      'Create a group or join one with an invite code.';

  @override
  String get groupsLoadError => 'Groups could not be loaded. Please try again.';

  @override
  String get joinGroupTitle => 'Join a group';

  @override
  String get joinGroupCodeLabel => 'Invite code';

  @override
  String get joinGroupScanQr => 'Scan QR';

  @override
  String get joinGroupPreviewButton => 'Find';

  @override
  String get joinGroupJoinButton => 'Join';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileLoadError =>
      'Profile could not be loaded. Please try again.';

  @override
  String get profileNotFound => 'Profile was not found.';

  @override
  String get profileUnnamed => 'Player';

  @override
  String profileLevel(int level) {
    return 'Level $level';
  }

  @override
  String profileXpProgress(int current, int target) {
    return '$current / $target XP';
  }

  @override
  String get profileChips => 'Chips';

  @override
  String get profileXp => 'XP';

  @override
  String get profileTotalWagers => 'Total wagers';

  @override
  String get profileCorrectWagers => 'Correct wagers';

  @override
  String get profileTotalEarned => 'Chips earned';

  @override
  String get profileMyWagers => 'My wagers';

  @override
  String get profileActivity => 'Activity';

  @override
  String get activityTitle => 'Activity';

  @override
  String get activityEmpty => 'No activity yet.';

  @override
  String get activityNewWagerTitle => 'New wager';

  @override
  String activityResolvedWonTitle(int amount) {
    return 'You won $amount chips';
  }

  @override
  String get activityResolvedTitle => 'Wager resolved';

  @override
  String get activityTaskCompletedTitle => 'Task completed';

  @override
  String get activityCancelledTitle => 'Wager cancelled';

  @override
  String get activityOpenGroup => 'Open group';

  @override
  String activityCreatedAt(String value) {
    return 'Created $value';
  }

  @override
  String activityCompletedAt(String value) {
    return 'Completed $value';
  }

  @override
  String get myWagersTitle => 'My wagers';

  @override
  String get myWagersEmpty => 'No wagers yet.';

  @override
  String get myWagersActive => 'Active';

  @override
  String get myWagersHistory => 'History';

  @override
  String myWagersStake(int amount) {
    return 'Staked $amount';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsProfileSaved => 'Profile updated.';

  @override
  String get settingsProfileSaveError =>
      'Profile was not updated. Please try again.';

  @override
  String get settingsProfileNameRequired => 'Enter your name.';

  @override
  String get settingsAvatarAction => 'Change photo';

  @override
  String get settingsAvatarError => 'Photo was not updated. Please try again.';

  @override
  String get settingsPhotoPermissionDenied =>
      'Allow photo access to choose a profile picture.';

  @override
  String get settingsNotificationsError =>
      'Notifications were not updated. Please try again.';

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String get settingsDeleteAccount => 'Delete account';

  @override
  String get settingsDeleteWarning =>
      'Account deletion is available after a 10-second confirmation delay.';

  @override
  String get settingsDeleteTitle => 'Delete account?';

  @override
  String get settingsDeleteBody =>
      'Your account will be hidden and you will be signed out. This action is delayed for safety.';

  @override
  String settingsDeleteCountdown(int seconds) {
    return 'You can confirm in $seconds s';
  }

  @override
  String get settingsDeleteError =>
      'Account was not deleted. Please try again.';

  @override
  String groupMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participants',
      one: '$count participant',
    );
    return '$_temp0';
  }

  @override
  String get groupMonthLeaders => 'Leaders (current month)';

  @override
  String get groupMonthTab => 'Month';

  @override
  String get groupAllTimeLeaders => 'All-time leaders';

  @override
  String get groupAllTimeTab => 'All time';

  @override
  String get groupWagerArchive => 'Wager archive';

  @override
  String get groupActiveWagers => 'Active wagers';

  @override
  String get groupWagersTab => 'Wagers';

  @override
  String get groupTasksTab => 'Tasks';

  @override
  String get groupNoActiveWagers => 'No active wagers yet.';

  @override
  String get groupNoActiveTasks => 'No active tasks yet.';

  @override
  String get groupAdminBadge => 'Admin';

  @override
  String get groupCreateWager => 'Create wager';

  @override
  String get groupCreateTask => 'Create task';

  @override
  String get groupSettingsTitle => 'Group settings';

  @override
  String get groupNameLabel => 'Group name';

  @override
  String get groupNameRequired => 'Enter a group name.';

  @override
  String get groupAccentColorTitle => 'Group color';

  @override
  String get groupAccentColorSubtitle =>
      'Used for group cards, actions, and highlights.';

  @override
  String get groupInviteCode => 'Invite code';

  @override
  String get groupInviteQr => 'Invite QR';

  @override
  String get groupInviteShareAction => 'Share invite';

  @override
  String get groupInviteCopyAction => 'Copy code';

  @override
  String get groupInviteCopied => 'Invite code copied.';

  @override
  String groupInviteShareText(String groupName, String inviteCode) {
    return 'Join $groupName in Point Rivals. Invite code: $inviteCode';
  }

  @override
  String get groupCreateError => 'Group was not created. Please try again.';

  @override
  String get joinGroupCodeRequired => 'Enter an invite code.';

  @override
  String get joinGroupError =>
      'Group was not found. Check the code and try again.';

  @override
  String joinGroupMembersPreview(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '$count member',
    );
    return '$_temp0';
  }

  @override
  String get joinGroupScanTitle => 'Scan invite QR';

  @override
  String get joinGroupScanBody => 'Point the camera at a group invite QR.';

  @override
  String get joinGroupInvalidQr => 'This QR does not contain an invite code.';

  @override
  String get joinGroupCameraError =>
      'Camera is unavailable. Enter the code instead.';

  @override
  String get groupAdmins => 'Admins';

  @override
  String get groupParticipants => 'Participants';

  @override
  String get groupPromoteMember => 'Make admin';

  @override
  String get groupDemoteMember => 'Remove admin';

  @override
  String get groupRemoveMember => 'Remove from group';

  @override
  String get groupMemberActionError =>
      'Member was not updated. Please try again.';

  @override
  String get groupRemoveMemberTitle => 'Remove member?';

  @override
  String get groupRemoveMemberBody =>
      'This member will lose access to the group.';

  @override
  String get groupSelfAdminHint => 'You cannot change your own admin role.';

  @override
  String get createWagerTitle => 'Create wager';

  @override
  String get createWagerConditionLabel => 'Wager condition';

  @override
  String get createWagerConditionRequired => 'Enter a wager condition.';

  @override
  String createWagerConditionTooLong(int max) {
    return 'Keep the condition under $max characters.';
  }

  @override
  String get createWagerExcludedParticipants => 'Participants in the wager';

  @override
  String get createWagerParticipantsHint =>
      'People involved in the outcome cannot place bets.';

  @override
  String createWagerSelectedParticipants(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participants selected',
      one: '1 participant selected',
      zero: 'No participants selected',
    );
    return '$_temp0';
  }

  @override
  String get createWagerNoMembers => 'No members available yet.';

  @override
  String get createWagerParticipantsRequired =>
      'Choose two participants for this wager type.';

  @override
  String get createWagerType => 'Wager type';

  @override
  String get createWagerTypeYesNo => 'Yes / No';

  @override
  String get createWagerTypeParticipants => 'Participant 1 / Participant 2';

  @override
  String get createWagerTypeCustom => 'Custom';

  @override
  String get createWagerTypeHintYesNo =>
      'Use this for outcomes with a clear yes or no.';

  @override
  String get createWagerTypeHintParticipants =>
      'Choose exactly two people. They will become the two sides and cannot bet.';

  @override
  String get createWagerTypeHintCustom =>
      'Write your own labels for both sides.';

  @override
  String get createWagerLeftLabel => 'Left button label';

  @override
  String get createWagerRightLabel => 'Right button label';

  @override
  String get createWagerOptionLabelRequired => 'Enter both button labels.';

  @override
  String createWagerOptionLabelTooLong(int max) {
    return 'Keep labels under $max characters.';
  }

  @override
  String get createWagerPreview => 'Outcome buttons';

  @override
  String get createWagerPreviewHint =>
      'Correct picks earn the reward. Unpopular correct picks earn 1.5x.';

  @override
  String get createWagerRewardCoinsLabel => 'Reward coins';

  @override
  String get createWagerRewardCoinsHelper =>
      'Correct players earn this amount. Unpopular correct picks earn 1.5x.';

  @override
  String createWagerRewardCoinsTooHigh(int max) {
    return 'Maximum reward is $max coins.';
  }

  @override
  String get createWagerRewardPreview => 'Default reward is 10 coins.';

  @override
  String createWagerStakeRangeHint(int min, int max) {
    return 'Stake range: $min-$max chips.';
  }

  @override
  String get createWagerError => 'Wager was not created. Please try again.';

  @override
  String get createTaskTitle => 'Create task';

  @override
  String get createTaskTitleLabel => 'Task name';

  @override
  String get createTaskTitleRequired => 'Enter a task name.';

  @override
  String createTaskTitleTooLong(int max) {
    return 'Keep the name under $max characters.';
  }

  @override
  String get createTaskDescriptionLabel => 'Description';

  @override
  String createTaskDescriptionTooLong(int max) {
    return 'Keep the description under $max characters.';
  }

  @override
  String get createTaskAssigneeLabel => 'Assignee';

  @override
  String get createTaskUnassigned => 'No assignee';

  @override
  String get createTaskRewardPointsLabel => 'Reward points';

  @override
  String get createTaskRewardPointsHelper =>
      'The assignee receives these points after admin approval.';

  @override
  String createTaskRewardPointsTooHigh(int max) {
    return 'Maximum reward is $max points.';
  }

  @override
  String get createTaskDueDateAction => 'Add due date';

  @override
  String createTaskDueDateValue(String value) {
    return 'Due $value';
  }

  @override
  String get createTaskClearDueDate => 'Clear due date';

  @override
  String get createTaskError => 'Task was not created. Please try again.';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonRetry => 'Retry';

  @override
  String get sampleGroupNamePrimary => 'Morning rivals';

  @override
  String get sampleGroupNameSecondary => 'Office dares';

  @override
  String get sampleProfileName => 'Alex';

  @override
  String get sampleWagerCondition => 'Who finishes the workout first?';

  @override
  String get wagerOptionYes => 'Yes';

  @override
  String get wagerOptionNo => 'No';

  @override
  String wagerOdds(String odds) {
    return 'x$odds';
  }

  @override
  String wagerStakeRatio(int left, int right) {
    return '$left / $right';
  }

  @override
  String get wagerConfirmTitle => 'Confirm pick';

  @override
  String get wagerStakeAmountLabel => 'Coins to risk';

  @override
  String get wagerStakeAmountRequired => 'Enter how many chips to stake.';

  @override
  String get wagerStakeAmountInvalid => 'Enter a positive whole number.';

  @override
  String wagerStakeAmountTooHigh(int max) {
    return 'Maximum stake is $max chips.';
  }

  @override
  String get wagerStakeInsufficientBalance =>
      'You do not have enough chips in this group.';

  @override
  String wagerPotentialPayout(int amount) {
    return 'Reward: $amount coins';
  }

  @override
  String wagerRewardCoins(int amount) {
    return '$amount coins';
  }

  @override
  String get wagerUnderdogBonus => 'Includes unpopular pick bonus.';

  @override
  String get wagerYourChoice => 'Your pick';

  @override
  String wagerCreatedAt(String value) {
    return 'Created $value';
  }

  @override
  String wagerCompletedAt(String value) {
    return 'Completed $value';
  }

  @override
  String get wagerStakeUnavailable => 'You cannot stake on this wager.';

  @override
  String get wagerStakeError => 'Stake was not placed. Please try again.';

  @override
  String get wagerResolveTitle => 'Confirm result';

  @override
  String get wagerResolveBody =>
      'This will close the wager and pay winning stakes.';

  @override
  String wagerResolveAs(String label) {
    return 'Resolve as $label';
  }

  @override
  String get wagerResolveError => 'Result was not confirmed. Please try again.';

  @override
  String get wagerCancelTitle => 'Cancel wager?';

  @override
  String get wagerCancelBody =>
      'All placed chips will be returned and the wager will move to the archive.';

  @override
  String get wagerCancelAction => 'Cancel wager';

  @override
  String get wagerCancelError => 'Wager was not cancelled. Please try again.';

  @override
  String get wagerConfirmBody =>
      'Your chips are locked until the admin confirms the result.';

  @override
  String get wagerArchiveTitle => 'Wager archive';

  @override
  String get wagerDetailsTitle => 'Wager details';

  @override
  String get wagerDetailsOpen => 'Open details';

  @override
  String get wagerDetailsStatusActive => 'Active';

  @override
  String get wagerDetailsStatusResolved => 'Resolved';

  @override
  String get wagerDetailsStatusCancelled => 'Cancelled';

  @override
  String get wagerDetailsMyStake => 'Your stake';

  @override
  String get wagerDetailsNoStakes => 'No one has staked yet.';

  @override
  String get taskDetailsTitle => 'Task details';

  @override
  String get taskStatusActive => 'Active';

  @override
  String get taskStatusCompleted => 'Completed';

  @override
  String taskRewardPoints(int amount) {
    String _temp0 = intl.Intl.pluralLogic(
      amount,
      locale: localeName,
      other: '$amount points',
      one: '$amount point',
    );
    return '$_temp0';
  }

  @override
  String taskDueDate(String value) {
    return 'Due $value';
  }

  @override
  String get taskNoDueDate => 'No due date';

  @override
  String get taskAssignee => 'Assignee';

  @override
  String get taskUnassigned => 'Unassigned';

  @override
  String get taskAssigned => 'Assigned';

  @override
  String get taskAssignSelf => 'Assign to me';

  @override
  String get taskAssignError => 'Task was not assigned. Please try again.';

  @override
  String get taskCompleteAction => 'Mark complete';

  @override
  String get taskCompleteSuccess => 'Task completed.';

  @override
  String get taskCompleteError => 'Task was not completed. Please try again.';

  @override
  String get wagerArchiveEmpty => 'No resolved wagers yet.';

  @override
  String get wagerArchiveSearchHint => 'Search wagers';

  @override
  String get wagerArchiveFilterAll => 'All';

  @override
  String get wagerArchiveFilterResolved => 'Resolved';

  @override
  String get wagerArchiveFilterCancelled => 'Cancelled';

  @override
  String get wagerArchiveSortLabel => 'Sort';

  @override
  String get wagerArchiveSortNewest => 'Newest';

  @override
  String get wagerArchiveSortLargestPool => 'Largest pool';

  @override
  String get wagerArchiveSortMostStakes => 'Most stakes';

  @override
  String get wagerArchiveFilteredEmpty => 'Nothing matches this search.';

  @override
  String wagerArchiveResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wagers',
      one: '$count wager',
    );
    return '$_temp0';
  }

  @override
  String wagerArchiveWinner(String label) {
    return 'Winner: $label';
  }

  @override
  String wagerArchiveTotalPool(int amount) {
    return 'Pool: $amount';
  }

  @override
  String wagerArchiveWinningPool(int amount) {
    return 'Winning side: $amount';
  }

  @override
  String get wagerArchiveStakes => 'Participant stakes';

  @override
  String wagerArchiveStakeSide(String label, int amount) {
    return '$label';
  }

  @override
  String wagerArchivePayout(int amount) {
    return '+$amount';
  }

  @override
  String get groupPreviewTitle => 'Group preview';

  @override
  String get groupSaveSuccess => 'Group updated.';

  @override
  String get groupSaveError => 'Group was not updated. Please try again.';

  @override
  String get groupLeaveAction => 'Leave group';

  @override
  String get groupLeaveTitle => 'Leave group?';

  @override
  String get groupLeaveBody =>
      'You will leave this group. Your resolved wager history stays in the group archive.';

  @override
  String get groupLeaveConfirm => 'Leave';

  @override
  String get groupLeaveError => 'You cannot leave this group right now.';

  @override
  String get wagerResultWon => 'You won this wager.';

  @override
  String get wagerResultLost => 'You lost this wager.';

  @override
  String wagerResultWonInGroup(String groupName) {
    return 'You won in $groupName.';
  }

  @override
  String wagerResultLostInGroup(String groupName) {
    return 'You lost in $groupName.';
  }

  @override
  String get authGenericError => 'Sign-in did not finish. Please try again.';

  @override
  String get achievementsTitle => 'Achievements';

  @override
  String achievementsSubtitle(int earned, int total) {
    return '$earned of $total unlocked';
  }

  @override
  String get achievementsViewAll => 'View all';

  @override
  String get achievementsUnlockedSection => 'Unlocked';

  @override
  String get achievementsNearestSection => 'Closest next';

  @override
  String get achievementStatusUnlocked => 'Unlocked';

  @override
  String achievementUnlockedToast(String title) {
    return 'Achievement unlocked: $title';
  }

  @override
  String achievementProgress(int current, int target) {
    return '$current of $target';
  }

  @override
  String achievementRequirementTotalWagers(int target) {
    return 'Place $target wagers';
  }

  @override
  String achievementRequirementCorrectWagers(int target) {
    return 'Win $target wagers';
  }

  @override
  String achievementRequirementEarnedChips(int target) {
    return 'Earn $target chips';
  }

  @override
  String achievementRequirementLevel(int target) {
    return 'Reach level $target';
  }

  @override
  String get achievementFirstWagerTitle => 'First Move';

  @override
  String get achievementFirstWagerDescription =>
      'Place your first wager in any group.';

  @override
  String get achievementFiveWagersTitle => 'Table Regular';

  @override
  String get achievementFiveWagersDescription => 'Place 5 wagers.';

  @override
  String get achievementTwentyFiveWagersTitle => 'Risk Reader';

  @override
  String get achievementTwentyFiveWagersDescription => 'Place 25 wagers.';

  @override
  String get achievementHundredWagersTitle => 'Always In';

  @override
  String get achievementHundredWagersDescription => 'Place 100 wagers.';

  @override
  String get achievementFirstWinTitle => 'Called It';

  @override
  String get achievementFirstWinDescription => 'Win your first wager.';

  @override
  String get achievementFiveWinsTitle => 'Clean Read';

  @override
  String get achievementFiveWinsDescription => 'Win 5 wagers.';

  @override
  String get achievementTwentyFiveWinsTitle => 'Sharp Eye';

  @override
  String get achievementTwentyFiveWinsDescription => 'Win 25 wagers.';

  @override
  String get achievementHundredWinsTitle => 'Legend Pick';

  @override
  String get achievementHundredWinsDescription => 'Win 100 wagers.';

  @override
  String get achievementHundredChipsTitle => 'First Stack';

  @override
  String get achievementHundredChipsDescription =>
      'Earn 100 chips across your groups.';

  @override
  String get achievementThousandChipsTitle => 'Chip Collector';

  @override
  String get achievementThousandChipsDescription =>
      'Earn 1,000 chips across your groups.';

  @override
  String get achievementTenThousandChipsTitle => 'Vault Builder';

  @override
  String get achievementTenThousandChipsDescription =>
      'Earn 10,000 chips across your groups.';

  @override
  String get achievementLevelTwoTitle => 'Level Spark';

  @override
  String get achievementLevelTwoDescription => 'Reach level 2.';

  @override
  String get achievementLevelFiveTitle => 'Momentum';

  @override
  String get achievementLevelFiveDescription => 'Reach level 5.';

  @override
  String get achievementLevelTenTitle => 'Double Digits';

  @override
  String get achievementLevelTenDescription => 'Reach level 10.';

  @override
  String get achievementLevelTwentyFiveTitle => 'Veteran Circle';

  @override
  String get achievementLevelTwentyFiveDescription => 'Reach level 25.';

  @override
  String get notificationChannelName => 'Point Rivals alerts';
}
