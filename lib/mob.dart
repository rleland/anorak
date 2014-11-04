library mob;

import "package:anorak/common.dart";
import "package:anorak/tile.dart";

class Stats {
  int hp;
  int str;
  int dex;
  int vit;
  int get max_hp => vit * 10;

  Stats({int this.str, int this.dex, int this.vit}) {
    hp = max_hp;
  }
}

abstract class Mob {
  String get name;
  Tile get tile;
  Pos get pos;
  Stats get stats;

  bool get attackable;
  bool get is_alive;

  Pos getMove(DateTime now, GameState game_state);
  void move(Pos pos);
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

class Rat implements Mob {
  static final int MOVE_PERIOD_MS = 200;
  static final int ROW_AGGRO = 5;
  static final int COL_AGGRO = 5;
  static final int SPEED = 1;

  final Tile _tile = new RatTile();
  Pos _pos;
  int _last_move = 0;
  Stats _stats;

  Rat(Pos this._pos, Stats this._stats);

  String get name => 'rat';
  Tile get tile => _tile;
  Pos get pos => _pos;
  Stats get stats => _stats;
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
    int now_ms = now.millisecondsSinceEpoch;
    if (now_ms >= _last_move + MOVE_PERIOD_MS) {
      _last_move = now_ms;
      return true;
    }
    return false;
  }

  void move(Pos new_pos) {
    _pos = new_pos;
  }
}