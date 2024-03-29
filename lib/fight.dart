library fight;

import "dart:math";
import "package:anorak/common.dart";
import "package:anorak/messages.dart";
import "package:anorak/mob.dart";

const HIT_DICE = 12;
const HIT_SUCCESS = 6;

final _random = new Random();

bool isHit(Stats attacker, Stats defender) {
  int bias = attacker.dex - defender.dex;
  int roll = _random.nextInt(HIT_DICE);
  return roll + bias > HIT_SUCCESS;
}

void Attack(Mob attacker, Mob defender, MessageLog log) {
  if (!isHit(attacker.stats, defender.stats)) {
    log.write(Messages.AttackMiss(attacker.name, defender.name));
    return;
  }
  defender.stats.hp -= 2;
  log.write(Messages.Damage(attacker.name, defender.name, 2));
}