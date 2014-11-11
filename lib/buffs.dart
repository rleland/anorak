library buffs;

import "package:anorak/common.dart";
import "package:anorak/mob.dart";

// TODO: Looks like I have to put these in the mob file. Or something.
abstract class Buff {
  final DateTime _start_time;

  Buff(DateTime this._start_time);

  int get duration_ms;
  String get id;
  bool get stacks => false;

  bool Active(DateTime now) {
    return now.millisecondsSinceEpoch - _start_time.millisecondsSinceEpoch > duration_ms;
  }

  void Apply(DateTime now, Mob mob);
  void UnApply(DateTime now, Mob mob);
}

abstract class PeriodicBuff extends Buff {
  final RateLimiter _apply_rate;

  PeriodicBuff(DateTime start_time, int period_ms) :
    super(start_time), _apply_rate = new RateLimiter(period_ms);

  void Apply(DateTime now, Mob mob) {
    if (_apply_rate.checkRate(now)) {
      _InternalApply(now, mob);
    }
  }

  void UnApply(DateTime now, Mob mob) {
  }

  void _InternalApply(DateTime now, Mob mob);
}

class BurnBuff extends PeriodicBuff {
  static const int BURN_PERIOD_MS = 1000;
  final int _damage;

  int get duration_ms => 2000;
  String get id => 'burn';

  BurnBuff(DateTime start_time, int this._damage) : super(start_time, BURN_PERIOD_MS);

  void _InternalApply(DateTime now, Mob mob) {

  }
}