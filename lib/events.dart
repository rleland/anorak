library events;

import 'package:anorak/buffs.dart';
import 'package:anorak/common.dart';
import 'package:anorak/mob.dart';

abstract class MobEvent extends Event {
  void process(DateTime now, MessageLog log, Mob mob);

  int get type => Event.TYPE_MOB;
}

// TODO: Make more generic.
class BuffEvent extends MobEvent {
  void process(DateTime now, MessageLog log, Mob mob) {
    mob.addBuff(log, now, new BurnBuff(mob.name, now, 2));
  }
}