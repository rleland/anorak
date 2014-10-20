import 'dart:collection';
import 'dart:html';

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
  int _width;
  int _height;
  
  TileMap(int width, int height) {
    _width = width;
    _height = height;
    _tiles = new List<Tile>(_width * _height);
    Tile null_tile = new NullTile();
    for (int row = 0; row < _height; ++row) {
      for (int col = 0; col < _width; ++col) {
        addTile(null_tile, row, col);
      }
    }
  }
  
  // row and col starts at 0
  bool hasTile(int row, int col) {
    return tileAt(row, col) != null;
  }
  
  Tile tileAt(int row, int col) {
    assert(row < _height && col < _width);
    return _tiles[row * _width + col];
  }
  
  void addTile(Tile tile, int row, int col) {
    _tiles[row * _width + col] = tile;
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
          if (!_layers[i].hasTile(row, col)) {
            continue;
          }
          outer.append(_layers[i].tileAt(row, col).makeElement());
        }
      }
      outer.append(new Element.br());
    }
    return outer;
  }
  
  void addTile(Tile tile, int row, int col) {
    _layers[0].addTile(tile, row, col);
  }
  
  void multiAddTile(Tile tile, int start_row, int start_col, int end_row, int end_col) {
    for (int row = start_row; row < end_row; ++row) {
      for (int col = start_col; col < end_col; ++col) {
        addTile(tile, row, col);
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

void main() {
  Level level = new Level(20, 20);
  level.multiAddTile(new Grass(), 0, 0, 20, 20);
  level.multiAddTile(new Tree(), 0, 0, 1, 20);
  level.multiAddTile(new Tree(), 0, 0, 20, 1);
  level.multiAddTile(new Tree(), 0, 19, 20, 20);
  level.multiAddTile(new Tree(), 19, 0, 20, 20);
  level.multiAddTile(new Path(),  0,  10, 20, 11);
  level.addTile(new PlayerTile(), 10, 10);
  querySelector('#world').append(level.render());
  KeyboardListener kl = new KeyboardListener();
  kl.listen(window);  // TODO: Why isn't this an element! what is it?
}
