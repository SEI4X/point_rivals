final class XpProgression {
  const XpProgression();

  static const int maxLevel = 100;

  int levelForXp(int xp) {
    if (xp <= 0) {
      return 1;
    }

    var remainingXp = xp;
    for (var level = 1; level < maxLevel; level += 1) {
      final int requirement = xpRequiredForNextLevel(level);
      if (remainingXp < requirement) {
        return level;
      }
      remainingXp -= requirement;
    }

    return maxLevel;
  }

  int xpRequiredForNextLevel(int currentLevel) {
    if (currentLevel >= maxLevel) {
      return 0;
    }

    return 15 + ((currentLevel - 1) * 15);
  }

  int xpIntoCurrentLevel(int xp) {
    final int level = levelForXp(xp);
    var remainingXp = xp;
    for (var current = 1; current < level; current += 1) {
      remainingXp -= xpRequiredForNextLevel(current);
    }

    return remainingXp.clamp(0, xpRequiredForNextLevel(level));
  }

  double progressToNextLevel(int xp) {
    final int level = levelForXp(xp);
    if (level >= maxLevel) {
      return 1;
    }

    return xpIntoCurrentLevel(xp) / xpRequiredForNextLevel(level);
  }

  int xpForWagerResult({required bool won}) => won ? 35 : 15;
}
