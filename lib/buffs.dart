library buffs;

import "package:anorak/common.dart";
import "package:anorak/messages.dart";

abstract class Buff {
  DateTime _start_time;

  Buff(DateTime this._start_time);

  int get duration_ms;
  String get id;
  bool get stacks => false;
  bool get periodic => false;

  bool active(DateTime now) {
    return now.millisecondsSinceEpoch - _start_time.millisecondsSinceEpoch <= duration_ms;
  }

  void update(Buff buff) {
    // Refresh start time, individual buffs may also want to do other things like update buff
    // strength.
    _start_time = buff._start_time;
  }

  void apply(MessageLog log, DateTime now, Stats stats);
  void unApply(Stats stats);
}

class BuffContainer {
  final Map<String, List<Buff>> _buffs = new Map<String, List<Buff>>();

  void add(Buff buff, Stats stats) {
    if (!buff.stacks && _buffs.containsKey(buff.id)) {
      // If it doesn't stack update the buff if it exists. This is necessary to avoid
      // multiple applications of the buff overcoming the internal rate limit.
      assert(_buffs[buff.id].length == 1);
      _buffs[buff.id][0].update(buff);
      return;
    } else if (!_buffs.containsKey(buff.id)) {
      _buffs[buff.id] = new List<Buff>();
    }
    _buffs[buff.id].add(buff);
  }

  void process(MessageLog log, DateTime now, Stats stats) {
    Set<String> empty_keys = new Set<String>();
    for (String key in _buffs.keys) {
      List<Buff> buffs = _buffs[key];
      buffs.forEach((e) {
        if (!e.active(now)) e.unApply(stats);
        else e.apply(log, now, stats);
      });
      buffs.removeWhere((e) => !e.active(now));
      if (buffs.isEmpty) empty_keys.add(key);
    }
    empty_keys.forEach((e) => _buffs.remove(e));
  }
}

abstract class PeriodicBuff extends Buff {
  final RateLimiter _apply_rate;

  bool get periodic => true;

  PeriodicBuff(DateTime start_time, int period_ms) :
    super(start_time), _apply_rate = new RateLimiter(period_ms);

  void apply(MessageLog log, DateTime now, Stats stats) {
    if (_apply_rate.checkRate(now)) {
      _internalApply(log, now, stats);
    }
  }

  void unApply(Stats stats) {
  }

  void _internalApply(MessageLog log, DateTime now, Stats stats);
}

class BurnBuff extends PeriodicBuff {
  static const int BURN_PERIOD_MS = 1000;
  final String _name;
  int _damage;

  int get duration_ms => 2000;
  String get id => 'burn';

  BurnBuff(String this._name, DateTime start_time, int this._damage)
      : super(start_time, BURN_PERIOD_MS);

  void _internalApply(MessageLog log, DateTime now, Stats stats) {
    log.write(Messages.BurnBuff(_name, _damage));
    stats.hp -= _damage;
  }

  void update(Buff buff) {
    _damage = (buff as BurnBuff)._damage;
    super.update(buff);
  }
}