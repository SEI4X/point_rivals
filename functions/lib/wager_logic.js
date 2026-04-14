"use strict";

const SIDES = new Set(["left", "right"]);

function settlementForStakes(stakes, winningSide, rewardCoins = 10) {
  const validStakes = stakes.filter((stake) => (
    SIDES.has(stake.side)
  ));
  const normalizedReward = normalizePositiveInteger(rewardCoins) || 10;
  const totalPool = validStakes.length * normalizedReward;
  const winningSideTotal = validStakes
    .filter((stake) => stake.side === winningSide)
    .length;
  const leftCount = validStakes.filter((stake) => stake.side === "left").length;
  const rightCount = validStakes.filter((stake) => stake.side === "right").length;
  const unpopularWinningSide =
    (winningSide === "left" && leftCount > 0 && leftCount < rightCount) ||
    (winningSide === "right" && rightCount > 0 && rightCount < leftCount);
  const winningPayout = unpopularWinningSide ?
    Math.floor(normalizedReward * 1.5) :
    normalizedReward;
  const payouts = {};

  for (const stake of validStakes) {
    payouts[stake.userId] = stake.side === winningSide ?
      winningPayout :
      0;
  }

  return {
    validStakes,
    totalPool,
    winningSideTotal,
    payouts,
  };
}

function refundsForStakes(stakes) {
  const refunds = {};
  for (const stake of stakes) {
    if (typeof stake.userId === "string" && stake.userId.length > 0) {
      refunds[stake.userId] = 0;
    }
  }

  return refunds;
}

function weeklyTokensEarnedUpdate({
  member,
  currentWeeklyPeriodId,
  payout,
  increment,
}) {
  if (member && member.weeklyScorePeriodId === currentWeeklyPeriodId) {
    return increment(payout);
  }

  return payout;
}

function normalizeSide(value) {
  return typeof value === "string" ? value : "";
}

function normalizePositiveInteger(value) {
  return Number.isInteger(value) && value > 0 ? value : 0;
}

function normalizePositiveNumber(value) {
  return typeof value === "number" && Number.isFinite(value) && value > 0 ?
    value :
    0;
}

function currentIsoWeekPeriodId(date = new Date()) {
  return isoWeekParts(date).periodId;
}

function currentLeaderboardPeriodId(windowWeeks = 1, date = new Date(), anchorDate = null) {
  const normalizedWindowWeeks = Number.isInteger(windowWeeks) && windowWeeks > 0 ?
    windowWeeks :
    1;
  const normalizedAnchor = normalizeDate(anchorDate);
  if (normalizedAnchor) {
    return sprintPeriodId(normalizedWindowWeeks, date, normalizedAnchor);
  }

  const parts = isoWeekParts(date);
  if (normalizedWindowWeeks === 1) {
    return parts.periodId;
  }

  const windowIndex = Math.floor((parts.week - 1) / normalizedWindowWeeks) + 1;
  return `${parts.year}-W${String(windowIndex).padStart(2, "0")}x${normalizedWindowWeeks}`;
}

function sprintPeriodId(windowWeeks, date = new Date(), anchorDate) {
  const dayInMilliseconds = 24 * 60 * 60 * 1000;
  const periodDays = windowWeeks * 7;
  const anchor = utcDateOnly(anchorDate);
  const current = utcDateOnly(date);
  const daysSinceAnchor = Math.floor((current - anchor) / dayInMilliseconds);
  const periodIndex = daysSinceAnchor < 0 ? 0 : Math.floor(daysSinceAnchor / periodDays);
  const periodStart = new Date(anchor.getTime() + periodIndex * periodDays * dayInMilliseconds);

  return `${dateId(periodStart)}-S${String(periodIndex + 1).padStart(3, "0")}x${windowWeeks}`;
}

function normalizeDate(value) {
  if (value && typeof value.toDate === "function") {
    return value.toDate();
  }
  if (value instanceof Date && Number.isFinite(value.getTime())) {
    return value;
  }
  if (typeof value === "string") {
    const parsed = new Date(value);
    return Number.isFinite(parsed.getTime()) ? parsed : null;
  }

  return null;
}

function utcDateOnly(date) {
  return new Date(Date.UTC(
    date.getUTCFullYear(),
    date.getUTCMonth(),
    date.getUTCDate(),
  ));
}

function dateId(date) {
  return `${date.getUTCFullYear()}${String(date.getUTCMonth() + 1).padStart(2, "0")}${String(date.getUTCDate()).padStart(2, "0")}`;
}

function isoWeekParts(date = new Date()) {
  const dayInMilliseconds = 24 * 60 * 60 * 1000;
  const utcDate = new Date(Date.UTC(
    date.getUTCFullYear(),
    date.getUTCMonth(),
    date.getUTCDate(),
  ));
  const day = utcDate.getUTCDay() || 7;
  utcDate.setUTCDate(utcDate.getUTCDate() + 4 - day);

  const yearStart = new Date(Date.UTC(utcDate.getUTCFullYear(), 0, 1));
  const week = Math.ceil(((utcDate - yearStart) / dayInMilliseconds + 1) / 7);
  const year = utcDate.getUTCFullYear();
  return {
    year,
    week,
    periodId: `${year}-W${String(week).padStart(2, "0")}`,
  };
}

module.exports = {
  currentLeaderboardPeriodId,
  currentIsoWeekPeriodId,
  normalizePositiveInteger,
  normalizePositiveNumber,
  normalizeSide,
  refundsForStakes,
  settlementForStakes,
  weeklyTokensEarnedUpdate,
};
