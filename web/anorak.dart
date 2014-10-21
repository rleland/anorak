import 'dart:collection';
import 'dart:html';
import 'dart:async';

class Pos {
  final int row;
  final int col;

  Pos(this.row, this.col) {
  }
}

abstract class Tile {
  String _explanation;  // Explains what the symbol means.
  String _symbol;  // Symbol used to render the tile.
  String _color;  // Color of the symbol.
  bool get passable => true;  // True if player can move onto tile.
  bool get has_event => false;  // True if interacting with the tile results in event.
  bool get bold => false;  // Rendered in bold if true (typically PC and NPCs).

  Element makeElement() {
    Element span = new Element.span();
    span.style.setProperty('color', _color);
    if (bold) {
      span.style.setProperty('font-weight', 'bold');
    }
    span.appendText(_symbol);
    return span;
  }
}

class NullTile extends Tile {
  String _explanation = '';
  String _symbol = ' ';
  String _color = 'white';
}

class Grass extends Tile {
  String _explanation = 'grass';
  String _symbol = '.';
  String _color = 'lightgreen';  // TODO: Pick right shade of green.
}

class Tree extends Tile {
  String _explanation = 'tree';
  String _symbol = '#';
  String _color = 'green';
}

class Path extends Tile {
  String _explanation = 'path';
  String _symbol = '#';
  String _color = 'brown';
}

class PlayerTile extends Tile {
  String _explanation = 'you';
  String _symbol = '@';
  String _color = 'black';
  bool get passable => false;
  bool get bold => true;
}

class TileMap {
  List<Tile> _tiles;
  final int _width;
  final int _height;
  
  TileMap(int this._width, int this._height) {
    _tiles = new List<Tile>(_width * _height);
    Tile null_tile = new NullTile();
    for (int row = 0; row < _height; ++row) {
      for (int col = 0; col < _width; ++col) {
        addTile(null_tile, new Pos(row, col));
      }
    }
  }
  
  // row and col starts at 0
  bool hasTile(Pos pos) {
    return tileAt(pos) != null;
  }
  
  Tile tileAt(Pos pos) {
    assert(pos.row < _height && pos.col < _width);
    return _tiles[pos.row * _width + pos.col];
  }
  
  void addTile(Tile tile, Pos pos) {
    _tiles[pos.row * _width + pos.col] = tile;
  }
}

class Level {  // Better name, e.g. zone, scene, map, area, etc
  List<TileMap> _layers;
  final int _width;
  final int _height;
  
  Level(int this._width, int this._height) {
    _layers = new List<TileMap>();
    _layers.add(new TileMap(_width, _height));
  }
  
  Element render() {
    Element outer = new Element.div();
    outer.style.setProperty('font-family', 'monospace');
    List<String> tiles = new List<String>(_height * _width);
    for (int row = 0; row < _height; ++row) {
      for (int col = 0; col < _width; ++col) {
        for (int i = _layers.length-1; i >= 0; --i) {
          Pos pos = new Pos(row, col);
          if (!_layers[i].hasTile(pos)) {
            continue;
          }
          outer.append(_layers[i].tileAt(pos).makeElement());
        }
      }
      outer.append(new Element.br());
    }
    return outer;
  }
  
  void addTile(Tile tile, Pos pos) {
    _layers[0].addTile(tile, pos);
  }
  
  void multiAddTile(Tile tile, Pos start_pos, Pos end_pos) {
    for (int row = start_pos.row; row < end_pos.row; ++row) {
      for (int col = start_pos.col; col < end_pos.col; ++col) {
        addTile(tile, new Pos(row, col));
      }
    }
  }
}

class Key {
  static final HashMap<int, Key> _keys = {};

  static Key get(int keyCode) {
    return _keys.containsKey(keyCode) ? _keys[keyCode] : null;
  }

  static final Key DOWN = new Key(40);
  static final Key UP = new Key(38);
  static final Key LEFT = new Key(37);
  static final Key RIGHT = new Key(39);

  final int _code;
  Key(this._code) {
    _keys[_code] = this;
  }
}

class KeyboardListener {
  HashMap<Key, int> _keys = {};

  void listen(Window w) {
    // TODO: Change to event target
    w.onKeyDown.listen(_processKeyDown);
    w.onKeyUp.listen(_processKeyUp);
  }

  int timestampIfPressed(Key key) {
    return _keys.containsKey(key) ? _keys[key] : -1;
  }

  void _processKeyDown(KeyboardEvent e) {
    Key key = Key.get(e.keyCode);
    if (key != null) {
      _keys.putIfAbsent(key, () => e.timeStamp);
    }
  }

  void _processKeyUp(KeyboardEvent e) {
    Key key = Key.get(e.keyCode);
    if (key != null) {
      this._keys.remove(key);
    }
  }
}

class InputHandler {  // TODO: Rename to describe the type of inputhandler and maybe generic class?
  final KeyboardListener _listener;

  InputHandler(this._listener) {
  }

  Key GetDirectionKey() {
    int lastTimestamp = -1;
    Key lastKey;
    for (Key k in [Key.UP, Key.DOWN, Key.RIGHT, Key.LEFT]) {
      int ts = _listener.timestampIfPressed(k);
      if (ts > lastTimestamp) {
        lastKey = k;
      }
    }
    return lastKey;
  }
}

class Player {
  static final int MOVE_PERIOD_MS = 500;
  int _row = 10;
  int _col = 10;
  int _last_move = 0;
  Tile _tile = new PlayerTile();

  bool shouldMove() {
    // TODO: TIme should be passed in.
    int now_ms = new DateTime.now().millisecondsSinceEpoch;
    if (now_ms > _last_move + MOVE_PERIOD_MS) {
      _last_move = now_ms;
      return true;
    }
    return false;
  }
}

class Game {
  final Level _level;
  final KeyboardListener _kl;
  final Player _player = new Player();
  InputHandler _input_handler;

  Game(this._kl, this._level) {
    this._input_handler = new InputHandler(_kl);
  }

  void start() {
    new Timer.periodic(new Duration(milliseconds: 100), this._gameLoop);
  }

  void _gameLoop(Timer timer) {
    _updatePlayer();
  }

  void _updatePlayer() {
    if (!_player.shouldMove()) {
      return;
    }
    Key direction = _input_handler.GetDirectionKey();
    if (direction == null) {
      return;
    } else if (direction == Key.UP) {
      _movePlayer(new Pos(1, 0));
    } else if (direction == Key.RIGHT) {
      _movePlayer(new Pos(0, 1));
    } else if (direction == Key.DOWN) {
      _movePlayer(new Pos(-1, 0));
    } else if (direction == Key.LEFT){
      _movePlayer(new Pos(0, -1));
    } else {
      assert(false);  // Invalid direction.
    }
  }

  void _movePlayer(Pos pos_offset) {
  }
}

void main() {
  Level level = new Level(20, 20);
  level.multiAddTile(new Grass(), new Pos(0, 0), new Pos(20, 20));
  level.multiAddTile(new Tree(), new Pos(0, 0), new Pos(1, 20));
  level.multiAddTile(new Tree(), new Pos(0, 0), new Pos(20, 1));
  level.multiAddTile(new Tree(), new Pos(0, 19), new Pos(20, 20));
  level.multiAddTile(new Tree(), new Pos(19, 0), new Pos(20, 20));
  level.multiAddTile(new Path(),  new Pos(0,  10), new Pos(20, 11));
  level.addTile(new PlayerTile(), new Pos(10, 10));
  querySelector('#world').append(level.render());
  KeyboardListener kl = new KeyboardListener();
  kl.listen(window);  // TODO: Why isn't this an element! what is it?

  Game game = new Game(kl, level);
  game.start();
}
