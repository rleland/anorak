library player_test;

import 'package:anorak/mob.dart';
import 'package:anorak/player.dart';
import 'package:unittest/unittest.dart';

main() {
  group("player test", () {
    test("test move interval", () {
      Player player = new Player(1);
      DateTime time = new DateTime(2014, 10, 24, 13, 37, 0, 0);
      expect(player.canMove(time), isTrue);
      expect(player.canMove(time), isFalse);
      time = new DateTime(2014, 10, 24, 13, 37, 0, 10);
      expect(player.canMove(time), isFalse);
      time = new DateTime(2014, 10, 24, 13, 37, 0, Player.MOVE_PERIOD_MS);
      expect(player.canMove(time), isTrue);
    });
  });

  group("level tracker test", () {
    test("test level tracker increments", () {
      LevelTracker level_tracker = new LevelTracker(1, 0);
      expect(level_tracker.addXp(1), isFalse);  // Not enough.
      expect(level_tracker.addXp(9), isTrue);  // Exactly enough for next level.
      expect(level_tracker.level, equals(2));
      expect(level_tracker.addXp(14), isTrue);  // Test xp increase.
      expect(level_tracker.level, equals(3));
      expect(level_tracker.addXp(25), isTrue);  // Test xp overflow (should only need 20).
      expect(level_tracker.level, equals(4));
      expect(level_tracker.addXp(23), isTrue);  // 28 for next lvl but should have overflow of 5.
      expect(level_tracker.level, equals(5));
    });

    test("test double level up", () {
      LevelTracker level_tracker = new LevelTracker(1, 0);
      expect(level_tracker.addXp(30), isTrue);
      expect(level_tracker.level, equals(3));
    });
  });
}