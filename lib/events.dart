library events;

import 'package:anorak/buffs.dart';
import 'package:anorak/common.dart';
import 'package:anorak/mob.dart';

abstract class MobEvent extends Event {
  void process(DateTime now, Mob mob);

  @override int get type => Event.TYPE_MOB;
}

class BuffEvent extends MobEvent {
  final Function _generator;

  BuffEvent(Buff this._generator(DateTime now));

  @override
  void process(DateTime now, Mob mob) {
    mob.addBuff(_generator(now));
  }
}