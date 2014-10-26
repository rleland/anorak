import 'dart:collection';
import 'dart:html';
import 'dart:async';
import 'package:anorak/input.dart';
import 'package:anorak/level.dart';
import 'package:anorak/tile.dart';
import 'rendering.dart';

class Player {
  // TODO: One problems. Doesn't react quickly enough to keypress.
  // Especially bad if keydown and keyup happens between loops checking kbd input.
  // I think keypresses need to be processed somehow, and I have to build a better model of
  // keypresses + key repetitions.
  static final int MOVE_PERIOD_MS = 200;

  final Tile tile = new PlayerTile();
  Pos pos = new Pos(10, 10);
  int _last_move = 0;
  Tile _tile = new PlayerTile();

  bool shouldMove(DateTime now) {
    int now_ms = now.millisecondsSinceEpoch;
    if (now_ms > _last_move + MOVE_PERIOD_MS) {
      _last_move = now_ms;
      return true;
    }
    return false;
  }
}

class FpsCounter {
  static final int WINDOW = 5;
  final Element _element;
  final Queue<int> _frames = new Queue<int>();

  FpsCounter(Element this._element) {
  }

  void update(DateTime time) {
    int now_ms = time.millisecondsSinceEpoch;
    int cutoff = now_ms - WINDOW * 1000;
    while (_frames.isNotEmpty && _frames.first < cutoff) {
      _frames.removeFirst();
    }
    _frames.add(now_ms);
    _redraw(_frames.length / WINDOW);
  }

  void _redraw(double fps) {
    clearElement(_element);
    _element.appendText("$fps");
  }
}

class Game {
  final Level _level;
  final KeyboardListener _kl;
  final Player _player = new Player();
  final FpsCounter _fps_counter;
  InputHandler _input_handler;
  bool _need_redraw = true;  // Force first draw.

  Game(this._kl, this._level) : _fps_counter = new FpsCounter(querySelector('#fps')) {
    this._input_handler = new InputHandler();
  }

  void start() {
    new Timer.periodic(new Duration(milliseconds: 50), this._gameLoop);
  }

  void _gameLoop(Timer timer) {
    DateTime now = new DateTime.now();
    _fps_counter.update(now);

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
    redraw(_level);
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

void main() {
  Level level = new Level(20, 20);
  level.multiAddBaseTile(new Grass(), new Pos(0, 0), new Pos(20, 20));
  level.multiAddBaseTile(new Tree(), new Pos(0, 0), new Pos(1, 20));
  level.multiAddBaseTile(new Tree(), new Pos(0, 0), new Pos(20, 1));
  level.multiAddBaseTile(new Tree(), new Pos(0, 19), new Pos(20, 20));
  level.multiAddBaseTile(new Tree(), new Pos(19, 0), new Pos(20, 20));
  level.multiAddBaseTile(new Path(), new Pos(0,  10), new Pos(20, 11));
  KeyboardListener kl = new KeyboardListener();
  kl.listen(window);

  Game game = new Game(kl, level);
  game.start();
}
