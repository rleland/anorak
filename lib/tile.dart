library tile;

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