library mob;

import "package:anorak/common.dart";
import "package:anorak/buffs.dart";
import "package:anorak/tile.dart";


// TODO: This clearly needs sublcasses to distinguish types of mobs
// (currently; player and creature).
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

  Npc(Pos pos) : super(pos);

  Pos getMove(DateTime now, GameState game_state);
}

int capMagnitude(int value, int magnitude) {
  if (value == 0)
    return 0;
  return (magnitude * value / value.abs()).truncate();
}

// TODO: Create path finding library.
// Naive pathfinding.
Pos moveCloser(Pos from, Pos to, int speed) {
  Pos delta = to - from;
  if (delta.row.abs() >= delta.col.abs()) {
    return new Pos(capMagnitude(delta.row, speed), 0);
  } else {
    return new Pos(0, capMagnitude(delta.col, speed));
  }
}

class Rat extends Npc {
  static const int MOVE_PERIOD_MS = 200;
  static const int ROW_AGGRO = 5;
  static const int COL_AGGRO = 5;
  static const int SPEED = 1;

  final Tile _tile = new RatTile();
  final RateLimiter move_rate_ = new RateLimiter(MOVE_PERIOD_MS);
  Stats _stats;

  Rat(Pos pos, Stats this._stats) : super(pos);

  String get name => 'rat';
  Tile get tile => _tile;
  Stats get stats => _stats;
  int get xp_reward => 5;
  bool get attackable => true;

  Pos getMove(DateTime now, GameState game_state) {
    if (!shouldMove(now, game_state)) {
      return null;
    }
    return _pos + moveCloser(_pos, game_state.player_pos, SPEED);
  }

  bool shouldMove(DateTime now, GameState game_state) {
    Pos player_pos = game_state.player_pos;
    if ((player_pos.row - _pos.row).abs() > ROW_AGGRO ||
        (player_pos.col - _pos.col).abs() > COL_AGGRO) {
      return false;
    }
    return move_rate_.checkRate(now);
  }
}