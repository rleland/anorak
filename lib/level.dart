library level;

import 'dart:html';
import 'package:anorak/tile.dart';

class Pos {
  final int row;
  final int col;

  Pos(this.row, this.col) {
  }

  Pos operator+(Pos other) {
    return new Pos(this.row + other.row, this.col + other.col);
  }
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

abstract class LevelRenderer {
  // Add a tile to the current row in rendering.
  void AddTile(Tile tile);

  // Should be called after each row of tiles. Should not be called before first row.
  void NewRow();
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

  void render(LevelRenderer renderer) {
    List<String> tiles = new List<String>(_rows * _cols);
    for (int row = 0; row < _rows; ++row) {
      for (int col = 0; col < _cols; ++col) {
        for (int i = _layers.length-1; i >= 0; --i) {
          Pos pos = new Pos(row, col);
          if (!_layers[i].hasTile(pos)) {
            continue;
          }
          renderer.AddTile(_layers[i].tileAt(pos));
          break;  // Only append one per row,col.
        }
      }
      renderer.NewRow();
    }
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
