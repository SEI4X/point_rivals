const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {onSchedule} = require("firebase-functions/v2/scheduler");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");
const {
  currentLeaderboardPeriodId,
  normalizePositiveInteger,
  normalizeSide,
  refundsForStakes,
  settlementForStakes,
  weeklyTokensEarnedUpdate,
} = require("./lib/wager_logic");

admin.initializeApp();

const db = admin.firestore();
const FieldValue = admin.firestore.FieldValue;

const XP_FOR_WIN = 35;
const XP_FOR_LOSS = 15;
const WAGER_STATUS_ACTIVE = "active";
const WAGER_STATUS_RESOLVED = "resolved";
const ADMIN_ROLE = "admin";
const MEMBER_ROLE = "member";
const SIDES = new Set(["left", "right"]);
const MEMBER_ACTIONS = new Set(["promote", "demote", "remove"]);
const NOTIFICATION_BATCH_SIZE = 500;
const FIRESTORE_BATCH_SIZE = 450;
const SUPPORTED_NOTIFICATION_LOCALES = new Set(["en", "ru"]);
const STALE_TOKEN_ERROR_CODES = new Set([
  "messaging/invalid-registration-token",
  "messaging/registration-token-not-registered",
]);

exports.notifyNewWager = onDocumentCreated({
  document: "groups/{groupId}/wagers/{wagerId}",
}, async (event) => {
  const wager = event.data && event.data.data();
  if (!wager || wager.status !== WAGER_STATUS_ACTIVE) {
    return;
  }
  if (wager.notifications && wager.notifications.newWagerSent === true) {
    return;
  }

  const groupId = event.params.groupId;
  const wagerId = event.params.wagerId;
  logger.info("New wager trigger received", {
    groupId,
    wagerId,
  });

  await notifyNewWagerRecipients({
    groupId,
    wagerId,
    wager,
  });
  await event.data.ref.set({
    notifications: {
      newWagerSent: true,
    },
  }, {merge: true});
});

async function notifyNewWagerRecipients({groupId, wagerId, wager}) {
  const excludedUserIds = new Set(Array.isArray(wager.excludedUserIds) ?
    wager.excludedUserIds : []);
  if (typeof wager.creatorUserId === "string") {
    excludedUserIds.add(wager.creatorUserId);
  }

  const groupSnapshot = await db.collection("groups").doc(groupId).get();
  const group = groupSnapshot.data() || {};
  const membersSnapshot = await db.collection("groups")
    .doc(groupId)
    .collection("members")
    .get();
  const recipientIds = [];
  membersSnapshot.forEach((memberSnapshot) => {
    if (!excludedUserIds.has(memberSnapshot.id)) {
      recipientIds.push(memberSnapshot.id);
    }
  });

  await sendNotificationToUsers(recipientIds, {
    data: {
      type: "newWager",
      groupId,
      wagerId,
    },
    notificationForTarget: (target) => ({
      title: group.name || "Point Rivals",
      body: localizedText(target.locale, {
        en: `New wager: ${wager.condition || "Open the group"}`,
        ru: `Новая ставка: ${wager.condition || "Откройте группу"}`,
      }),
    }),
  });

  await writeActivitiesForUsers(recipientIds, {
    type: "newWager",
    groupId,
    wagerId,
    groupName: group.name || "Point Rivals",
    condition: wager.condition || "",
    payout: 0,
  });
}

exports.previewGroupByInviteCode = onCall({enforceAppCheck: true}, async (request) => {
  const userId = request.auth && request.auth.uid;
  if (!userId) {
    throw new HttpsError("unauthenticated", "Sign in is required.");
  }

  const inviteCode = normalizeInviteCode(readRequiredString(request.data, "inviteCode"));
  const groupsSnapshot = await db.collection("groups")
    .where("inviteCode", "==", inviteCode)
    .limit(1)
    .get();
  if (groupsSnapshot.empty) {
    throw new HttpsError("not-found", "Group invite code was not found.");
  }

  const groupSnapshot = groupsSnapshot.docs[0];
  const group = groupSnapshot.data() || {};
  const memberSnapshot = await groupSnapshot.ref.collection("members").doc(userId).get();
  const member = memberSnapshot.data() || {};

  return publicGroupPayload({
    groupId: groupSnapshot.id,
    group,
    myTokenBalance: normalizePositiveInteger(member.tokenBalance),
  });
});

exports.joinGroupByInviteCode = onCall({enforceAppCheck: true}, async (request) => {
  const userId = request.auth && request.auth.uid;
  if (!userId) {
    throw new HttpsError("unauthenticated", "Sign in is required.");
  }

  const inviteCode = normalizeInviteCode(readRequiredString(request.data, "inviteCode"));
  const groupsSnapshot = await db.collection("groups")
    .where("inviteCode", "==", inviteCode)
    .limit(1)
    .get();
  if (groupsSnapshot.empty) {
    throw new HttpsError("not-found", "Group invite code was not found.");
  }

  const groupSnapshot = groupsSnapshot.docs[0];
  const groupReference = groupSnapshot.ref;
  const memberReference = groupReference.collection("members").doc(userId);
  const userReference = db.collection("users").doc(userId);

  const result = await db.runTransaction(async (transaction) => {
    const [groupDoc, memberSnapshot, userSnapshot] = await Promise.all([
      transaction.get(groupReference),
      transaction.get(memberReference),
      transaction.get(userReference),
    ]);
    const group = groupDoc.data() || {};

    if (!memberSnapshot.exists) {
      const user = userSnapshot.data() || {};
      transaction.set(memberReference, {
        userId,
        displayName: typeof user.displayName === "string" ? user.displayName : "",
        avatarUrl: typeof user.avatarUrl === "string" ? user.avatarUrl : null,
        role: MEMBER_ROLE,
        tokenBalance: 0,
        weeklyTokensEarned: 0,
        weeklyScorePeriodId: "",
        allTimeTokensEarned: 0,
        xp: normalizePositiveInteger(user.xp),
        totalWagers: normalizePositiveInteger(user.totalWagers),
        correctWagers: normalizePositiveInteger(user.correctWagers),
        totalTokensEarned: normalizePositiveInteger(user.totalTokensEarned),
        joinedAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });
      transaction.update(groupReference, {
        memberCount: FieldValue.increment(1),
        updatedAt: FieldValue.serverTimestamp(),
      });
    }

    return publicGroupPayload({
      groupId: groupDoc.id,
      group,
      myTokenBalance: memberSnapshot.exists ?
        normalizePositiveInteger((memberSnapshot.data() || {}).tokenBalance) :
        0,
    });
  });

  logger.info("Group joined by invite code", {
    groupId: result.id,
    userId,
  });

  return result;
});

exports.createWager = onCall({enforceAppCheck: true}, async (request) => {
  const userId = request.auth && request.auth.uid;
  if (!userId) {
    throw new HttpsError("unauthenticated", "Sign in is required.");
  }

  const groupId = readRequiredString(request.data, "groupId");
  const condition = readRequiredString(request.data, "condition");
  const type = readRequiredString(request.data, "type");
  const leftLabel = readRequiredString(request.data, "leftLabel");
  const rightLabel = readRequiredString(request.data, "rightLabel");
  const rewardCoins = normalizePositiveInteger(request.data && request.data.rewardCoins) || 10;
  const excludedUserIds = normalizeStringArray(request.data && request.data.excludedUserIds);
  if (condition.length > 160) {
    throw new HttpsError("invalid-argument", "Wager condition is too long.");
  }
  if (!["yesNo", "participantVsParticipant", "custom"].includes(type)) {
    throw new HttpsError("invalid-argument", "Unknown wager type.");
  }
  if (leftLabel.length > 28 || rightLabel.length > 28) {
    throw new HttpsError("invalid-argument", "Wager option label is too long.");
  }
  if (rewardCoins > 1000) {
    throw new HttpsError("invalid-argument", "Reward amount is too high.");
  }

  const groupReference = db.collection("groups").doc(groupId);
  const memberReference = groupReference.collection("members").doc(userId);
  const wagerReference = groupReference.collection("wagers").doc();
  const wagerId = wagerReference.id;

  await db.runTransaction(async (transaction) => {
    const memberSnapshot = await transaction.get(memberReference);
    if (!memberSnapshot.exists) {
      throw new HttpsError("permission-denied", "Group member was not found.");
    }

    transaction.set(wagerReference, {
      groupId,
      creatorUserId: userId,
      condition,
      type,
      leftLabel,
      rightLabel,
      rewardCoins,
      excludedUserIds,
      status: WAGER_STATUS_ACTIVE,
      notifications: {
        newWagerSent: true,
      },
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
    transaction.update(groupReference, {
      activeWagerCount: FieldValue.increment(1),
      updatedAt: FieldValue.serverTimestamp(),
    });
  });

  logger.info("Wager created", {
    groupId,
    wagerId,
    creatorUserId: userId,
  });

  await notifyNewWagerRecipients({
    groupId,
    wagerId,
    wager: {
      condition,
      status: WAGER_STATUS_ACTIVE,
      creatorUserId: userId,
      excludedUserIds,
    },
  });

  return {wagerId};
});

exports.placeStake = onCall({enforceAppCheck: true}, async (request) => {
  const userId = request.auth && request.auth.uid;
  if (!userId) {
    throw new HttpsError("unauthenticated", "Sign in is required.");
  }

  const groupId = readRequiredString(request.data, "groupId");
  const wagerId = readRequiredString(request.data, "wagerId");
  const side = normalizeSide(readRequiredString(request.data, "side"));
  if (!SIDES.has(side)) {
    throw new HttpsError("invalid-argument", "Unknown wager side.");
  }

  const groupReference = db.collection("groups").doc(groupId);
  const wagerReference = groupReference.collection("wagers").doc(wagerId);
  const stakeReference = wagerReference.collection("stakes").doc(userId);
  const memberReference = groupReference.collection("members").doc(userId);

  const result = await db.runTransaction(async (transaction) => {
    const [
      wagerSnapshot,
      existingStakeSnapshot,
      memberSnapshot,
    ] = await Promise.all([
      transaction.get(wagerReference),
      transaction.get(stakeReference),
      transaction.get(memberReference),
    ]);

    if (!wagerSnapshot.exists) {
      throw new HttpsError("not-found", "Wager was not found.");
    }
    if (existingStakeSnapshot.exists) {
      throw new HttpsError("failed-precondition", "User has already staked.");
    }
    if (!memberSnapshot.exists) {
      throw new HttpsError("permission-denied", "Group member was not found.");
    }

    const wager = wagerSnapshot.data() || {};
    const excludedUserIds = Array.isArray(wager.excludedUserIds) ?
      wager.excludedUserIds :
      [];
    if (wager.status !== WAGER_STATUS_ACTIVE || excludedUserIds.includes(userId)) {
      throw new HttpsError("failed-precondition", "User cannot stake on this wager.");
    }

    transaction.set(stakeReference, {
      userId,
      side,
      amount: 1,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
    transaction.update(wagerReference, {
      updatedAt: FieldValue.serverTimestamp(),
    });
    return {
      selectedSide: side,
    };
  });

  logger.info("Stake placed", {
    groupId,
    wagerId,
    userId,
    side,
  });

  return result;
});

exports.resolveWager = onCall({enforceAppCheck: true}, async (request) => {
  const userId = request.auth && request.auth.uid;
  if (!userId) {
    throw new HttpsError("unauthenticated", "Sign in is required.");
  }

  const groupId = readRequiredString(request.data, "groupId");
  const wagerId = readRequiredString(request.data, "wagerId");
  const winningSide = readRequiredString(request.data, "winningSide");
  if (!SIDES.has(winningSide)) {
    throw new HttpsError("invalid-argument", "Unknown winning side.");
  }

  const groupReference = db.collection("groups").doc(groupId);
  const adminMemberReference = groupReference.collection("members").doc(userId);
  const wagerReference = groupReference.collection("wagers").doc(wagerId);

  const result = await db.runTransaction(async (transaction) => {
    const adminMemberSnapshot = await transaction.get(adminMemberReference);
    if (!adminMemberSnapshot.exists) {
      throw new HttpsError("permission-denied", "Only group admins can resolve wagers.");
    }

    const adminMember = adminMemberSnapshot.data();
    if (!adminMember || adminMember.role !== ADMIN_ROLE) {
      throw new HttpsError("permission-denied", "Only group admins can resolve wagers.");
    }

    const wagerSnapshot = await transaction.get(wagerReference);
    if (!wagerSnapshot.exists) {
      throw new HttpsError("not-found", "Wager was not found.");
    }

    const wager = wagerSnapshot.data();
    if (!wager || wager.status !== WAGER_STATUS_ACTIVE) {
      throw new HttpsError("failed-precondition", "Wager is not active.");
    }

    const stakesSnapshot = await transaction.get(wagerReference.collection("stakes"));
    const stakes = [];
    stakesSnapshot.forEach((stakeSnapshot) => {
      const stake = stakeSnapshot.data();
      if (!stake) {
        return;
      }

      stakes.push({
        userId: stakeSnapshot.id,
        side: normalizeSide(stake.side),
        amount: normalizePositiveInteger(stake.amount) || 1,
      });
    });

    const settlement = settlementForStakes(
      stakes,
      winningSide,
      normalizePositiveInteger(wager.rewardCoins) || 10,
    );
    const validStakes = settlement.validStakes;
    const totalPool = settlement.totalPool;
    const winningSideTotal = settlement.winningSideTotal;
    const payouts = settlement.payouts;
    const groupSnapshot = await transaction.get(groupReference);
    const group = groupSnapshot.data() || {};
    const currentWeeklyPeriodId = currentLeaderboardPeriodId(
      normalizePositiveInteger(group.leaderboardWindowWeeks) || 1,
      new Date(),
      group.leaderboardPeriodAnchorDate || null,
    );
    const memberSnapshots = {};
    for (const stake of validStakes) {
      const memberReference = groupReference.collection("members").doc(stake.userId);
      memberSnapshots[stake.userId] = await transaction.get(memberReference);
    }

    for (const stake of validStakes) {
      const won = stake.side === winningSide;
      const payout = payouts[stake.userId] || 0;
      const xpDelta = won ? XP_FOR_WIN : XP_FOR_LOSS;

      const userReference = db.collection("users").doc(stake.userId);
      transaction.set(userReference, {
        xp: FieldValue.increment(xpDelta),
        totalWagers: FieldValue.increment(1),
        correctWagers: FieldValue.increment(won ? 1 : 0),
        totalTokensEarned: FieldValue.increment(payout),
        updatedAt: FieldValue.serverTimestamp(),
      }, {merge: true});

      const memberReference = groupReference.collection("members").doc(stake.userId);
      const memberSnapshot = memberSnapshots[stake.userId];
      const member = memberSnapshot && memberSnapshot.data();
      const memberUpdate = {
        xp: FieldValue.increment(xpDelta),
        totalWagers: FieldValue.increment(1),
        correctWagers: FieldValue.increment(won ? 1 : 0),
        totalTokensEarned: FieldValue.increment(payout),
        updatedAt: FieldValue.serverTimestamp(),
      };

      if (payout <= 0) {
        transaction.update(memberReference, memberUpdate);
        continue;
      }

      transaction.update(memberReference, {
        ...memberUpdate,
        tokenBalance: FieldValue.increment(payout),
        weeklyTokensEarned: weeklyTokensEarnedUpdate({
          member,
          currentWeeklyPeriodId,
          payout,
          increment: (value) => FieldValue.increment(value),
        }),
        weeklyScorePeriodId: currentWeeklyPeriodId,
        allTimeTokensEarned: FieldValue.increment(payout),
        updatedAt: FieldValue.serverTimestamp(),
      });
    }

    transaction.update(wagerReference, {
      status: WAGER_STATUS_RESOLVED,
      winningSide,
      resolvedBy: userId,
      resolvedAt: FieldValue.serverTimestamp(),
      settlement: {
        totalPool,
        winningSideTotal,
        payouts,
      },
      updatedAt: FieldValue.serverTimestamp(),
    });

    transaction.update(groupReference, {
      activeWagerCount: FieldValue.increment(-1),
      updatedAt: FieldValue.serverTimestamp(),
    });

    return {
      totalPool,
      winningSideTotal,
      resolvedStakeCount: validStakes.length,
      payouts,
    };
  });

  logger.info("Wager resolved", {
    groupId,
    wagerId,
    winningSide,
    resolvedBy: userId,
    ...result,
  });

  try {
    await notifyResolvedWager({
      groupId,
      wagerId,
      winningSide,
      payouts: result.payouts,
    });
  } catch (error) {
    logger.error("Resolved wager notification failed", {
      groupId,
      wagerId,
      winningSide,
      error,
    });
  }

  return result;
});

exports.resetWeeklyLeaderboards = onSchedule({
  schedule: "10 0 * * *",
  timeZone: "Etc/UTC",
}, async () => {
  const groupsSnapshot = await db.collection("groups").get();
  let batch = db.batch();
  let batchSize = 0;
  let updatedCount = 0;

  for (const groupSnapshot of groupsSnapshot.docs) {
    const group = groupSnapshot.data() || {};
    const currentWeeklyPeriodId = currentLeaderboardPeriodId(
      normalizePositiveInteger(group.leaderboardWindowWeeks) || 1,
      new Date(),
      group.leaderboardPeriodAnchorDate || null,
    );
    const membersSnapshot = await groupSnapshot.ref.collection("members").get();

    for (const memberSnapshot of membersSnapshot.docs) {
      const member = memberSnapshot.data() || {};
      if (member.weeklyScorePeriodId === currentWeeklyPeriodId) {
        continue;
      }

      batch.update(memberSnapshot.ref, {
        weeklyTokensEarned: 0,
        weeklyScorePeriodId: currentWeeklyPeriodId,
        updatedAt: FieldValue.serverTimestamp(),
      });
      batchSize += 1;
      updatedCount += 1;

      if (batchSize >= FIRESTORE_BATCH_SIZE) {
        await batch.commit();
        batch = db.batch();
        batchSize = 0;
      }
    }
  }

  if (batchSize > 0) {
    await batch.commit();
  }

  logger.info("Weekly leaderboards reset", {
    updatedCount,
  });
});

exports.manageGroupMember = onCall({enforceAppCheck: true}, async (request) => {
  const userId = request.auth && request.auth.uid;
  if (!userId) {
    throw new HttpsError("unauthenticated", "Sign in is required.");
  }

  const groupId = readRequiredString(request.data, "groupId");
  const targetUserId = readRequiredString(request.data, "targetUserId");
  const action = readRequiredString(request.data, "action");
  if (!MEMBER_ACTIONS.has(action)) {
    throw new HttpsError("invalid-argument", "Unknown member action.");
  }

  if (targetUserId === userId) {
    throw new HttpsError("failed-precondition", "You cannot change your own membership.");
  }

  const groupReference = db.collection("groups").doc(groupId);
  const actorMemberReference = groupReference.collection("members").doc(userId);
  const targetMemberReference = groupReference.collection("members").doc(targetUserId);

  const result = await db.runTransaction(async (transaction) => {
    const actorSnapshot = await transaction.get(actorMemberReference);
    if (!actorSnapshot.exists) {
      throw new HttpsError("permission-denied", "Only group admins can manage members.");
    }

    const actor = actorSnapshot.data();
    if (!actor || actor.role !== ADMIN_ROLE) {
      throw new HttpsError("permission-denied", "Only group admins can manage members.");
    }

    const targetSnapshot = await transaction.get(targetMemberReference);
    if (!targetSnapshot.exists) {
      throw new HttpsError("not-found", "Group member was not found.");
    }

    const target = targetSnapshot.data();
    const targetRole = target && target.role;
    if ((action === "demote" || action === "remove") && targetRole === ADMIN_ROLE) {
      const adminsSnapshot = await transaction.get(
        groupReference.collection("members").where("role", "==", ADMIN_ROLE),
      );
      if (adminsSnapshot.size <= 1) {
        throw new HttpsError("failed-precondition", "A group must keep at least one admin.");
      }
    }

    if (action === "remove") {
      transaction.delete(targetMemberReference);
      transaction.update(groupReference, {
        memberCount: FieldValue.increment(-1),
        updatedAt: FieldValue.serverTimestamp(),
      });
      return {action, targetUserId};
    }

    const role = action === "promote" ? ADMIN_ROLE : MEMBER_ROLE;
    transaction.update(targetMemberReference, {
      role,
      updatedAt: FieldValue.serverTimestamp(),
    });
    transaction.update(groupReference, {
      updatedAt: FieldValue.serverTimestamp(),
    });

    return {action, targetUserId, role};
  });

  logger.info("Group member managed", {
    groupId,
    managedBy: userId,
    ...result,
  });

  return result;
});

exports.leaveGroup = onCall({enforceAppCheck: true}, async (request) => {
  const userId = request.auth && request.auth.uid;
  if (!userId) {
    throw new HttpsError("unauthenticated", "Sign in is required.");
  }

  const groupId = readRequiredString(request.data, "groupId");
  const groupReference = db.collection("groups").doc(groupId);
  const memberReference = groupReference.collection("members").doc(userId);

  const result = await db.runTransaction(async (transaction) => {
    const memberSnapshot = await transaction.get(memberReference);
    if (!memberSnapshot.exists) {
      throw new HttpsError("not-found", "Group member was not found.");
    }

    const member = memberSnapshot.data();
    if (member && member.role === ADMIN_ROLE) {
      const adminsSnapshot = await transaction.get(
        groupReference.collection("members").where("role", "==", ADMIN_ROLE),
      );
      if (adminsSnapshot.size <= 1) {
        throw new HttpsError("failed-precondition", "A group must keep at least one admin.");
      }
    }

    transaction.delete(memberReference);
    transaction.update(groupReference, {
      memberCount: FieldValue.increment(-1),
      updatedAt: FieldValue.serverTimestamp(),
    });

    return {groupId, userId};
  });

  logger.info("Group member left", result);
  return result;
});

exports.cancelWager = onCall({enforceAppCheck: true}, async (request) => {
  const userId = request.auth && request.auth.uid;
  if (!userId) {
    throw new HttpsError("unauthenticated", "Sign in is required.");
  }

  const groupId = readRequiredString(request.data, "groupId");
  const wagerId = readRequiredString(request.data, "wagerId");
  const groupReference = db.collection("groups").doc(groupId);
  const adminMemberReference = groupReference.collection("members").doc(userId);
  const wagerReference = groupReference.collection("wagers").doc(wagerId);

  const result = await db.runTransaction(async (transaction) => {
    const adminMemberSnapshot = await transaction.get(adminMemberReference);
    if (!adminMemberSnapshot.exists) {
      throw new HttpsError("permission-denied", "Only group admins can cancel wagers.");
    }

    const adminMember = adminMemberSnapshot.data();
    if (!adminMember || adminMember.role !== ADMIN_ROLE) {
      throw new HttpsError("permission-denied", "Only group admins can cancel wagers.");
    }

    const wagerSnapshot = await transaction.get(wagerReference);
    if (!wagerSnapshot.exists) {
      throw new HttpsError("not-found", "Wager was not found.");
    }

    const wager = wagerSnapshot.data();
    if (!wager || wager.status !== WAGER_STATUS_ACTIVE) {
      throw new HttpsError("failed-precondition", "Wager is not active.");
    }

    const stakesSnapshot = await transaction.get(wagerReference.collection("stakes"));
    const stakes = [];
    stakesSnapshot.forEach((stakeSnapshot) => {
      const stake = stakeSnapshot.data();
      stakes.push({
        userId: stakeSnapshot.id,
        amount: stake && stake.amount,
      });
    });
    const refunds = refundsForStakes(stakes);
    const totalPool = Object.values(refunds).reduce((total, amount) => total + amount, 0);
    transaction.update(wagerReference, {
      status: "cancelled",
      cancelledBy: userId,
      cancelledAt: FieldValue.serverTimestamp(),
      settlement: {
        totalPool,
        winningSideTotal: 0,
        payouts: refunds,
      },
      updatedAt: FieldValue.serverTimestamp(),
    });
    transaction.update(groupReference, {
      activeWagerCount: FieldValue.increment(-1),
      updatedAt: FieldValue.serverTimestamp(),
    });

    return {totalPool, refundedUserIds: Object.keys(refunds)};
  });

  logger.info("Wager cancelled", {
    groupId,
    wagerId,
    cancelledBy: userId,
    ...result,
  });

  await notifyCancelledWager({
    groupId,
    wagerId,
    recipientIds: result.refundedUserIds,
  });

  return result;
});

function readRequiredString(data, field) {
  const value = data && data[field];
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new HttpsError("invalid-argument", `${field} is required.`);
  }

  return value.trim();
}

function normalizeStringArray(value) {
  if (!Array.isArray(value)) {
    return [];
  }

  return [...new Set(value.filter((item) => (
    typeof item === "string" && item.length > 0
  )))];
}

function normalizeInviteCode(value) {
  const trimmed = value.trim();
  let normalized = trimmed;
  try {
    const parsed = new URL(trimmed);
    const queryCode = parsed.searchParams.get("code");
    if (queryCode && queryCode.trim().length > 0) {
      normalized = queryCode.trim();
    }
  } catch (error) {
    const codeMatch = trimmed.match(/(?:code|invite|код)[^A-Za-z0-9]*([A-Za-z0-9]{4,24})/i);
    if (codeMatch && codeMatch[1]) {
      normalized = codeMatch[1];
    }
  }

  return normalized.toUpperCase();
}

function publicGroupPayload({groupId, group, myTokenBalance}) {
  return {
    id: groupId,
    name: typeof group.name === "string" ? group.name : "",
    inviteCode: typeof group.inviteCode === "string" ? group.inviteCode : "",
    memberCount: normalizePositiveInteger(group.memberCount),
    activeWagerCount: normalizePositiveInteger(group.activeWagerCount),
    myTokenBalance,
    leaderboardWindowWeeks: normalizePositiveInteger(group.leaderboardWindowWeeks) || 1,
    leaderboardPeriodAnchorDate: group.leaderboardPeriodAnchorDate || null,
    accentColor: normalizePositiveInteger(group.accentColor),
  };
}

async function notifyResolvedWager({groupId, wagerId, winningSide, payouts}) {
  const wagerReference = db.collection("groups").doc(groupId)
    .collection("wagers").doc(wagerId);
  const [groupSnapshot, wagerSnapshot] = await Promise.all([
    db.collection("groups").doc(groupId).get(),
    wagerReference.get(),
  ]);
  const group = groupSnapshot.data() || {};
  const wager = wagerSnapshot.data() || {};
  const recipientIds = Object.keys(payouts || {});
  if (recipientIds.length === 0) {
    return;
  }

  await sendNotificationToUsers(recipientIds, {
    data: {
      type: "wagerResolved",
      groupId,
      wagerId,
      winningSide,
    },
    notificationForTarget: (target) => {
      const payout = normalizePositiveInteger(payouts[target.userId]);
      const won = payout > 0;
      return {
        title: group.name || "Point Rivals",
        body: localizedText(target.locale, {
          en: won ?
            `You won ${payout} chips: ${wager.condition || "wager resolved"}` :
            `You lost: ${wager.condition || "wager resolved"}`,
          ru: won ?
            `Вы выиграли ${payout} фишек: ${wager.condition || "ставка завершена"}` :
            `Вы проиграли: ${wager.condition || "ставка завершена"}`,
        }),
      };
    },
  });

  await writeActivitiesForUsers(recipientIds, {
    type: "wagerResolved",
    groupId,
    wagerId,
    groupName: group.name || "Point Rivals",
    condition: wager.condition || "",
    payoutForUserId: payouts || {},
  });
}

async function notifyCancelledWager({groupId, wagerId, recipientIds}) {
  if (recipientIds.length === 0) {
    return;
  }

  const [groupSnapshot, wagerSnapshot] = await Promise.all([
    db.collection("groups").doc(groupId).get(),
    db.collection("groups").doc(groupId).collection("wagers").doc(wagerId).get(),
  ]);
  const group = groupSnapshot.data() || {};
  const wager = wagerSnapshot.data() || {};

  await sendNotificationToUsers(recipientIds, {
    data: {
      type: "wagerCancelled",
      groupId,
      wagerId,
    },
    notificationForTarget: (target) => ({
      title: group.name || "Point Rivals",
      body: localizedText(target.locale, {
        en: `Wager cancelled. Chips returned: ${wager.condition || "open the group"}`,
        ru: `Ставка отменена. Фишки возвращены: ${wager.condition || "откройте группу"}`,
      }),
    }),
  });

  await writeActivitiesForUsers(recipientIds, {
    type: "wagerCancelled",
    groupId,
    wagerId,
    groupName: group.name || "Point Rivals",
    condition: wager.condition || "",
    payout: 0,
  });
}

async function writeActivitiesForUsers(userIds, activity) {
  const uniqueUserIds = [...new Set(userIds)].filter(Boolean);
  if (uniqueUserIds.length === 0) {
    return;
  }

  let batch = db.batch();
  let batchSize = 0;
  for (const userId of uniqueUserIds) {
    const activityReference = db.collection("users").doc(userId)
      .collection("activities")
      .doc(`${activity.type}_${activity.groupId}_${activity.wagerId}`);
    const payout = activity.payoutForUserId ?
      normalizePositiveInteger(activity.payoutForUserId[userId]) :
      normalizePositiveInteger(activity.payout);

    batch.set(activityReference, {
      type: activity.type,
      groupId: activity.groupId,
      wagerId: activity.wagerId,
      groupName: activity.groupName,
      condition: activity.condition,
      payout,
      createdAt: FieldValue.serverTimestamp(),
    }, {merge: true});
    batchSize += 1;

    if (batchSize >= FIRESTORE_BATCH_SIZE) {
      await batch.commit();
      batch = db.batch();
      batchSize = 0;
    }
  }

  if (batchSize > 0) {
    await batch.commit();
  }
}

async function sendNotificationToUsers(userIds, {data, notificationForTarget}) {
  const uniqueUserIds = [...new Set(userIds)].filter(Boolean);
  if (uniqueUserIds.length === 0) {
    logger.info("Notification skipped: no recipients", {
      type: data && data.type,
    });
    return;
  }

  const targets = [];
  let disabledUsers = 0;
  let usersWithoutTokens = 0;
  for (const userId of uniqueUserIds) {
    const userSnapshot = await db.collection("users").doc(userId).get();
    const user = userSnapshot.data();
    if (!user || user.notificationsEnabled !== true) {
      disabledUsers += 1;
      continue;
    }

    const tokensSnapshot = await db.collection("users").doc(userId)
      .collection("deviceTokens")
      .get();
    if (tokensSnapshot.empty) {
      usersWithoutTokens += 1;
    }
    tokensSnapshot.forEach((tokenSnapshot) => {
      const tokenData = tokenSnapshot.data() || {};
      const token = tokenData.token;
      if (typeof token === "string" && token.length > 0) {
        targets.push({
          userId,
          token,
          tokenReference: tokenSnapshot.ref,
          locale: normalizedNotificationLocale(tokenData.locale),
        });
      }
    });
  }

  const uniqueTargets = uniqueTargetsByToken(targets);
  logger.info("Notification targets resolved", {
    type: data && data.type,
    recipientCount: uniqueUserIds.length,
    disabledUsers,
    usersWithoutTokens,
    tokenCount: uniqueTargets.length,
  });
  const groupedTargets = groupTargetsByNotification(uniqueTargets, notificationForTarget);
  for (const group of groupedTargets) {
    for (let index = 0; index < group.targets.length; index += NOTIFICATION_BATCH_SIZE) {
      const batchTargets = group.targets.slice(index, index + NOTIFICATION_BATCH_SIZE);
      const response = await admin.messaging().sendEachForMulticast({
        notification: group.notification,
        data,
        tokens: batchTargets.map((target) => target.token),
        android: {
          priority: "high",
          notification: {
            channelId: "point_rivals_alerts",
            sound: "default",
          },
        },
        apns: {
          headers: {
            "apns-priority": "10",
            "apns-push-type": "alert",
          },
          payload: {
            aps: {
              sound: "default",
            },
          },
        },
      });

      logger.info("Notification batch sent", {
        type: data && data.type,
        successCount: response.successCount,
        failureCount: response.failureCount,
      });
      response.responses.forEach((item, responseIndex) => {
        if (!item.error) {
          return;
        }

        logger.warn("Notification token failed", {
          type: data && data.type,
          userId: batchTargets[responseIndex].userId,
          code: item.error.code,
          message: item.error.message,
        });
      });
      await deleteStaleTokens(batchTargets, response.responses);
    }
  }
}

function uniqueTargetsByToken(targets) {
  const byToken = new Map();
  for (const target of targets) {
    if (!byToken.has(target.token)) {
      byToken.set(target.token, target);
    }
  }

  return [...byToken.values()];
}

function groupTargetsByNotification(targets, notificationForTarget) {
  const groups = new Map();
  for (const target of targets) {
    const notification = notificationForTarget(target);
    const key = JSON.stringify(notification);
    const group = groups.get(key) || {notification, targets: []};
    group.targets.push(target);
    groups.set(key, group);
  }

  return [...groups.values()];
}

async function deleteStaleTokens(targets, responses) {
  const staleTokenReferences = [];
  responses.forEach((response, index) => {
    const errorCode = response.error && response.error.code;
    if (STALE_TOKEN_ERROR_CODES.has(errorCode)) {
      staleTokenReferences.push(targets[index].tokenReference);
    }
  });

  if (staleTokenReferences.length === 0) {
    return;
  }

  let batch = db.batch();
  let batchSize = 0;
  for (const tokenReference of staleTokenReferences) {
    batch.delete(tokenReference);
    batchSize += 1;

    if (batchSize >= FIRESTORE_BATCH_SIZE) {
      await batch.commit();
      batch = db.batch();
      batchSize = 0;
    }
  }

  if (batchSize > 0) {
    await batch.commit();
  }

  logger.info("Stale FCM tokens deleted", {
    count: staleTokenReferences.length,
  });
}

function normalizedNotificationLocale(value) {
  if (typeof value !== "string") {
    return "en";
  }

  const locale = value.toLowerCase().split("-")[0];
  return SUPPORTED_NOTIFICATION_LOCALES.has(locale) ? locale : "en";
}

function localizedText(locale, values) {
  return values[normalizedNotificationLocale(locale)] || values.en;
}
