library mob;

import "package:anorak/common.dart";
import "package:anorak/buffs.dart";
import "package:anorak/tile.dart";


// TODO: This clearly needs sublcasses to distinguish types of mobs
// (currently; player and creature).
abstract class Mob {
  String get name;
  Tile get tile;
  Pos get pos;
  Stats get stats;
  int get xp_reward;

  bool get attackable;
  bool get is_alive;

  final BuffContainer _buffs = new BuffContainer();

  Pos getMove(DateTime now, GameState game_state);
  void move(Pos pos);

  void addBuff(DateTime now, Buff buff) {
    _buffs.add(now, buff, stats);
  }

  void checkBuffs(DateTime now) {
    _buffs.process(now, stats);
  }
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

class Rat extends Mob {
  static const int MOVE_PERIOD_MS = 200;
  static const int ROW_AGGRO = 5;
  static const int COL_AGGRO = 5;
  static const int SPEED = 1;

  final Tile _tile = new RatTile();
  Pos _pos;
  final RateLimiter move_rate_ = new RateLimiter(MOVE_PERIOD_MS);
  Stats _stats;

  Rat(Pos this._pos, Stats this._stats);

  String get name => 'rat';
  Tile get tile => _tile;
  Pos get pos => _pos;
  Stats get stats => _stats;
  int get xp_reward => 5;
  bool get attackable => true;
  bool get is_alive => stats.hp > 0;

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

  void move(Pos new_pos) {
    _pos = new_pos;
  }
}