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
