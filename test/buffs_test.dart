library buffs_test;

import 'package:anorak/buffs.dart';
import 'package:anorak/common.dart';
import 'package:unittest/unittest.dart';

// TODO: Mock buff for testing.
class TestBuff extends Buff {
  TestBuff(DateTime start_time) : super(start_time);

  String get id => 'test';
  int get duration_ms => 1000;

  void apply(DateTime now, Stats stats) {}
  void unApply(Stats stats) {}
}

main() {
  group("buff tests", () {
    test("buff active", () {
      DateTime start_time = new DateTime(2014, 11, 7, 12, 0, 0);
      DateTime middle_time = new DateTime(2014, 11, 7, 12, 0, 1);
      DateTime end_time = new DateTime(2014, 11, 7, 12, 0, 2);

      TestBuff buff = new TestBuff(start_time);
      expect(buff.active(start_time), isTrue);
      expect(buff.active(middle_time), isTrue);
      expect(buff.active(end_time), isFalse);
    });
  });
}