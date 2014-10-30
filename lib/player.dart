library player;

import 'package:anorak/mob.dart';
import 'package:anorak/common.dart';
import 'package:anorak/tile.dart';

class Player implements Mob {
  static final int MOVE_PERIOD_MS = 200;

  final Tile _tile = new PlayerTile();
  Pos _pos = new Pos(10, 10);
  int _last_move = 0;
  Stats _stats;

  Tile get tile => _tile;
  Pos get pos => _pos;
  Stats get stats => _stats;

  Player(Stats this._stats);

  bool shouldMove(DateTime now) {
    int now_ms = now.millisecondsSinceEpoch;
    if (now_ms >= _last_move + MOVE_PERIOD_MS) {
      _last_move = now_ms;
      return true;
    }
    return false;
  }

  // TODO: Implemented only to fit mob interface. This is not ideal; maybe npcs should have
  // their own mob subclass.
  Pos getMove(DateTime now, GameState gameState) {
    return null;
  }

  void move(Pos new_pos) {
    _pos = new_pos;
  }
}