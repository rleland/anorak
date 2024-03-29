library mob;

import "package:anorak/common.dart";
import "package:anorak/buffs.dart";
import "package:anorak/path_finding.dart";
import "package:anorak/tile.dart";


abstract class Skill {
  // True if it can only be activated on yourself and thus is not targeted or ranged.
  bool get self_skill;
  // False if it can only target adjacent (non-diagonal) enemies.
  bool get ranged;
  // True if the skill can be activated.
  bool ready(DateTime now);
}

abstract class AttackSkill extends Skill {
  // By defintiion you only attack your enemies, not yourself.
  @override bool get self_skill => false;
}

class BasicAttack extends AttackSkill {
  static const BASIC_ATTACK_RATE_MS = 1000;

  final _rate = new RateLimiter(BASIC_ATTACK_RATE_MS);

  @override bool get ranged => false;
  @override bool ready(DateTime now) => _rate.checkRate(now, peek: true);
}

abstract class Mob {
  final _buffs = new BuffContainer();
  Pos _pos;

  String get name;
  Tile get tile;
  Stats get stats;
  bool get attackable;
  Pos get pos => _pos;

  bool get is_alive => stats.hp > 0;

  Mob(Pos this._pos);

  void move(Pos pos) {
    _pos = pos;
  }

  void addBuff(Buff buff) {
    _buffs.add(buff, stats, name);
  }

  void checkBuffs(MessageLog log, DateTime now) {
    _buffs.process(log, now);
  }
}

abstract class Npc extends Mob {
  final RateLimiter _move_rate;

  @override bool get attackable => true;
  int get xp_reward;

  Npc(Pos pos, int move_period) : super(pos), _move_rate = new RateLimiter(move_period);

  Pos getMove(DateTime now, GameState game_state) {
    if (!shouldMove(now, game_state)) {
      return null;
    }
    return calculateMove(game_state);
  }

  bool shouldMove(DateTime now, GameState game_state) =>
      hasAggro(game_state) && _move_rate.checkRate(now);

  bool shouldAttack(DateTime now, GameState game_state) =>
      hasAggro(game_state) && hasViableAttack(now, game_state);

  Pos calculateMove(GameState game_state);
  bool hasAggro(GameState game_state);
  bool hasViableAttack(DateTime now, GameState game_state);
}

class Rat extends Npc {
  static const MOVE_PERIOD_MS = 200;
  static const ROW_AGGRO = 5;
  static const COL_AGGRO = 5;

  final _tile = new RatTile();
  final Stats _stats;

  Rat(Pos pos, Stats this._stats) : super(pos, MOVE_PERIOD_MS);

  @override String get name => 'rat';
  @override Tile get tile => _tile;
  @override Stats get stats => _stats;
  @override int get xp_reward => 5;
  @override bool get attackable => true;

  @override
  Pos calculateMove(GameState game_state) => _pos + moveCloser(_pos, game_state.player_pos);
  @override
  bool hasAggro(GameState game_state) => inRange(_pos, game_state.player_pos, ROW_AGGRO, COL_AGGRO);
  @override
  bool hasViableAttack(DateTime now, GameState game_state) => true;
}