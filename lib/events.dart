library events;

import 'package:anorak/common.dart';
import 'package:anorak/messages.dart';
import 'package:anorak/mob.dart';

abstract class MobEvent extends Event {
  void process(MessageLog log, Mob mob);

  int get type => Event.TYPE_MOB;
}

// TODO: Instead of this, have event apply damage (burn) debuff.
class DamageEvent extends MobEvent {
  final String _name;
  final int _damage;

  DamageEvent(String this._name, int this._damage);

  void process(MessageLog log, Mob mob) {
    mob.stats.hp -= _damage;
    log.write(Messages.Damage(_name, mob.name, _damage));
  }
}