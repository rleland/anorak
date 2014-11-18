library mob;

import "package:anorak/common.dart";
import "package:anorak/buffs.dart";
import "package:anorak/path_finding.dart";
import "package:anorak/tile.dart";


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

  bool get attackable => true;
  int get xp_reward;

  Npc(Pos pos, int move_period) : super(pos), _move_rate = new RateLimiter(move_period);

  Pos getMove(DateTime now, GameState game_state) {
    if (!shouldMove(now, game_state)) {
      return null;
    }
    return calculateMove(game_state);
  }


  bool shouldMove(DateTime now, GameState game_state) {
    return hasAggro(game_state) && _move_rate.checkRate(now);
  }

  Pos calculateMove(GameState game_state);
  bool hasAggro(GameState game_state);
}

class Rat extends Npc {
  static const MOVE_PERIOD_MS = 200;
  static const ROW_AGGRO = 5;
  static const COL_AGGRO = 5;

  final _tile = new RatTile();
  final Stats _stats;

  Rat(Pos pos, Stats this._stats) : super(pos, MOVE_PERIOD_MS);

  String get name => 'rat';
  Tile get tile => _tile;
  Stats get stats => _stats;
  int get xp_reward => 5;
  bool get attackable => true;

  Pos calculateMove(GameState game_state) {
    return _pos + moveCloser(_pos, game_state.player_pos);
  }

  bool hasAggro(GameState game_state) {
    return inRange(_pos, game_state.player_pos, ROW_AGGRO, COL_AGGRO);
  }
}