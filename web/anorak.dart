import 'dart:async';
import 'dart:collection';
import 'dart:html';
import 'package:anorak/buffs.dart';
import 'package:anorak/common.dart';
import 'package:anorak/events.dart';
import 'package:anorak/game.dart';
import 'package:anorak/input.dart';
import 'package:anorak/level.dart';
import 'package:anorak/mob.dart';
import 'package:anorak/player.dart';
import 'package:anorak/tile.dart';

void clearElement(Element e) {
  while (e.hasChildNodes()) {
    e.firstChild.remove();
  }
}

String twoDigits(int n) {
  if (n >= 10) return "${n}";
  return "0${n}";
}

void _renderGameOver() {
  querySelector('#game_over').style.display = '';
}

class FpsCounter {
  static final int WINDOW = 5;
  final Element _element;
  final Queue<int> _frames = new Queue<int>();

  FpsCounter(Element this._element);

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

class GameLoop {
  final Game _game;
  final FpsCounter _fps_counter;
  Timer _timer;

  GameLoop(Game this._game): _fps_counter = new FpsCounter(querySelector('#fps')) {
    _timer = new Timer.periodic(new Duration(milliseconds: 50), this._loop);
  }

  void _loop(Timer timer) {
    DateTime now = new DateTime.now();
    _fps_counter.update(now);
    try {
      if (_game.loop(now)) {
        // Need redraw.
        _redraw(_game.level);
      }
    } catch (GameOver) {
      _timer.cancel();
      _redraw(_game.level);
      _renderGameOver();
    }
  }

  void _redraw(Level level) {
    LevelRendererImpl renderer = new LevelRendererImpl();
    level.render(renderer);

    Element world = querySelector('#world');
    clearElement(world);
    world.append(renderer.rendered);
  }
}

class LevelRendererImpl implements LevelRenderer {
  final Element _outer;

  LevelRendererImpl() : _outer = new Element.div() {
    _outer.style.setProperty('font-family', 'monospace');
  }

  void AddTile(Tile tile) {
    _outer.append(_renderTile(tile));
  }

  void NewRow() {
    _outer.append(new Element.br());
  }

  Element get rendered => _outer;

  Element _renderTile(Tile tile) {
    Element span = new Element.span();
    span.style.setProperty('color', tile.color);
    if (tile.bold) {
      span.style.setProperty('font-weight', 'bold');
    }
    span.appendText(tile.symbol);
    return span;
  }
}

class MessageLogImpl implements MessageLog {
  static String AddTimestamp(DateTime time, String text) {
    String h = twoDigits(time.hour);
    String m = twoDigits(time.minute);
    String s = twoDigits(time.second);
    return "[$h:$m:$s] $text";
  }

  static const int LOG_LENGTH = 200;
  final Element _log;

  MessageLogImpl(Element this._log);

  void write(String s) {
    s = AddTimestamp(new DateTime.now(), s);
    while (_log.childNodes.length >= LOG_LENGTH) {
      _log.lastChild.remove();
    }
    _log.insertBefore(new Element.br(), _log.firstChild);
    _log.insertBefore(new Text(s), _log.firstChild);
  }
}

void main() {
  KeyboardListener kl = new KeyboardListener();
  WindowListener wl = new WindowListener(window, kl);
  MessageLogImpl log = new MessageLogImpl(querySelector('#messageLog'));

  Level level = new Level(20, 20);
  level.multiAddBaseTile(new Grass(), new Pos(0, 0), new Pos(20, 20));
  level.multiAddBaseTile(new Tree(), new Pos(0, 0), new Pos(1, 20));
  level.multiAddBaseTile(new Tree(), new Pos(0, 0), new Pos(20, 1));
  level.multiAddBaseTile(new Tree(), new Pos(0, 19), new Pos(20, 20));
  level.multiAddBaseTile(new Tree(), new Pos(19, 0), new Pos(20, 20));
  level.multiAddBaseTile(new Path(), new Pos(0,  10), new Pos(20, 11));
  level.addBaseTile(new Fire()..event = new BuffEvent((DateTime now) => new BurnBuff(log, now, 2)),
                    new Pos(15, 15));
  Game game = new Game(kl, level, log, new Player(new Pos(10, 10), 1));
  game.addMob(new Rat(new Pos(1, 1), new Stats(str: 1, dex: 1, vit: 1)));
  new GameLoop(game);
}