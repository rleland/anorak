library messages;

class Messages {
  static String Damage(String attacker, String defender, int damage) {
    return "$attacker hits $defender for $damage.";
  }

  static String AttackMiss(String attacker, String defender) {
    return "$attacker misses $defender.";
  }

  static String Dead(String name) {
    return "$name was killed.";
  }

  static String LevelUp(int level) {
    return "Player levels up to level $level!";
  }

  static String BurnAppliedPassive(String name) {
    return "$name caught fire.";
  }

  static String BurnBuff(String name, int damage) {
    return "$name was burned for $damage damage.";
  }
}