library character;

import "package:anorak/common.dart";
import "package:anorak/tile.dart";

abstract class Character {
  final Tile _tile;

  Character(Tile this._tile);

  Pos getMove();
}