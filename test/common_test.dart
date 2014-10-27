library common_test;

import 'package:anorak/common.dart';
import 'package:unittest/unittest.dart';

main() {
  group("pos tests", () {
    test("sum pos", () {
      Pos sum = new Pos(5, 1) + new Pos(1, 2);
      expect(sum.row, equals(6));
      expect(sum.col, equals(3));
    });

    test("sum w/ negative pos", () {
      Pos sum = new Pos(5, 3) + new Pos(-1, -2);
      expect(sum.row, equals(4));
      expect(sum.col, equals(1));
    });
  });
}