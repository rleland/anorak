library path_finding_test;

import 'package:anorak/path_finding.dart';
import 'package:unittest/unittest.dart';

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
}