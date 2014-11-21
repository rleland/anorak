library common;

// TODO: This looks quite similar to dart point. Consider using that if this doesn't evolve.
class Pos {
  static const MOVE_UP = const Pos(-1, 0);
  static const MOVE_DOWN = const Pos(1, 0);
  static const MOVE_RIGHT = const Pos(0, 1);
  static const MOVE_LEFT = const Pos(0, -1);

  final int row;
  final int col;

  const Pos(this.row, this.col);

  Pos operator+(Pos other) {
    return new Pos(this.row + other.row, this.col + other.col);
  }
  Pos operator-(Pos other) {
    return new Pos(this.row - other.row, this.col - other.col);
  }
  // TODO: If you override ==, you should also override Object’s hashCode getter. For an example of
  // overriding == and hashCode, see [Implementing map keys].
  bool operator==(Pos other) {
    return other.row == this.row && other.col == this.col;
  }
  String toString() {
    return "$row,$col";
  }
}

class PosList<T> {
  final int _rows;
  final int _cols;
  final List<T> _list;

  int get length => _list.length;

  PosList(int rows, int cols)
      : _rows = rows, _cols = cols, _list = new List<T>(rows * cols);

  T operator[](Pos p) {
    assert(p.row < _rows && p.col < _cols);
    return _list[p.row * _cols + p.col];
  }

  void operator[]=(Pos p, T t) {
    assert(p.row < _rows && p.col < _cols);
    _list[p.row * _cols + p.col] = t;
  }

  String toString() {
    return _list.toString();
  }
}

abstract class GameState {
  Pos get player_pos;

  bool isPassable(Pos pos);
}

abstract class MessageLog {
  void write(String s);
}

abstract class Event {
  static const int TYPE_MOB = 1;

  int get type;
}

class RateLimiter {
  final int min_delay_;
  int last_ = 0;

  RateLimiter(int this.min_delay_);

  bool checkRate(DateTime now, {bool peek: false}) {
    int ms = now.millisecondsSinceEpoch;
    if (ms - last_ < min_delay_) {
      return false;
    }
    if (!peek) {
      last_ = ms;
    }
    return true;
  }
}

class Stats {
  final int str;
  final int dex;
  final int vit;
  int hp;

  int get max_hp => vit * 10;

  Stats({int this.str, int this.dex, int this.vit}) {
    FullHeal();
  }

  void FullHeal() {
    hp = max_hp;
  }
}