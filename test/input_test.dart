library input_test;

import 'package:anorak/input.dart';
import 'package:unittest/unittest.dart';

void expectKeys(KeyboardListener kl, DateTime time, List<Key> keys) {
  for (Key key in keys) {
    expect(kl.hasKeysToProcess(time), isTrue, reason: "Expected keys, found none.");
    expect(kl.consumeKeyFromQueue(), equals(key));
  }
  expect(kl.hasKeysToProcess(time), isFalse, reason: "Unexpectedly contains keys.");
}

main() {
  group("key tests", () {
    test("get keys", () {
      // Just check that fetching keys work.
      expect(Key.get(38), equals(Key.UP));
      expect(Key.get(40), equals(Key.DOWN));
    });
  });

  group("keyboard listener tests", () {
    test("keypress", () {
      KeyboardListener kl = new KeyboardListener();
      kl.keyDown(38, 100);
      kl.keyUp(38);
      DateTime time = new DateTime(2014);
      expectKeys(kl, new DateTime(2014), [Key.UP]);
    });

    test("hold key", () {
      KeyboardListener kl = new KeyboardListener();
      kl.keyDown(38, 100);
      expectKeys(kl, new DateTime(2014, 10, 24), [Key.UP]);
      // One whole day later we expect one more repetition. We purposely don't repeat more often
      // than keys are requested, even if the reptition period is lower, to avoid a backlog of
      // repetitions.
      expectKeys(kl, new DateTime(2014, 10, 25), [Key.UP]);
      kl.keyUp(38);
      expect(kl.hasKeysToProcess(new DateTime(2014, 10, 26)), isFalse);
    });

    test("hold two keys", () {
      KeyboardListener kl = new KeyboardListener();
      kl.keyDown(38, 100);
      kl.keyDown(40, 101);
      expectKeys(kl, new DateTime(2014, 10, 24), [Key.UP, Key.DOWN]);
      expectKeys(kl, new DateTime(2014, 10, 25), [Key.DOWN]);
      kl.keyUp(40);
      expect(kl.hasKeysToProcess(new DateTime(2014, 10, 25)), isFalse);
      expectKeys(kl, new DateTime(2014, 10, 26), [Key.UP]);
      kl.keyUp(38);
      expect(kl.hasKeysToProcess(new DateTime(2014, 10, 26)), isFalse);
    });
  });

  group("input handler tests", () {
    test("check direction keys", () {
      expect(InputHandler.IsDirectionKey(Key.UP), isTrue);
    });
  });
}
