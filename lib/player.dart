library player;

import 'package:anorak/common.dart';
import 'package:anorak/tile.dart';

class Player {
  static final int MOVE_PERIOD_MS = 200;

  final Tile tile = new PlayerTile();
  Pos pos = new Pos(10, 10);
  int _last_move = 0;
  Tile _tile = new PlayerTile();

  bool shouldMove(DateTime now) {
    int now_ms = now.millisecondsSinceEpoch;
    if (now_ms >= _last_move + MOVE_PERIOD_MS) {
      _last_move = now_ms;
      return true;
    }
    return false;
  }
}