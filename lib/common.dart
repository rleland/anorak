library common;

class Pos {
  static const Pos MOVE_DOWN = const Pos(1, 0);
  static const Pos MOVE_UP = const Pos(-1, 0);
  static const Pos MOVE_RIGHT = const Pos(0, 1);
  static const Pos MOVE_LEFT = const Pos(0, -1);

  final int row;
  final int col;

  const Pos(this.row, this.col);

  Pos operator+(Pos other) {
    return new Pos(this.row + other.row, this.col + other.col);
  }
}
