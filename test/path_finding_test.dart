library path_finding_test;

import 'package:anorak/common.dart';
import 'package:anorak/path_finding.dart';
import 'package:unittest/unittest.dart';

class MockGameState implements GameState {
  Pos _player_pos = new Pos(0, 0);
  Pos get player_pos =>  _player_pos;
  bool isPassable(Pos) {
    return true;
  }
}

main() {
  group("test loose functions", () {
    test("test cap", () {
      expect(capMagnitude(5, 1), equals(1));
      expect(capMagnitude(-5, 1), equals(-1));
      expect(capMagnitude(7, 2), equals(2));
      expect(capMagnitude(-7, 2), equals(-2));
      expect(capMagnitude(0, 3), equals(0));
    });
  });

  // TODO: Test: Straight lines
  group("line drawing", () {
    test("first octant", () {
      expect(drawLine(new Pos(0, 0), new Pos(1, 3)),
             equals([new Pos(0,0), new Pos(0,1), new Pos(1,2), new Pos(1,3)]));
      expect(drawLine(new Pos(0, 0), new Pos(3, 3)),
             equals([new Pos(0,0), new Pos(1,1), new Pos(2,2), new Pos(3,3)]));
      expect(drawLine(new Pos(2, 2), new Pos(3, 5)),
             equals([new Pos(2, 2), new Pos(2, 3), new Pos(3, 4), new Pos(3, 5)]));
    });
    test("second octant", () {
      expect(drawLine(new Pos(3, 7), new Pos(6, 9)),
             equals([new Pos(3, 7), new Pos(4, 8), new Pos(5, 8), new Pos(6, 9)]));
    });
    test("third octant", () {
      expect(drawLine(new Pos(1, 8), new Pos(5, 5)),
             equals([new Pos(1, 8), new Pos(2, 7), new Pos(3, 6), new Pos(4, 6), new Pos(5, 5)]));
    });
    test("fourth octant", () {
      expect(drawLine(new Pos(3, 10), new Pos(5, 7)),
             equals([new Pos(3, 10), new Pos(4, 9), new Pos(4, 8), new Pos(5, 7)]));
    });
    test("fifth octant", () {
      expect(drawLine(new Pos(5, 5), new Pos(3, 1)),
             equals([new Pos(5, 5), new Pos(4, 4), new Pos(4, 3), new Pos(3, 2), new Pos(3, 1)]));
    });
    test("sixth octant", () {
      expect(drawLine(new Pos(10, 10), new Pos(7, 8)),
             equals([new Pos(10, 10), new Pos(9, 9), new Pos(8, 9), new Pos(7, 8)]));
    });
    test("seventh octant", () {
      expect(drawLine(new Pos(5, 5), new Pos(8, 1)),
             equals([new Pos(5, 5), new Pos(6, 4), new Pos(7, 3), new Pos(7, 2), new Pos(8, 1)]));
    });
    test("eigth octant", () {
      expect(drawLine(new Pos(8, 8), new Pos(6, 12)),
             equals([new Pos(8, 8), new Pos(7, 9), new Pos(7, 10), new Pos(6, 11), new Pos(6, 12)]));
    });
  });
}