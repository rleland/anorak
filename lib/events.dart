library events;

import 'package:anorak/mob.dart';

abstract class Event {
  static const int TYPE_MOB = 1;

  int get event_type;
}

abstract class MobEvent extends Event {
  void Process(Mob mob);

  int get event_type => Event.TYPE_MOB;
}

class Damage extends MobEvent {
  final int _damage;

  Damage(int this._damage);

  void Process(Mob mob) {
    mob.stats.hp -= _damage;
  }
}