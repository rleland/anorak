library player;

import 'dart:math';

import 'package:anorak/mob.dart';
import 'package:anorak/common.dart';
import 'package:anorak/tile.dart';

Stats PlayerStatsForLevel(int level) {
  return new Stats(str: 1 + level,
                   dex: level,
                   vit: 1 + level);
}

class LevelTracker {
  static int NextLevelXp(int level) {
    return (10 * pow(SQRT2, level-1)).round();
  }

  int _level;
  int _xp;

  int get level => _level;

  LevelTracker(int this._level, int this._xp);

  bool addXp(int xp) {
    bool leveled_up = false;
    _xp += xp;
    while (_xp >= NextLevelXp(_level)) {
      _xp -= NextLevelXp(_level);
      ++_level;
      leveled_up = true;
    }
    return leveled_up;
  }
}

class Player implements Mob {
  static final int MOVE_PERIOD_MS = 200;
  static final int ATTACK_PERIOD_MS = 1000;

  final Tile _tile = new PlayerTile();
  Pos _pos = new Pos(10, 10);
  int _last_move = 0;
  int _last_attack = 0;
  Stats _stats;
  LevelTracker _level_tracker = new LevelTracker(1, 0);

  String get name => 'player';
  Tile get tile => _tile;
  Pos get pos => _pos;
  Stats get stats => _stats;
  bool get attackable => true;
  int get xp_gain => 0;
  bool get is_alive => stats.hp > 0;
  int get level => _level_tracker.level;

  Player(int level) : _level_tracker = new LevelTracker(level, 0),
                      _stats = PlayerStatsForLevel(level);

  bool canMove(DateTime now) {
    int now_ms = now.millisecondsSinceEpoch;
    if (now_ms >= _last_move + MOVE_PERIOD_MS) {
      _last_move = now_ms;
      return true;
    }
    return false;
  }

  bool canAttack(DateTime now) {
    int now_ms = now.millisecondsSinceEpoch;
    if (now_ms >= _last_attack + ATTACK_PERIOD_MS) {
      _last_attack = now_ms;
      return true;
    }
    return false;
  }

  // TODO: Implemented only to fit mob interface. This is not ideal; maybe npcs should have
  // their own mob subclass.
  Pos getMove(DateTime now, GameState gameState) {
    return null;
  }

  void move(Pos new_pos) {
    _pos = new_pos;
  }

  bool gainXp(int xp) {
    if (_level_tracker.addXp(xp)) {
      _stats = PlayerStatsForLevel(_level_tracker.level);
      _stats.FullHeal();
      return true;
    }
    return false;
  }
}