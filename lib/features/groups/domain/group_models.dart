enum GroupMemberRole { admin, member }

final class RivalGroup {
  const RivalGroup({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.memberCount,
    required this.activeWagerCount,
    required this.myTokenBalance,
    required this.leaderboardWindowWeeks,
    required this.leaderboardPeriodAnchorDate,
    required this.accentColorValue,
  });

  final String id;
  final String name;
  final String inviteCode;
  final int memberCount;
  final int activeWagerCount;
  final int myTokenBalance;
  final int leaderboardWindowWeeks;
  final DateTime? leaderboardPeriodAnchorDate;
  final int accentColorValue;
}

final class GroupMember {
  const GroupMember({
    required this.userId,
    required this.displayName,
    required this.avatarUrl,
    required this.role,
    required this.tokenBalance,
    required this.weeklyTokensEarned,
    required this.weeklyScorePeriodId,
    required this.dailyTokenBuckets,
    required this.allTimeTokensEarned,
    required this.xp,
    required this.totalWagers,
    required this.correctWagers,
    required this.totalTokensEarned,
  });

  final String userId;
  final String displayName;
  final String? avatarUrl;
  final GroupMemberRole role;
  final int tokenBalance;
  final int weeklyTokensEarned;
  final String weeklyScorePeriodId;
  final Map<String, int> dailyTokenBuckets;
  final int allTimeTokensEarned;
  final int xp;
  final int totalWagers;
  final int correctWagers;
  final int totalTokensEarned;

  double get correctWagerRate {
    if (totalWagers == 0) {
      return 0;
    }

    return correctWagers / totalWagers;
  }

  GroupMember copyWith({
    String? displayName,
    String? avatarUrl,
    int? xp,
    int? totalWagers,
    int? correctWagers,
    int? totalTokensEarned,
  }) {
    return GroupMember(
      userId: userId,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role,
      tokenBalance: tokenBalance,
      weeklyTokensEarned: weeklyTokensEarned,
      weeklyScorePeriodId: weeklyScorePeriodId,
      dailyTokenBuckets: dailyTokenBuckets,
      allTimeTokensEarned: allTimeTokensEarned,
      xp: xp ?? this.xp,
      totalWagers: totalWagers ?? this.totalWagers,
      correctWagers: correctWagers ?? this.correctWagers,
      totalTokensEarned: totalTokensEarned ?? this.totalTokensEarned,
    );
  }
}
