library player_test;

import 'package:anorak/player.dart';
import 'package:unittest/unittest.dart';

main() {
  group("player test", () {
    test("test move interval", () {
      Player player = new Player();
      DateTime time = new DateTime(2014, 10, 24, 13, 37, 0, 0);
      expect(player.shouldMove(time), isTrue);
      expect(player.shouldMove(time), isFalse);
      time = new DateTime(2014, 10, 24, 13, 37, 0, 10);
      expect(player.shouldMove(time), isFalse);
      time = new DateTime(2014, 10, 24, 13, 37, 0, Player.MOVE_PERIOD_MS);
      expect(player.shouldMove(time), isTrue);
    });
  });
}