library buffs;

import "package:anorak/common.dart";

abstract class Buff {
  DateTime _start_time;

  Buff(DateTime this._start_time);

  int get duration_ms;
  String get id;
  bool get stacks => false;
  bool get periodic => false;

  bool active(DateTime now) {
    return now.millisecondsSinceEpoch - _start_time.millisecondsSinceEpoch > duration_ms;
  }

  void update(Buff buff) {
    // Refresh start time, individual buffs may also want to do other things like update buff
    // strength.
    _start_time = buff._start_time;
  }

  void apply(DateTime now, Stats stats);
  void unApply(Stats stats);
}

abstract class PeriodicBuff extends Buff {
  final RateLimiter _apply_rate;

  bool get periodic => true;

  PeriodicBuff(DateTime start_time, int period_ms) :
    super(start_time), _apply_rate = new RateLimiter(period_ms);

  void apply(DateTime now, Stats stats) {
    if (_apply_rate.checkRate(now)) {
      _internalApply(now, stats);
    }
  }

  void unApply(Stats stats) {
  }

  void _internalApply(DateTime now, Stats stats);
}

class BurnBuff extends PeriodicBuff {
  static const int BURN_PERIOD_MS = 1000;
  int _damage;

  int get duration_ms => 2000;
  String get id => 'burn';

  BurnBuff(DateTime start_time, int this._damage) : super(start_time, BURN_PERIOD_MS);

  void _internalApply(DateTime now, Stats stats) {
  }

  void update(Buff buff) {
    _damage = (buff as BurnBuff)._damage;
    super.update(buff);
  }
}