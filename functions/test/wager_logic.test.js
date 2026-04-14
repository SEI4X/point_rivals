"use strict";

const assert = require("node:assert/strict");
const test = require("node:test");
const {
  currentLeaderboardPeriodId,
  currentIsoWeekPeriodId,
  currentScoreDateId,
  refundsForStakes,
  settlementForStakes,
  weeklyTokensEarnedUpdate,
} = require("../lib/wager_logic");

test("settlementForStakes pays the configured reward", () => {
  const result = settlementForStakes([
    {userId: "a", side: "left"},
    {userId: "b", side: "right"},
  ], "left");

  assert.equal(result.totalPool, 20);
  assert.equal(result.winningSideTotal, 1);
  assert.deepEqual(result.payouts, {a: 10, b: 0});
});

test("currentScoreDateId uses UTC date buckets", () => {
  assert.equal(
    currentScoreDateId(new Date(Date.UTC(2026, 3, 14, 23, 30))),
    "20260414",
  );
});

test("settlementForStakes pays 1.5x for unpopular correct picks", () => {
  const result = settlementForStakes([
    {userId: "a", side: "left"},
    {userId: "b", side: "left"},
    {userId: "c", side: "right"},
  ], "right", 20);

  assert.equal(result.totalPool, 60);
  assert.equal(result.winningSideTotal, 1);
  assert.deepEqual(result.payouts, {a: 0, b: 0, c: 30});
});

test("refundsForStakes keeps recipients without refunding coins", () => {
  const result = refundsForStakes([
    {userId: "a"},
    {userId: "b"},
  ]);

  assert.deepEqual(result, {a: 0, b: 0});
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

test("currentLeaderboardPeriodId uses sprint windows from anchor dates", () => {
  const anchor = new Date(Date.UTC(2026, 3, 13));
  assert.equal(
    currentLeaderboardPeriodId(2, new Date(Date.UTC(2026, 3, 14)), anchor),
    "20260413-S001x2",
  );
  assert.equal(
    currentLeaderboardPeriodId(2, new Date(Date.UTC(2026, 3, 27)), anchor),
    "20260427-S002x2",
  );
});
