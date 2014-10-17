import 'dart:html';

abstract class Tile {
  String get explanation;  // Explains what the symbol means.
  String get symbol;  // Symbol used to render the tile.
  String get color;  // Color of the symbol.
  bool get passable => true;  // True if player can move onto tile.
  bool get has_event => false;  // True if interacting with the tile results in event.
}

class NullTile extends Tile {
  String get explanation => '';
  String get symbol => ' ';
  String get color => 'white';
}

class Grass extends Tile {
  String get explanation => 'grass';
  String get symbol => '.';
  String get color => 'lightgreen';  // TODO: Pick right shade of green.
}

class Tree extends Tile {
  String get explanation => 'tree';
  String get symbol => '#';
  String get color => 'green';
}

class Path extends Tile {
  String get explanation => 'path';
  String get symbol => '#';
  String get color => 'brown';
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
        AddTile(null_tile, row, col);
      }
    }
  }
  
  // row and col starts at 0
  bool HasTile(int row, int col) {
    return TileAt(row, col) != null;
  }
  
  Tile TileAt(int row, int col) {
    assert(row < _height && col < _width);
    return _tiles[row * _width + col];
  }
  
  void AddTile(Tile tile, int row, int col) {
    _tiles[row * _width + col] = tile;
  }
}

class Level {  // Better name, e.g. zone, scene, map, area, etc
  List<TileMap> _layers;
  int _width;
  int _height;
  
  Level(int width, int height) {
    _width = width;
    _height = height;
    _layers = new List<TileMap>();
    _layers.add(new TileMap(_width, _height));
  }
  
  Element Render() {
    Element outer = new Element.div();
    outer.style.setProperty('font-family', 'monospace');
    List<String> tiles = new List<String>(_height * _width);
    for (int row = 0; row < _height; ++row) {
      for (int col = 0; col < _width; ++col) {
        for (int i = _layers.length-1; i >= 0; --i) {
          if (!_layers[i].HasTile(row, col)) {
            continue;
          }
          Tile tile = _layers[i].TileAt(row, col);
          Element span = new Element.span();
          span.style.setProperty('color', tile.color);
          span.appendText(tile.symbol);
          outer.append(span);
        }
      }
      outer.append(new Element.br());
    }
    return outer;
  }
  
  void AddTile(Tile tile, int row, int col) {
    _layers[0].AddTile(tile, row, col);
  }
  
  void MultiAddTile(Tile tile, int start_row, int start_col, int end_row, int end_col) {
    for (int row = start_row; row < end_row; ++row) {
      for (int col = start_col; col < end_col; ++col) {
        AddTile(tile, row, col);
      }
    }
  }
}

void main() {
  Level level = new Level(20, 20);
  level.MultiAddTile(new Grass(), 0, 0, 20, 20);
  level.MultiAddTile(new Tree(), 0, 0, 1, 20);
  level.MultiAddTile(new Tree(), 0, 0, 20, 1);
  level.MultiAddTile(new Tree(), 0, 19, 20, 20);
  level.MultiAddTile(new Tree(), 19, 0, 20, 20);
  level.MultiAddTile(new Path(),  0,  10, 20, 11);
  querySelector('#world').append(level.Render());
}
