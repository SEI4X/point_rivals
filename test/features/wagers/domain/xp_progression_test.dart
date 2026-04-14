import 'package:flutter_test/flutter_test.dart';
import 'package:point_rivals/features/profile/domain/xp_progression.dart';

void main() {
  const progression = XpProgression();

  test('starts every user at level 1', () {
    expect(progression.levelForXp(0), 1);
  });

  test('increases each level requirement', () {
    expect(progression.xpRequiredForNextLevel(1), 15);
    expect(progression.xpRequiredForNextLevel(2), 30);
    expect(progression.xpRequiredForNextLevel(3), 45);
  });

  test('reaches level 2 after the first wager', () {
    expect(progression.levelForXp(progression.xpForWagerResult(won: false)), 2);
    expect(progression.levelForXp(progression.xpForWagerResult(won: true)), 2);
  });

  test('calculates level and current progress', () {
    expect(progression.levelForXp(245), 6);
    expect(progression.xpIntoCurrentLevel(245), 20);
    expect(progression.progressToNextLevel(245), closeTo(0.222, 0.001));
  });

  test('gives more XP for a win than a loss', () {
    expect(progression.xpForWagerResult(won: true), greaterThan(15));
    expect(progression.xpForWagerResult(won: false), 15);
  });
}
