library common;

// Note: This looks quite similar to dart point. Consider using that if this doesn't evolve.
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
  Pos operator-(Pos other) {
    return new Pos(this.row - other.row, this.col - other.col);
  }
  String toString() {
    return "$row,$col";
  }
}

abstract class GameState {
  Pos get player_pos;

  bool isPassable(Pos pos);
}

abstract class MessageLog {
  void write(String s);
}
