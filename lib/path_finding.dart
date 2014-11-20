library path_finding;

import "package:anorak/common.dart";

int capMagnitude(int value, int magnitude) {
  if (value == 0)
    return 0;
  return (magnitude * value / value.abs()).truncate();
}

// Naive pathfinding.
Pos moveCloser(Pos from, Pos to) {
  Pos delta = to - from;
  if (delta.row.abs() >= delta.col.abs()) {
    return new Pos(capMagnitude(delta.row, 1), 0);
  } else {
    return new Pos(0, capMagnitude(delta.col, 1));
  }
}

bool inRange(Pos src, Pos dst, int row_dist, int col_dist) {
  Pos delta = dst - src;
  return delta.row.abs() <= row_dist && delta.col.abs() <= col_dist;
}

// Bresenham for lines in the first octant.
List<Pos> _firstOctantBresenham(Pos from, Pos to) {
  // In mapping x,y coordinates in Bresenham to the row/col matrix this convention is used:
  // x : col
  // y : row
  // points are (x, y) i.e (col, row)
  assert(to.row > from.row);
  assert(to.col > from.col);
  Pos delta = to - from;
  assert(delta.col >= delta.row);

  List<Pos> plot = [];
  int y = from.row;
  int e = 0;

  for (int x = from.col; x <= to.col; ++x) {
    plot.add(new Pos(y, x));
    e += delta.row;
    if (2 * e >= delta.col) {
      ++y;
      e -= delta.col;
    }
  }
  return plot;
}

// Gets which octant the line lies in. Octants can be thought of as classifying the direction of the
// line with the 'from' point as the origin
// Octants:
//  \2|1/
//  3\|/0
// ---+---
//  4/|\7
//  /5|6\
// For the purposes of this illustration y (rows) increases going up, and x (cols) increases going
// right. Note that this is different from the coordinate system used for the map which has the
// origin in the top left, and y (rows) increasing going down from the origin. However for this
// purpose that's not important.
int _getOctant(Pos from, Pos to) {
  Pos diff = to - from;
  assert(diff.row != 0 && diff.col != 0);
  if (diff.row > 0 && diff.col > 0) {
    return diff.col >= diff.row ? 0 : 1;
  } else if (diff.row > 0 && diff.col < 0) {
    return diff.col.abs() >= diff.row ? 3 : 2;
  } else if (diff.row < 0 && diff.col < 0) {
    return diff.col <= diff.row ? 4 : 5;
  } else {  // diff.row < 0 && diff.col > 0
    return diff.col >= diff.row.abs() ? 7: 6;
  }
}

List<Pos> drawLine(Pos from, Pos to) {
  // Use bresenham for this and return the positions the line passes through.
  // This will have the caveat that line of sight doesn't necessarily mean the two can be reached.
  // E.g. the line between X and Y marked by o's is:
  // ..Xooo........
  // ......oooY....
  // Where there is a diagonal 'jump', rather than overlap.
  // It's possible Bresenham can be modified to include this overlap if necessary, or maybe one of
  // the anti-aliasing algorithms can be adapted, but for a first implementation this looks fine.
  int octant = _getOctant(from, to);
  switch (octant) {
    case 0:
      return _firstOctantBresenham(from, to);
    default:
      throw new UnimplementedError("Octant not supported: $octant");
  }

}

bool hasLineOfSight(Pos from, Pos to, GameState game_state) {
  List<Pos> line = drawLine(from, to);
  return line.every(game_state.isPassable);
}