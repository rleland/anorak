library messages;

class Messages {
  static String Damage(String attacker, String defender, int damage) {
    return "$attacker hits $defender for $damage";
  }

  static String AttackMiss(String attacker, String defender) {
    return "$attacker misses $defender.";
  }

  static String Dead(String name) {
    return "$name was killed.";
  }
}