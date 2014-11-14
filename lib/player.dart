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

class Player extends Mob {
  static const int MOVE_PERIOD_MS = 200;
  static const int ATTACK_PERIOD_MS = 1000;

  final Tile _tile = new PlayerTile();
  final RateLimiter _move_rate = new RateLimiter(MOVE_PERIOD_MS);
  final RateLimiter _attack_rate = new RateLimiter(ATTACK_PERIOD_MS);
  Stats _stats;
  LevelTracker _level_tracker = new LevelTracker(1, 0);

  String get name => 'Player';
  Tile get tile => _tile;
  Stats get stats => _stats;
  int get level => _level_tracker.level;
  bool get attackable => false;

  Player(Pos pos, int level) : super(pos),
                               _level_tracker = new LevelTracker(level, 0),
                               _stats = PlayerStatsForLevel(level);

  bool canMove(DateTime now) {
    return _move_rate.checkRate(now);
  }

  bool canAttack(DateTime now) {
    return _attack_rate.checkRate(now);
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