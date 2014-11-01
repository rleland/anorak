library fight;

import "dart:math";
import "package:anorak/common.dart";
import "package:anorak/messages.dart";
import "package:anorak/mob.dart";

int HIT_DICE = 12;
int HIT_SUCCESS = 6;

Random _random = new Random();

bool isHit(Stats attacker, Stats defender) {
  int bias = attacker.dex - defender.dex;
  int roll = _random.nextInt(HIT_DICE);
  return roll + bias > HIT_SUCCESS;
}

void Attack(Mob attacker, Mob defender, MessageLog log) {
  if (!isHit(attacker.stats, defender.stats)) {
    return;
  }
  defender.stats.hp -= 2;
  log.write(Messages.Damage(attacker.name, defender.name, 2));
}