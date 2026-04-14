"use strict";

const assert = require("node:assert/strict");
const test = require("node:test");
const {
  currentIsoWeekPeriodId,
  refundsForStakes,
  settlementForStakes,
  weeklyTokensEarnedUpdate,
} = require("../lib/wager_logic");

test("settlementForStakes pays winners with bounded odds", () => {
  const result = settlementForStakes([
    {userId: "a", side: "left", amount: 100},
    {userId: "b", side: "right", amount: 300},
  ], "left");

  assert.equal(result.totalPool, 400);
  assert.equal(result.winningSideTotal, 100);
  assert.deepEqual(result.payouts, {a: 240, b: 0});
});

test("settlementForStakes reduces a crowded single-sided pool", () => {
  const result = settlementForStakes([
    {userId: "a", side: "left", amount: 100},
  ], "left");

  assert.equal(result.totalPool, 100);
  assert.equal(result.winningSideTotal, 100);
  assert.deepEqual(result.payouts, {a: 150});
});

test("settlementForStakes uses locked stake odds when present", () => {
  const result = settlementForStakes([
    {userId: "a", side: "left", amount: 100, odds: 2},
  ], "left");

  assert.equal(result.totalPool, 100);
  assert.equal(result.winningSideTotal, 100);
  assert.deepEqual(result.payouts, {a: 200});
});

test("refundsForStakes returns only positive integer stakes", () => {
  const result = refundsForStakes([
    {userId: "a", amount: 50},
    {userId: "b", amount: 0},
    {userId: "c", amount: 12.5},
  ]);

  assert.deepEqual(result, {a: 50});
});

test("weeklyTokensEarnedUpdate increments inside current period", () => {
  const result = weeklyTokensEarnedUpdate({
    member: {weeklyScorePeriodId: "2026-W16"},
    currentWeeklyPeriodId: "2026-W16",
    payout: 40,
    increment: (value) => ({increment: value}),
  });

  assert.deepEqual(result, {increment: 40});
});

test("weeklyTokensEarnedUpdate resets stale period", () => {
  const result = weeklyTokensEarnedUpdate({
    member: {weeklyScorePeriodId: "2026-W15"},
    currentWeeklyPeriodId: "2026-W16",
    payout: 40,
    increment: (value) => ({increment: value}),
  });

  assert.equal(result, 40);
});

test("currentIsoWeekPeriodId follows ISO week-year boundaries", () => {
  assert.equal(
    currentIsoWeekPeriodId(new Date(Date.UTC(2026, 0, 1))),
    "2026-W01",
  );
  assert.equal(
    currentIsoWeekPeriodId(new Date(Date.UTC(2027, 0, 1))),
    "2026-W53",
  );
});
