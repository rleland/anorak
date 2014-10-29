library game;

import 'package:anorak/character.dart';
import 'package:anorak/common.dart';
import 'package:anorak/input.dart';
import 'package:anorak/level.dart';
import 'package:anorak/player.dart';

class Game implements GameState {
  static final Map<Key, Pos> MOVES =
    {Key.UP: Pos.MOVE_UP,
     Key.DOWN: Pos.MOVE_DOWN,
     Key.LEFT: Pos.MOVE_LEFT,
     Key.RIGHT: Pos.MOVE_RIGHT};

  final Level _level;
  final KeyboardListener _kl;
  final Player _player = new Player();
  final InputHandler _input_handler;
  bool _need_redraw = true;  // Force first draw.
  final List<Character> _characters = new List<Character>();

  Level get level => _level;

  Game(this._kl, this._level) : _input_handler = new InputHandler() {
    _level.addCharacterTile(_player.tile, _player.pos);
  }

  Pos get player_pos => _player.pos;

  bool isPassable(Pos pos) {
    return _level.isPassable(pos);
  }

  void addCharacter(Character c) {
    _characters.add(c);
    _level.addCharacterTile(c.tile, c.pos);
  }

  bool loop(DateTime now) {
    while (_kl.hasKeysToProcess(now)) {
      Key key = _kl.consumeKeyFromQueue();
      if (_input_handler.IsDirectionKey(key)) {
        _updatePlayer(now, key);
      }
    }
    for (Character c in _characters) {
      Pos new_pos = c.getMove(now, this);
      if (new_pos != null &&
          _level.isPassable(new_pos)) {
        _need_redraw = true;
        _level.moveCharacterTile(c.pos, new_pos);
        c.move(new_pos);
      }
    }
    // Don't waste resources unnecessarily.
    if (_need_redraw) {
      _need_redraw = false;
      return true;
    } else {
      return false;
    }
  }

  void _updatePlayer(DateTime now, Key key) {
    if (!_player.shouldMove(now)) {
      return;
    }
    assert(MOVES.containsKey(key));
    _movePlayer(MOVES[key]);
  }

  void _movePlayer(Pos pos_offset) {
    Pos new_pos = _player.pos + pos_offset;
    if (_level.isPassable(new_pos)) {
      _level.moveCharacterTile(_player.pos, new_pos);
      _player.move(new_pos);
      _need_redraw = true;
    }
    // TODO: Interact with new tile regardless of whether it's passable.
  }
}