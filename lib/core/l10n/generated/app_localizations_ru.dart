// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Point Rivals';

  @override
  String get homeTitle => 'Point Rivals';

  @override
  String get homeHeadline => 'Готовы к следующему матчу';

  @override
  String get homeBody =>
      'Каждая функция создается маленькими тестируемыми слоями.';

  @override
  String get navGroups => 'Группы';

  @override
  String get navProfile => 'Профиль';

  @override
  String get onboardingTitle => 'Дружеские ставки без денег';

  @override
  String get onboardingBody =>
      'Создайте группу, ставьте фишки на реальные исходы и доверяйте админам подтверждать результат.';

  @override
  String get onboardingGameNotice =>
      'Фишки остаются внутри группы. Point Rivals - это игра, а не азартные ставки.';

  @override
  String get onboardingAppleButton => 'Продолжить с Apple';

  @override
  String get onboardingGoogleButton => 'Продолжить с Google';

  @override
  String get onboardingNameLabel => 'Имя';

  @override
  String get onboardingPhotoAction => 'Добавить фото';

  @override
  String get onboardingNotificationsAction => 'Разрешить уведомления';

  @override
  String get onboardingNext => 'Дальше';

  @override
  String get onboardingStart => 'Начать';

  @override
  String get onboardingAuthTitle => 'Сохраните победы';

  @override
  String get onboardingAuthBody =>
      'Войдите, чтобы группы, фишки и XP синхронизировались.';

  @override
  String get onboardingNotificationsTitle => 'Будьте в курсе';

  @override
  String get onboardingNotificationsBody =>
      'Получайте уведомления, когда ставка завершена или группа ждет вас.';

  @override
  String get groupsTitle => 'Группы';

  @override
  String get groupsSearchTooltip => 'Найти или создать группу';

  @override
  String get groupsCreateTooltip => 'Создать группу';

  @override
  String groupsMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count участника',
      many: '$count участников',
      few: '$count участника',
      one: '$count участник',
    );
    return '$_temp0';
  }

  @override
  String groupsActiveWagersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count активной ставки',
      many: '$count активных ставок',
      few: '$count активные ставки',
      one: '$count активная ставка',
    );
    return '$_temp0';
  }

  @override
  String groupsMyBalance(int amount) {
    return 'Мои фишки: $amount';
  }

  @override
  String groupsMemberBalance(int amount) {
    return 'Фишки: $amount';
  }

  @override
  String get groupsEmptyTitle => 'Групп пока нет';

  @override
  String get groupsEmptyBody =>
      'Создайте группу или войдите по коду приглашения.';

  @override
  String get groupsLoadError =>
      'Не удалось загрузить группы. Попробуйте еще раз.';

  @override
  String get joinGroupTitle => 'Войти в группу';

  @override
  String get joinGroupCodeLabel => 'Код приглашения';

  @override
  String get joinGroupScanQr => 'Сканировать QR';

  @override
  String get joinGroupPreviewButton => 'Найти';

  @override
  String get joinGroupJoinButton => 'Присоединиться';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileLoadError => 'Профиль не загружен. Попробуйте еще раз.';

  @override
  String get profileNotFound => 'Профиль не найден.';

  @override
  String get profileUnnamed => 'Игрок';

  @override
  String profileLevel(int level) {
    return 'Уровень $level';
  }

  @override
  String profileXpProgress(int current, int target) {
    return '$current / $target XP';
  }

  @override
  String get profileChips => 'Фишки';

  @override
  String get profileXp => 'XP';

  @override
  String get profileTotalWagers => 'Всего ставок';

  @override
  String get profileCorrectWagers => 'Верных ставок';

  @override
  String get profileTotalEarned => 'Заработано фишек';

  @override
  String get profileMyWagers => 'Мои ставки';

  @override
  String get profileActivity => 'Активность';

  @override
  String get activityTitle => 'Активность';

  @override
  String get activityEmpty => 'Активности пока нет.';

  @override
  String get activityNewWagerTitle => 'Новая ставка';

  @override
  String activityResolvedWonTitle(int amount) {
    return 'Вы выиграли $amount фишек';
  }

  @override
  String get activityResolvedTitle => 'Ставка завершена';

  @override
  String get activityCancelledTitle => 'Ставка отменена';

  @override
  String get activityOpenGroup => 'Открыть группу';

  @override
  String activityCreatedAt(String value) {
    return 'Создано $value';
  }

  @override
  String activityCompletedAt(String value) {
    return 'Завершено $value';
  }

  @override
  String get myWagersTitle => 'Мои ставки';

  @override
  String get myWagersEmpty => 'Ставок пока нет.';

  @override
  String get myWagersActive => 'Активные';

  @override
  String get myWagersHistory => 'История';

  @override
  String myWagersStake(int amount) {
    return 'Поставлено $amount';
  }

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get settingsThemeSystem => 'Авто';

  @override
  String get settingsThemeLight => 'Светлая';

  @override
  String get settingsThemeDark => 'Темная';

  @override
  String get settingsNotifications => 'Уведомления';

  @override
  String get settingsProfileSaved => 'Профиль обновлен.';

  @override
  String get settingsProfileSaveError =>
      'Профиль не обновлен. Попробуйте еще раз.';

  @override
  String get settingsProfileNameRequired => 'Введите имя.';

  @override
  String get settingsAvatarAction => 'Сменить фото';

  @override
  String get settingsAvatarError => 'Фото не обновлено. Попробуйте еще раз.';

  @override
  String get settingsPhotoPermissionDenied =>
      'Разрешите доступ к фото, чтобы выбрать аватар.';

  @override
  String get settingsNotificationsError =>
      'Уведомления не обновлены. Попробуйте еще раз.';

  @override
  String get settingsSignOut => 'Выйти';

  @override
  String get settingsDeleteAccount => 'Удалить аккаунт';

  @override
  String get settingsDeleteWarning =>
      'Удаление аккаунта станет доступно после задержки подтверждения в 10 секунд.';

  @override
  String get settingsDeleteTitle => 'Удалить аккаунт?';

  @override
  String get settingsDeleteBody =>
      'Аккаунт будет скрыт, а вы выйдете из приложения. Для безопасности действие доступно с задержкой.';

  @override
  String settingsDeleteCountdown(int seconds) {
    return 'Подтвердить можно через $seconds с';
  }

  @override
  String get settingsDeleteError => 'Аккаунт не удален. Попробуйте еще раз.';

  @override
  String groupMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count участника',
      many: '$count участников',
      few: '$count участника',
      one: '$count участник',
    );
    return '$_temp0';
  }

  @override
  String get groupWeeklyLeaders => 'Лидеры недели';

  @override
  String get groupWeeklyTab => 'Неделя';

  @override
  String groupWindowLeaders(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: 'Лидеры за $weeks недели',
      many: 'Лидеры за $weeks недель',
      few: 'Лидеры за $weeks недели',
      one: 'Лидеры недели',
    );
    return '$_temp0';
  }

  @override
  String get groupAllTimeLeaders => 'Лидеры за все время';

  @override
  String get groupAllTimeTab => 'Все время';

  @override
  String get groupWagerArchive => 'Архив ставок';

  @override
  String get groupActiveWagers => 'Активные ставки';

  @override
  String get groupLeaderboardWindowTitle => 'Период недельных лидеров';

  @override
  String get groupLeaderboardWindowBody =>
      'Выберите длину спринта. Для 2 или 4 недель спринты идут подряд от даты старта.';

  @override
  String groupLeaderboardWindowWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count недели',
      many: '$count недель',
      few: '$count недели',
      one: '$count неделя',
    );
    return '$_temp0';
  }

  @override
  String get groupLeaderboardAnchorDateAction => 'Выбрать старт спринта';

  @override
  String groupLeaderboardAnchorDateValue(String value) {
    return 'Старт спринта: $value';
  }

  @override
  String get groupNoActiveWagers => 'Активных ставок пока нет.';

  @override
  String get groupAdminBadge => 'Админ';

  @override
  String get groupCreateWager => 'Создать ставку';

  @override
  String get groupSettingsTitle => 'Настройки группы';

  @override
  String get groupNameLabel => 'Название группы';

  @override
  String get groupNameRequired => 'Введите название группы.';

  @override
  String get groupAccentColorTitle => 'Цвет группы';

  @override
  String get groupAccentColorSubtitle =>
      'Используется в карточках, действиях и акцентах группы.';

  @override
  String get groupInviteCode => 'Код приглашения';

  @override
  String get groupInviteQr => 'QR приглашения';

  @override
  String get groupInviteShareAction => 'Поделиться';

  @override
  String get groupInviteCopyAction => 'Скопировать код';

  @override
  String get groupInviteCopied => 'Код приглашения скопирован.';

  @override
  String groupInviteShareText(String groupName, String inviteCode) {
    return 'Присоединяйся к группе $groupName в Point Rivals. Код приглашения: $inviteCode';
  }

  @override
  String get groupCreateError => 'Группа не создана. Попробуйте еще раз.';

  @override
  String get joinGroupCodeRequired => 'Введите код приглашения.';

  @override
  String get joinGroupError =>
      'Группа не найдена. Проверьте код и попробуйте снова.';

  @override
  String joinGroupMembersPreview(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count участника',
      many: '$count участников',
      few: '$count участника',
      one: '$count участник',
    );
    return '$_temp0';
  }

  @override
  String get joinGroupScanTitle => 'Сканировать QR';

  @override
  String get joinGroupScanBody => 'Наведи камеру на QR приглашения в группу.';

  @override
  String get joinGroupInvalidQr => 'В этом QR нет кода приглашения.';

  @override
  String get joinGroupCameraError => 'Камера недоступна. Введите код вручную.';

  @override
  String get groupAdmins => 'Админы';

  @override
  String get groupParticipants => 'Участники';

  @override
  String get groupPromoteMember => 'Назначить админом';

  @override
  String get groupDemoteMember => 'Снять админа';

  @override
  String get groupRemoveMember => 'Удалить из группы';

  @override
  String get groupMemberActionError =>
      'Участник не обновлен. Попробуйте еще раз.';

  @override
  String get groupRemoveMemberTitle => 'Удалить участника?';

  @override
  String get groupRemoveMemberBody => 'Участник потеряет доступ к группе.';

  @override
  String get groupSelfAdminHint => 'Нельзя изменить свою роль админа.';

  @override
  String get createWagerTitle => 'Создать ставку';

  @override
  String get createWagerConditionLabel => 'Условие ставки';

  @override
  String get createWagerConditionRequired => 'Введите условие ставки.';

  @override
  String createWagerConditionTooLong(int max) {
    return 'Условие должно быть до $max символов.';
  }

  @override
  String get createWagerExcludedParticipants => 'Участники ставки';

  @override
  String get createWagerParticipantsHint =>
      'Люди, от которых зависит исход, не смогут делать ставки.';

  @override
  String createWagerSelectedParticipants(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Выбрано $count участника',
      many: 'Выбрано $count участников',
      few: 'Выбрано $count участника',
      one: 'Выбран 1 участник',
      zero: 'Участники не выбраны',
    );
    return '$_temp0';
  }

  @override
  String get createWagerNoMembers => 'Участников пока нет.';

  @override
  String get createWagerParticipantsRequired =>
      'Выберите двух участников для этого типа ставки.';

  @override
  String get createWagerType => 'Тип ставки';

  @override
  String get createWagerTypeYesNo => 'Да / Нет';

  @override
  String get createWagerTypeParticipants => 'Участник 1 / Участник 2';

  @override
  String get createWagerTypeCustom => 'Кастом';

  @override
  String get createWagerTypeHintYesNo =>
      'Подходит для исходов с четким да или нет.';

  @override
  String get createWagerTypeHintParticipants =>
      'Выбери ровно двух людей. Они станут сторонами и не смогут ставить.';

  @override
  String get createWagerTypeHintCustom =>
      'Напиши свои надписи для обеих сторон.';

  @override
  String get createWagerLeftLabel => 'Надпись левой кнопки';

  @override
  String get createWagerRightLabel => 'Надпись правой кнопки';

  @override
  String get createWagerOptionLabelRequired => 'Введите надписи обеих кнопок.';

  @override
  String createWagerOptionLabelTooLong(int max) {
    return 'Надписи должны быть до $max символов.';
  }

  @override
  String get createWagerPreview => 'Кнопки исхода';

  @override
  String get createWagerPreviewHint =>
      'Кто угадает, получит награду. Непопулярный верный выбор дает x1.5.';

  @override
  String get createWagerRewardCoinsLabel => 'Награда в коинах';

  @override
  String get createWagerRewardCoinsHelper =>
      'Верные игроки получат эту сумму. Непопулярный верный выбор дает x1.5.';

  @override
  String createWagerRewardCoinsTooHigh(int max) {
    return 'Максимальная награда — $max коинов.';
  }

  @override
  String get createWagerRewardPreview => 'Стандартная награда — 10 коинов.';

  @override
  String createWagerStakeRangeHint(int min, int max) {
    return 'Диапазон ставки: $min-$max фишек.';
  }

  @override
  String get createWagerError => 'Ставка не создана. Попробуйте еще раз.';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonConfirm => 'Подтвердить';

  @override
  String get commonRetry => 'Повторить';

  @override
  String get sampleGroupNamePrimary => 'Утренние соперники';

  @override
  String get sampleGroupNameSecondary => 'Офисные вызовы';

  @override
  String get sampleProfileName => 'Алексей';

  @override
  String get sampleWagerCondition => 'Кто первым закончит тренировку?';

  @override
  String get wagerOptionYes => 'Да';

  @override
  String get wagerOptionNo => 'Нет';

  @override
  String wagerOdds(String odds) {
    return 'x$odds';
  }

  @override
  String wagerStakeRatio(int left, int right) {
    return '$left / $right';
  }

  @override
  String get wagerConfirmTitle => 'Подтвердить выбор';

  @override
  String get wagerStakeAmountLabel => 'Сколько коинов рискнуть';

  @override
  String get wagerStakeAmountRequired => 'Введите количество фишек.';

  @override
  String get wagerStakeAmountInvalid => 'Введите положительное целое число.';

  @override
  String wagerStakeAmountTooHigh(int max) {
    return 'Максимальная ставка — $max фишек.';
  }

  @override
  String get wagerStakeInsufficientBalance =>
      'В этой группе недостаточно фишек.';

  @override
  String wagerPotentialPayout(int amount) {
    return 'Награда: $amount коинов';
  }

  @override
  String wagerRewardCoins(int amount) {
    return '$amount коинов';
  }

  @override
  String get wagerUnderdogBonus => 'Учитывает бонус за непопулярный выбор.';

  @override
  String get wagerYourChoice => 'Ваш выбор';

  @override
  String wagerCreatedAt(String value) {
    return 'Создано $value';
  }

  @override
  String wagerCompletedAt(String value) {
    return 'Завершено $value';
  }

  @override
  String get wagerStakeUnavailable => 'Вы не можете поставить на эту ставку.';

  @override
  String get wagerStakeError => 'Ставка не сделана. Попробуйте еще раз.';

  @override
  String get wagerResolveTitle => 'Подтвердить результат';

  @override
  String get wagerResolveBody =>
      'Ставка закроется, а победители получат выплату.';

  @override
  String wagerResolveAs(String label) {
    return 'Завершить как $label';
  }

  @override
  String get wagerResolveError =>
      'Результат не подтвержден. Попробуйте еще раз.';

  @override
  String get wagerCancelTitle => 'Отменить ставку?';

  @override
  String get wagerCancelBody =>
      'Все поставленные фишки вернутся участникам, а ставка уйдет в архив.';

  @override
  String get wagerCancelAction => 'Отменить ставку';

  @override
  String get wagerCancelError => 'Ставка не отменена. Попробуйте еще раз.';

  @override
  String get wagerConfirmBody =>
      'Фишки будут заморожены, пока админ не подтвердит результат.';

  @override
  String get wagerArchiveTitle => 'Архив ставок';

  @override
  String get wagerDetailsTitle => 'Детали ставки';

  @override
  String get wagerDetailsOpen => 'Открыть детали';

  @override
  String get wagerDetailsStatusActive => 'Активна';

  @override
  String get wagerDetailsStatusResolved => 'Завершена';

  @override
  String get wagerDetailsStatusCancelled => 'Отменена';

  @override
  String get wagerDetailsMyStake => 'Моя ставка';

  @override
  String get wagerDetailsNoStakes => 'Пока никто не поставил.';

  @override
  String get wagerArchiveEmpty => 'Завершенных ставок пока нет.';

  @override
  String get wagerArchiveSearchHint => 'Поиск ставок';

  @override
  String get wagerArchiveFilterAll => 'Все';

  @override
  String get wagerArchiveFilterResolved => 'Завершены';

  @override
  String get wagerArchiveFilterCancelled => 'Отменены';

  @override
  String get wagerArchiveSortLabel => 'Сортировка';

  @override
  String get wagerArchiveSortNewest => 'Новые';

  @override
  String get wagerArchiveSortLargestPool => 'Крупный пул';

  @override
  String get wagerArchiveSortMostStakes => 'Больше ставок';

  @override
  String get wagerArchiveFilteredEmpty => 'По этому поиску ничего нет.';

  @override
  String wagerArchiveResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ставки',
      many: '$count ставок',
      few: '$count ставки',
      one: '$count ставка',
    );
    return '$_temp0';
  }

  @override
  String wagerArchiveWinner(String label) {
    return 'Победитель: $label';
  }

  @override
  String wagerArchiveTotalPool(int amount) {
    return 'Пул: $amount';
  }

  @override
  String wagerArchiveWinningPool(int amount) {
    return 'На победителя: $amount';
  }

  @override
  String get wagerArchiveStakes => 'Ставки участников';

  @override
  String wagerArchiveStakeSide(String label, int amount) {
    return '$label';
  }

  @override
  String wagerArchivePayout(int amount) {
    return '+$amount';
  }

  @override
  String get groupPreviewTitle => 'Предпросмотр группы';

  @override
  String get groupSaveSuccess => 'Группа обновлена.';

  @override
  String get groupSaveError => 'Группа не обновлена. Попробуйте еще раз.';

  @override
  String get groupLeaveAction => 'Выйти из группы';

  @override
  String get groupLeaveTitle => 'Выйти из группы?';

  @override
  String get groupLeaveBody =>
      'Вы выйдете из группы. История завершенных ставок останется в архиве группы.';

  @override
  String get groupLeaveConfirm => 'Выйти';

  @override
  String get groupLeaveError => 'Сейчас нельзя выйти из этой группы.';

  @override
  String get wagerResultWon => 'Вы выиграли эту ставку.';

  @override
  String get wagerResultLost => 'Вы проиграли эту ставку.';

  @override
  String wagerResultWonInGroup(String groupName) {
    return 'Вы выиграли в группе $groupName.';
  }

  @override
  String wagerResultLostInGroup(String groupName) {
    return 'Вы проиграли в группе $groupName.';
  }

  @override
  String get authGenericError => 'Вход не завершился. Попробуйте еще раз.';

  @override
  String get achievementsTitle => 'Достижения';

  @override
  String achievementsSubtitle(int earned, int total) {
    return 'Открыто $earned из $total';
  }

  @override
  String get achievementsViewAll => 'Все';

  @override
  String get achievementsUnlockedSection => 'Открытые';

  @override
  String get achievementsNearestSection => 'Ближайшие';

  @override
  String get achievementStatusUnlocked => 'Открыто';

  @override
  String achievementUnlockedToast(String title) {
    return 'Достижение открыто: $title';
  }

  @override
  String achievementProgress(int current, int target) {
    return '$current из $target';
  }

  @override
  String achievementRequirementTotalWagers(int target) {
    return 'Сделать $target ставок';
  }

  @override
  String achievementRequirementCorrectWagers(int target) {
    return 'Выиграть $target ставок';
  }

  @override
  String achievementRequirementEarnedChips(int target) {
    return 'Заработать $target фишек';
  }

  @override
  String achievementRequirementLevel(int target) {
    return 'Достичь $target уровня';
  }

  @override
  String get achievementFirstWagerTitle => 'Первый ход';

  @override
  String get achievementFirstWagerDescription =>
      'Сделайте первую ставку в любой группе.';

  @override
  String get achievementFiveWagersTitle => 'Завсегдатай';

  @override
  String get achievementFiveWagersDescription => 'Сделайте 5 ставок.';

  @override
  String get achievementTwentyFiveWagersTitle => 'Читает риск';

  @override
  String get achievementTwentyFiveWagersDescription => 'Сделайте 25 ставок.';

  @override
  String get achievementHundredWagersTitle => 'Всегда в игре';

  @override
  String get achievementHundredWagersDescription => 'Сделайте 100 ставок.';

  @override
  String get achievementFirstWinTitle => 'Угадал';

  @override
  String get achievementFirstWinDescription => 'Выиграйте первую ставку.';

  @override
  String get achievementFiveWinsTitle => 'Точный расчет';

  @override
  String get achievementFiveWinsDescription => 'Выиграйте 5 ставок.';

  @override
  String get achievementTwentyFiveWinsTitle => 'Острый глаз';

  @override
  String get achievementTwentyFiveWinsDescription => 'Выиграйте 25 ставок.';

  @override
  String get achievementHundredWinsTitle => 'Легендарный выбор';

  @override
  String get achievementHundredWinsDescription => 'Выиграйте 100 ставок.';

  @override
  String get achievementHundredChipsTitle => 'Первый стек';

  @override
  String get achievementHundredChipsDescription =>
      'Заработайте 100 фишек во всех группах.';

  @override
  String get achievementThousandChipsTitle => 'Коллекционер фишек';

  @override
  String get achievementThousandChipsDescription =>
      'Заработайте 1 000 фишек во всех группах.';

  @override
  String get achievementTenThousandChipsTitle => 'Строит банк';

  @override
  String get achievementTenThousandChipsDescription =>
      'Заработайте 10 000 фишек во всех группах.';

  @override
  String get achievementLevelTwoTitle => 'Искра уровня';

  @override
  String get achievementLevelTwoDescription => 'Достигните 2 уровня.';

  @override
  String get achievementLevelFiveTitle => 'Разгон';

  @override
  String get achievementLevelFiveDescription => 'Достигните 5 уровня.';

  @override
  String get achievementLevelTenTitle => 'Две цифры';

  @override
  String get achievementLevelTenDescription => 'Достигните 10 уровня.';

  @override
  String get achievementLevelTwentyFiveTitle => 'Круг ветеранов';

  @override
  String get achievementLevelTwentyFiveDescription => 'Достигните 25 уровня.';

  @override
  String get notificationChannelName => 'Уведомления Point Rivals';
}
