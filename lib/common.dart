library common;

class Pos {
  final int row;
  final int col;

  Pos(this.row, this.col);

  Pos operator+(Pos other) {
    return new Pos(this.row + other.row, this.col + other.col);
  }
}
