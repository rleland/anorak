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

  // TODO: Test: Straight lines, other octants.
  group("line drawing test", () {
    /*test("get octant test", () {
      expect(getOctant(new Pos(5, 5), new Pos(6, 7)), equals(0));
      expect(getOctant(new Pos(5, 5), new Pos(7, 7)), equals(0));
      expect(getOctant(new Pos(5, 5), new Pos(8, 7)), equals(1));
      expect(getOctant(new Pos(5, 5), new Pos(8, 3)), equals(2));
      expect(getOctant(new Pos(5, 5), new Pos(8, 2)), equals(3));
      expect(getOctant(new Pos(5, 5), new Pos(6, 2)), equals(3));
      expect(getOctant(new Pos(5, 5), new Pos(4, 2)), equals(4));
      expect(getOctant(new Pos(5, 5), new Pos(2, 2)), equals(4));
      expect(getOctant(new Pos(5, 5), new Pos(1, 2)), equals(5));
      expect(getOctant(new Pos(5, 5), new Pos(1, 6)), equals(6));
      expect(getOctant(new Pos(5, 5), new Pos(4, 6)), equals(7));
      expect(getOctant(new Pos(5, 5), new Pos(4, 8)), equals(7));
    });*/
    test("first octant test", () {
      expect(drawLine(new Pos(0, 0), new Pos(1, 3)),
             equals([new Pos(0,0), new Pos(0,1), new Pos(1,2), new Pos(1,3)]));
      expect(drawLine(new Pos(0, 0), new Pos(3, 3)),
             equals([new Pos(0,0), new Pos(1,1), new Pos(2,2), new Pos(3,3)]));
    });
  });
}