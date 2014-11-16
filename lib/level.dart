library level;

import 'package:anorak/common.dart';
import 'package:anorak/mob.dart';
import 'package:anorak/tile.dart';

class TileMap {
  PosList<Tile> _tiles;
  final int _rows;
  final int _cols;

  TileMap(int this._rows, int this._cols) {
    _tiles = new PosList<Tile>(_rows, _cols);
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
    return _tiles[pos];
  }

  void addTile(Tile tile, Pos pos) {
    _tiles[pos] = tile;
  }

  void removeTile(Pos pos) {
    _tiles[pos] = null;
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
  static final int MOB_LAYER = 2;
  static final int NUM_LAYERS = 3;

  final List<TileMap> _layers = [];
  final int _rows;
  final int _cols;
  PosList<Mob> _mobs;

  Level(int this._rows, int this._cols) {
    _mobs = new PosList<Mob>(_rows, _cols);
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

  void clearMobLayer() {
    for (int row = 0; row < _rows; ++row) {
      for (int col = 0; col < _cols; ++col) {
        _layers[MOB_LAYER].removeTile(new Pos(row, col));
      }
    }
  }

  void addMob(Mob mob, Pos pos) {
    _layers[MOB_LAYER].addTile(mob.tile, pos);
    _mobs[pos] = mob;
  }

  void moveMobTile(Pos from, Pos to) {
    TileMap layer = _layers[MOB_LAYER];
    Tile tile = layer.tileAt(from);
    layer.removeTile(from);
    layer.addTile(tile, to);
    _mobs[to] = _mobs[from];
    _mobs[from] = null;
  }

  void removeMobTile(Pos pos) {
    _layers[MOB_LAYER].removeTile(pos);
    _mobs[pos] = null;
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

  bool hasMob(Pos pos) {
    if (pos.row >= _rows || pos.row < 0 || pos.col >= _cols || pos.col < 0) {
      return false;
    }
    return _mobs[pos] != null;
  }

  Mob mobAt(Pos pos) {
    return _mobs[pos];
  }

  List<Event> getEvents(Pos pos) {
    List<Event> events = [];
    for (int i = _layers.length-1; i >= 0; --i) {
      if (_layers[i].hasTile(pos) && _layers[i].tileAt(pos).has_event) {
        events.add(_layers[i].tileAt(pos).event);
      }
    }
    return events;
  }
}
