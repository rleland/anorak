library tile;

import 'package:anorak/common.dart';

abstract class Tile {
  String get explanation;  // Explains what the symbol means.
  String get symbol;  // Symbol used to render the tile.
  String get color;  // Color of the symbol.
  bool get passable => true;  // True if player can move onto tile.
  bool get has_event => this.event != null;  // True if interacting with the tile results in event.
  bool get bold => false;  // Rendered in bold if true (typically PC and NPCs).

  Event event;
}

class Grass extends Tile {
  @override String get explanation => 'grass';
  @override String get symbol =>'.';
  @override String get color => 'lightgreen';
}

class Tree extends Tile {
  @override String get explanation => 'tree';
  @override String get symbol => '#';
  @override String get color => 'green';
  @override bool get passable => false;
}

class Path extends Tile {
  @override String get explanation => 'path';
  @override String get symbol => '#';
  @override String get color => 'rosybrown';
}

class Fire extends Tile {
  @override String get explanation => 'fire';
  @override String get symbol => '#';
  @override String get color => 'orangered';
}

class Tombstone extends Tile {
  @override String get explanation => 'tombstone';
  @override String get symbol => 'X';
  @override String get color => 'black';
  @override bool get bold => true;
}


// Mob tiles.

class PlayerTile extends Tile {
  @override String get explanation => 'you';
  @override String get symbol => '@';
  @override String get color => 'black';
  @override bool get passable => false;
  @override bool get bold => true;
}

class RatTile extends Tile {
  @override String get explanation => 'rat';
  @override String get symbol => 'r';
  @override String get color => 'black';
  @override bool get passable => false;
  @override bool get bold => true;
}