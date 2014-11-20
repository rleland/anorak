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

// Bresenham for lines in the first octant, assuming the line starts in the origin.
List<Pos> _firstOctantBresenham(Pos to) {
  // In mapping x,y coordinates in Bresenham to the row/col matrix this convention is used:
  // x : col
  // y : row
  // points are (x, y) i.e (col, row)
  assert(to.row > 0);
  assert(to.col > 0);
  assert(to.col >= to.row);

  List<Pos> plot = [];
  int y = 0;
  int e = 0;

  for (int x = 0; x <= to.col; ++x) {
    plot.add(new Pos(y, x));
    e += to.row;
    if (2 * e >= to.col) {
      ++y;
      e -= to.col;
    }
  }
  return plot;
}

// Gets which octant the line lies in, assuming it starts at the origin.
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
int _getOctant(Pos to) {
  assert(to.row != 0 && to.col != 0);
  if (to.row > 0 && to.col > 0) {
    return to.col >= to.row ? 0 : 1;
  } else if (to.row > 0 && to.col < 0) {
    return to.col.abs() >= to.row ? 3 : 2;
  } else if (to.row < 0 && to.col < 0) {
    return to.col <= to.row ? 4 : 5;
  } else {  // diff.row < 0 && diff.col > 0
    return to.col >= to.row.abs() ? 7: 6;
  }
}

// Maps the pos to or from the first octant.
Pos _mapToOctant(Pos pos, int octant, {bool undo: false}) {
  switch (octant) {
    case 0: return pos;
    case 1: return new Pos(pos.col, pos.row);
    case 2: return undo ? new Pos(pos.col, -pos.row) : new Pos(-pos.col, pos.row);
    case 3: return new Pos(pos.row, -pos.col);
    case 4: return new Pos(-pos.row, -pos.col);
    case 5: return new Pos(-pos.col, -pos.row);
    case 6: return undo ? new Pos(-pos.col, pos.row) : new Pos(pos.col, -pos.row);
    case 7: return new Pos(-pos.row, pos.col);
    default: throw new UnimplementedError("Unsupported octant: $octant");
  }
}

// Returns the positions, inclusive of from and to, needed to be filled to draw a line between the
// two points.
// TODO: Handle straight lines.
Iterable<Pos> drawLine(Pos from, Pos to) {
  // Shift the coordinate system so you're finding the line from the origin to the delta. This makes
  // dealing with octants and mapping between them more conceptually straight forward.
  Pos delta = to - from;
  int octant = _getOctant(delta);
  Pos mapped_delta = _mapToOctant(delta, octant);
  return _firstOctantBresenham(mapped_delta)
      .map((p) => _mapToOctant(p, octant, undo: true))
      .map((p) => p + from);
}

// Uses bresenham line drawing to determine tiles which need to be free to establish line of sight.
// This will have the caveat that line of sight doesn't necessarily mean the two can be reached.
// E.g. the line between X and Y marked by o's is:
// ..Xooo........
// ......oooY....
// Where there is a diagonal 'jump', rather than overlap.
// It's possible Bresenham can be modified to include this overlap if necessary, or maybe one of
// the anti-aliasing algorithms can be adapted, but for a first implementation this looks fine.
bool hasLineOfSight(Pos from, Pos to, GameState game_state) {
  return drawLine(from, to).every(game_state.isPassable);
}