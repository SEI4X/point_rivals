"use strict";

const SIDES = new Set(["left", "right"]);

function settlementForStakes(stakes, winningSide) {
  const validStakes = stakes.filter((stake) => (
    SIDES.has(stake.side) && normalizePositiveInteger(stake.amount) > 0
  ));
  const totalPool = validStakes.reduce((total, stake) => total + stake.amount, 0);
  const winningSideTotal = validStakes
    .filter((stake) => stake.side === winningSide)
    .reduce((total, stake) => total + stake.amount, 0);
  const payouts = {};

  for (const stake of validStakes) {
    const fallbackOdds = oddsForSide(totalPool, winningSideTotal);
    const odds = normalizePositiveNumber(stake.odds) || fallbackOdds;
    payouts[stake.userId] = stake.side === winningSide ?
      Math.floor(stake.amount * odds) :
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
    const amount = normalizePositiveInteger(stake.amount);
    if (amount > 0) {
      refunds[stake.userId] = amount;
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

function oddsForSide(totalPool, sideTotal) {
  if (totalPool <= 0) {
    return 2;
  }

  const virtualSidePool = Math.max(totalPool, 100);
  const virtualTotalPool = virtualSidePool * 2;
  const odds = (totalPool + virtualTotalPool) / (sideTotal + virtualSidePool);
  return Math.min(5, Math.max(1.1, odds));
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

function currentLeaderboardPeriodId(windowWeeks = 1, date = new Date()) {
  const normalizedWindowWeeks = Number.isInteger(windowWeeks) && windowWeeks > 0 ?
    windowWeeks :
    1;
  const parts = isoWeekParts(date);
  if (normalizedWindowWeeks === 1) {
    return parts.periodId;
  }

  const windowIndex = Math.floor((parts.week - 1) / normalizedWindowWeeks) + 1;
  return `${parts.year}-W${String(windowIndex).padStart(2, "0")}x${normalizedWindowWeeks}`;
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
  oddsForSide,
  refundsForStakes,
  settlementForStakes,
  weeklyTokensEarnedUpdate,
};
