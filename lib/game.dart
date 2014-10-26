library game;

import 'dart:async';

import 'package:anorak/common.dart';
import 'package:anorak/input.dart';
import 'package:anorak/level.dart';
import 'package:anorak/player.dart';

class Game {
  final Level _level;
  final KeyboardListener _kl;
  final Player _player = new Player();
  //final FpsCounter _fps_counter;
  InputHandler _input_handler;
  bool _need_redraw = true;  // Force first draw.

  Game(this._kl, this._level) {//: _fps_counter = new FpsCounter(querySelector('#fps')) {
    this._input_handler = new InputHandler();
  }

  void start() {
    // TODO: Move game loop out of here.
    new Timer.periodic(new Duration(milliseconds: 50), this._gameLoop);
  }

  void _gameLoop(Timer timer) {
    DateTime now = new DateTime.now();
    //_fps_counter.update(now);

    while (_kl.hasKeysToProcess(now)) {
      Key key = _kl.consumeKeyFromQueue();
      if (_input_handler.IsDirectionKey(key)) {
        _updatePlayer(now, key);
      }
    }
    _redraw();
  }

  void _redraw() {
    if (!_need_redraw) {
      // Don't waste resources.
      return;
    }
    _level.clearCharacterLayer();
    _level.addCharacterTile(_player.tile, _player.pos);
    //redraw(_level);  // TODO: No redrawing is actually happening now :(
    _need_redraw = false;
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