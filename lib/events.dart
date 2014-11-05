library events;

import 'package:anorak/common.dart';
import 'package:anorak/messages.dart';
import 'package:anorak/mob.dart';

abstract class Event {
  static const int TYPE_MOB = 1;

  int get event_type;
}

abstract class MobEvent extends Event {
  void Process(MessageLog log, Mob mob);

  int get event_type => Event.TYPE_MOB;
}

class Damage extends MobEvent {
  final String _name;
  final int _damage;

  Damage(String this._name, int this._damage);

  void Process(MessageLog log, Mob mob) {
    mob.stats.hp -= _damage;
    log.write(Messages.Damage(_name, mob.name, _damage));
  }
}