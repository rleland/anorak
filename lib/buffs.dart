library buffs;

import "package:anorak/common.dart";
import "package:anorak/messages.dart";

abstract class Buff {
  DateTime _start_time;
  String _name;
  Stats _stats;

  Buff(DateTime this._start_time);

  int get duration_ms;
  String get id;
  bool get stacks => false;
  bool get periodic => false;

  void attach(Stats stats, String name) {
    _name = name;
    _stats = stats;
  }
  void detach();

  bool active(DateTime now) {
    return now.millisecondsSinceEpoch - _start_time.millisecondsSinceEpoch <= duration_ms;
  }

  void update(Buff buff) {
    // Refresh start time, individual buffs may also want to do other things like update buff
    // strength.
    _start_time = buff._start_time;
  }
}

class BuffContainer {
  final Map<String, List<Buff>> _buffs = {};

  void add(Buff buff, Stats stats, String name) {
    if (!buff.stacks && _buffs.containsKey(buff.id)) {
      // If it doesn't stack update the buff if it exists. This is necessary to avoid
      // multiple applications of the buff overcoming the internal rate limit.
      assert(_buffs[buff.id].length == 1);
      _buffs[buff.id][0].update(buff);
      return;
    } else if (!_buffs.containsKey(buff.id)) {
      _buffs[buff.id] = [];
    }
    _buffs[buff.id].add(buff);
    buff.attach(stats,  name);
  }

  void process(MessageLog log, DateTime now) {
    var empty_keys = new Set<String>();
    for (String key in _buffs.keys) {
      List<Buff> buffs = _buffs[key];
      buffs.forEach((e) {
        if (!e.active(now)) e.detach();
        else if (e.periodic) (e as PeriodicBuff).apply(now);
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

  void apply(DateTime now) {
    if (_apply_rate.checkRate(now)) {
      _internalApply(now);
    }
  }

  void detach() {}

  void _internalApply(DateTime now);
}

class BurnBuff extends PeriodicBuff {
  static const BURN_PERIOD_MS = 1000;
  static const DURATION_MS = 2000;

  final MessageLog _log;
  int _damage;

  String get id => 'burn';
  int get duration_ms => DURATION_MS;

  BurnBuff(MessageLog this._log, DateTime start_time, int this._damage)
      : super(start_time, BURN_PERIOD_MS) {
  }

  void attach(Stats stats, String name) {
    super.attach(stats, name);
    _log.write(Messages.BurnAppliedPassive(_name));
  }

  void _internalApply(DateTime now) {
    _log.write(Messages.BurnBuff(_name, _damage));
    _stats.hp -= _damage;
  }

  void update(Buff buff) {
    assert(buff.id == id);
    _damage = (buff as BurnBuff)._damage;
    super.update(buff);
  }
}