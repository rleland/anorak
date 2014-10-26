import 'dart:collection';
import 'dart:html';
import 'package:anorak/common.dart';
import 'package:anorak/game.dart';
import 'package:anorak/input.dart';
import 'package:anorak/level.dart';
import 'package:anorak/tile.dart';
import 'rendering.dart';

class FpsCounter {
  static final int WINDOW = 5;
  final Element _element;
  final Queue<int> _frames = new Queue<int>();

  FpsCounter(Element this._element) {
  }

  void update(DateTime time) {
    int now_ms = time.millisecondsSinceEpoch;
    int cutoff = now_ms - WINDOW * 1000;
    while (_frames.isNotEmpty && _frames.first < cutoff) {
      _frames.removeFirst();
    }
    _frames.add(now_ms);
    _redraw(_frames.length / WINDOW);
  }

  void _redraw(double fps) {
    clearElement(_element);
    _element.appendText("$fps");
  }
}

class WindowListener {
  final KeyboardListener _kl;

  WindowListener(Window window, KeyboardListener this._kl) {
    window.onKeyDown.listen(_processKeyDown);
    window.onKeyUp.listen(_processKeyUp);
  }

  void _processKeyDown(KeyboardEvent e) {
    _kl.keyDown(e.keyCode, e.timeStamp);
  }

  void _processKeyUp(KeyboardEvent e) {
    _kl.keyUp(e.keyCode);
  }
}

void main() {
  Level level = new Level(20, 20);
  level.multiAddBaseTile(new Grass(), new Pos(0, 0), new Pos(20, 20));
  level.multiAddBaseTile(new Tree(), new Pos(0, 0), new Pos(1, 20));
  level.multiAddBaseTile(new Tree(), new Pos(0, 0), new Pos(20, 1));
  level.multiAddBaseTile(new Tree(), new Pos(0, 19), new Pos(20, 20));
  level.multiAddBaseTile(new Tree(), new Pos(19, 0), new Pos(20, 20));
  level.multiAddBaseTile(new Path(), new Pos(0,  10), new Pos(20, 11));
  KeyboardListener kl = new KeyboardListener();
  WindowListener wl = new WindowListener(window, kl);

  Game game = new Game(kl, level);
  game.start();
}
