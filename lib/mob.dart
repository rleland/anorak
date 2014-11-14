library mob;

import "package:anorak/common.dart";
import "package:anorak/buffs.dart";
import "package:anorak/tile.dart";


abstract class Mob {
  Pos _pos;

  String get name;
  Tile get tile;
  Stats get stats;
  bool get attackable;
  Pos get pos => _pos;

  bool get is_alive => stats.hp > 0;

  final BuffContainer _buffs = new BuffContainer();

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
  bool get attackable => true;
  int get xp_reward;
  final RateLimiter move_rate_;

  Npc(Pos pos, int move_period) : super(pos), move_rate_ = new RateLimiter(move_period);

  Pos getMove(DateTime now, GameState game_state) {
    if (!shouldMove(now, game_state)) {
      return null;
    }
    return calculateMove(game_state);
  }

  Pos calculateMove(GameState game_state);

  bool shouldMove(DateTime now, GameState game_state) {
    return hasAggro(game_state) && move_rate_.checkRate(now);
  }

  bool hasAggro(GameState game_state);
}

int capMagnitude(int value, int magnitude) {
  if (value == 0)
    return 0;
  return (magnitude * value / value.abs()).truncate();
}

// TODO: Create path finding library.
// Naive pathfinding.
Pos moveCloser(Pos from, Pos to) {
  Pos delta = to - from;
  if (delta.row.abs() >= delta.col.abs()) {
    return new Pos(capMagnitude(delta.row, 1), 0);
  } else {
    return new Pos(0, capMagnitude(delta.col, 1));
  }
}

class Rat extends Npc {
  static const int MOVE_PERIOD_MS = 200;
  static const int ROW_AGGRO = 5;
  static const int COL_AGGRO = 5;

  final Tile _tile = new RatTile();
  Stats _stats;

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
    Pos player_pos = game_state.player_pos;
    return (player_pos.row - _pos.row).abs() <= ROW_AGGRO ||
           (player_pos.col - _pos.col).abs() <= COL_AGGRO;
  }
}