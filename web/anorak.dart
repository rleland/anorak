import 'dart:collection';
import 'dart:html';
import 'dart:async';
import 'rendering.dart';

class Pos {
  final int row;
  final int col;

  Pos(this.row, this.col) {
  }

  Pos operator+(Pos other) {
    return new Pos(this.row + other.row, this.col + other.col);
  }
}

abstract class Tile {
  String get explanation;  // Explains what the symbol means.
  String get symbol;  // Symbol used to render the tile.
  String get color;  // Color of the symbol.
  bool get passable => true;  // True if player can move onto tile.
  bool get has_event => false;  // True if interacting with the tile results in event.
  bool get bold => false;  // Rendered in bold if true (typically PC and NPCs).
}

class Grass extends Tile {
  String get explanation => 'grass';
  String get symbol =>'.';
  String get color => 'lightgreen';  // TODO: Pick right shade of green.
}

class Tree extends Tile {
  String get explanation => 'tree';
  String get symbol => '#';
  String get color => 'green';
  bool get passable => false;
}

class Path extends Tile {
  String get explanation => 'path';
  String get symbol => '#';
  String get color => 'brown';
}

class PlayerTile extends Tile {
  String get explanation => 'you';
  String get symbol => '@';
  String get color => 'black';
  bool get passable => false;
  bool get bold => true;
}

class TileMap {
  List<Tile> _tiles;
  final int _rows;
  final int _cols;

  TileMap(int this._rows, int this._cols) {
    _tiles = new List<Tile>(_rows * _cols);
    for (int row = 0; row < _rows; ++row) {
      for (int col = 0; col < _cols; ++col) {
        addTile(null, new Pos(row, col));
      }
    }
  }

  // row and col starts at 0
  bool hasTile(Pos pos) {
    return tileAt(pos) != null;
  }

  Tile tileAt(Pos pos) {
    assert(pos.row < _rows && pos.col < _cols);
    return _tiles[pos.row * _cols + pos.col];
  }

  void addTile(Tile tile, Pos pos) {
    _tiles[pos.row * _cols + pos.col] = tile;
  }

  void clearTile(Pos pos) {
    _tiles[pos.row * _cols + pos.col] = null;
  }
}

class Level {  // Better name, e.g. zone, scene, map, area, etc
  static final int BASE_LAYER = 0;
  static final int MOVABLE_LAYER = 1; // TODO: Better name?
  static final int CHARACTER_LAYER = 2;
  static final int NUM_LAYERS = 3;

  List<TileMap> _layers;
  final int _rows;
  final int _cols;

  Level(int this._rows, int this._cols) {
    _layers = new List<TileMap>();
    for (int i = 0; i < NUM_LAYERS; ++i) {
      _layers.add(new TileMap(_rows, _cols));
    }
  }

  Element render() {
    Element outer = new Element.div();
    outer.style.setProperty('font-family', 'monospace');
    List<String> tiles = new List<String>(_rows * _cols);
    for (int row = 0; row < _rows; ++row) {
      for (int col = 0; col < _cols; ++col) {
        for (int i = _layers.length-1; i >= 0; --i) {
          Pos pos = new Pos(row, col);
          if (!_layers[i].hasTile(pos)) {
            continue;
          }
          outer.append(renderTile(_layers[i].tileAt(pos)));
          break;  // Only append one per row,col.
        }
      }
      outer.append(new Element.br());
    }
    return outer;
  }

  void addBaseTile(Tile tile, Pos pos) {
    _layers[BASE_LAYER].addTile(tile, pos);
  }

  void multiAddBaseTile(Tile tile, Pos start_pos, Pos end_pos) {
    for (int row = start_pos.row; row < end_pos.row; ++row) {
      for (int col = start_pos.col; col < end_pos.col; ++col) {
        addBaseTile(tile, new Pos(row, col));
      }
    }
  }

  void clearCharacterLayer() {
    for (int row = 0; row < _rows; ++row) {
      for (int col = 0; col < _cols; ++col) {
        _layers[CHARACTER_LAYER].clearTile(new Pos(row, col));
      }
    }
  }

  void addCharacterTile(Tile tile, Pos pos) {
    _layers[CHARACTER_LAYER].addTile(tile, pos);
  }

  bool isPassable(Pos pos) {
    if (pos.row >= _rows || pos.row < 0 || pos.col >= _cols || pos.col < 0) {
      return false;
    }
    for (int i = 0; i < _layers.length; ++i) {
      Tile tile = _layers[i].tileAt(pos);
      if (tile != null && !tile.passable) {
        return false;
      }
    }
    return true;
  }
}

class Key {
  static const Key DOWN = const Key(40);
  static const Key UP = const Key(38);
  static const Key LEFT = const Key(37);
  static const Key RIGHT = const Key(39);

  static Key get(int keyCode) {
     if (_keys.isEmpty) {
       _initKeys();
     }
     return _keys.containsKey(keyCode) ? _keys[keyCode] : null;
   }

  static final HashMap<int, Key> _keys = new HashMap<int, Key>();

  static void _initKeys() {
    for (Key k in [DOWN, UP, LEFT, RIGHT]) {
      _keys[k._code] = k;
    }
  }

  final int _code;
  const Key(int this._code);
}

class KeyboardListener {
  static final REPETITION_PERIOD_MS = 200;

  final Queue<Key> _key_queue = new Queue<Key>();
  final HashMap<Key, int> _held_keys = {};
  int _last_repetition_check_ms = 0;

  void listen(Window w) {
    w.onKeyDown.listen(_processKeyDown);
    w.onKeyUp.listen(_processKeyUp);
  }

  bool hasKeysToProcess(DateTime now) {
    _addRepeatsToQueue(now);
    return _key_queue.isNotEmpty;
  }

  Key consumeKeyFromQueue() {
    return _key_queue.removeFirst();
  }

  void _addRepeatsToQueue(DateTime now) {
    if (now.millisecondsSinceEpoch - _last_repetition_check_ms < REPETITION_PERIOD_MS ||
        _held_keys.isEmpty) {
      return;
    }
    _last_repetition_check_ms = now.millisecondsSinceEpoch;

    Key key = null;
    int max_ts = 0;
    for (Key k in _held_keys.keys) {
      if (_held_keys[k] <= max_ts) {
        continue;
      }
      max_ts = _held_keys[k];
      key = k;
    }
    assert(key != null);
    if (!_key_queue.contains(key)) {
      _key_queue.add(key);
    }
  }

  void _processKeyDown(KeyboardEvent e) {
    Key key = Key.get(e.keyCode);
    if (key == null) {
      return;
    }
    _held_keys.putIfAbsent(key, () => e.timeStamp);
    _key_queue.add(key);
  }

  void _processKeyUp(KeyboardEvent e) {
    Key key = Key.get(e.keyCode);
    if (key != null) {
      this._held_keys.remove(key);
    }
  }
}

class InputHandler {  // TODO: Rename to describe the type of inputhandler and maybe generic class?
  static final List<Key> DIRECTION_KEYS = [Key.UP, Key.DOWN, Key.RIGHT, Key.LEFT];

  bool IsDirectionKey(Key key) {
    return DIRECTION_KEYS.contains(key);
  }
}

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
    Element world = querySelector('#world');
    clearElement(world);
    world.append(_level.render());
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
