library game;

import 'package:anorak/common.dart';
import 'package:anorak/input.dart';
import 'package:anorak/level.dart';
import 'package:anorak/player.dart';

class Game {
  final Level _level;
  final KeyboardListener _kl;
  final Player _player = new Player();
  final InputHandler _input_handler;
  bool _need_redraw = true;  // Force first draw.

  Level get level => _level;

  Game(this._kl, this._level) : _input_handler = new InputHandler();

  bool loop(DateTime now) {
    while (_kl.hasKeysToProcess(now)) {
      Key key = _kl.consumeKeyFromQueue();
      if (_input_handler.IsDirectionKey(key)) {
        _updatePlayer(now, key);
      }
    }
    // Don't waste resources unnecessarily.
    if (_need_redraw) {
      _redraw();
      _need_redraw = false;
      return true;
    } else {
      return false;
    }
  }

  void _redraw() {
    _level.clearCharacterLayer();
    _level.addCharacterTile(_player.tile, _player.pos);
  }

  void _updatePlayer(DateTime now, Key key) {
    if (!_player.shouldMove(now)) {
      return;
    }
    if (key == Key.UP) {
      _movePlayer(new Pos(-1, 0));
    } else if (key == Key.RIGHT) {
      _movePlayer(new Pos(0, 1));
    } else if (key == Key.DOWN) {
      _movePlayer(new Pos(1, 0));
    } else if (key == Key.LEFT){
      _movePlayer(new Pos(0, -1));
    } else {
      assert(false);  // Invalid direction.
    }
  }

  void _movePlayer(Pos pos_offset) {
    _need_redraw = true;
    Pos new_pos = _player.pos + pos_offset;
    if (_level.isPassable(new_pos)) {
      _player.pos = new_pos;
    }
    // TODO: Interact with new tile regardless of whether it's passable.
  }
}