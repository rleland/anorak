library messages;

class Messages {
  static String Damage(String attacker, String defender, int damage) =>
      "$attacker hits $defender for $damage.";
  static String AttackMiss(String attacker, String defender) => "$attacker misses $defender.";
  static String Dead(String name) => "$name was killed.";
  static String LevelUp(String name, int level) => "$name levels up to level $level!";
  static String BurnAppliedPassive(String name) => "$name caught fire.";
  static String BurnBuff(String name, int damage) => "$name was burned for $damage damage.";
}