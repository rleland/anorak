library input;

import 'dart:collection';

class Key {
  static const Key DOWN = const Key(40);
  static const Key UP = const Key(38);
  static const Key LEFT = const Key(37);
  static const Key RIGHT = const Key(39);

  static Key get(int keyCode) {
     if (_keys.isEmpty) {
       _initKeys();
     }
     return _keys.containsKey(keyCode) ? _keys[keyCode] : null;
   }

  static final HashMap<int, Key> _keys = new HashMap<int, Key>();

  String toString() {
    return "KeyCode: $_code";
  }

  static void _initKeys() {
    for (Key k in [DOWN, UP, LEFT, RIGHT]) {
      _keys[k._code] = k;
    }
  }

  final int _code;
  const Key(int this._code);
}

class KeyboardListener {
  static final REPETITION_PERIOD_MS = 200;

  final Queue<Key> _key_queue = new Queue<Key>();
  final HashMap<Key, int> _held_keys = {};
  int _last_repetition_check_ms = 0;

  bool hasKeysToProcess(DateTime now) {
    _addRepeatsToQueue(now);
    return _key_queue.isNotEmpty;
  }

  Key consumeKeyFromQueue() {
    assert(_key_queue.isNotEmpty);
    return _key_queue.removeFirst();
  }

  void keyDown(int key_code, int timestamp) {
    Key key = Key.get(key_code);
    if (key == null) {
      return;
    }
    _held_keys.putIfAbsent(key, () => timestamp);
    _key_queue.add(key);
  }

  void keyUp(int key_code) {
    Key key = Key.get(key_code);
    if (key != null) {
      this._held_keys.remove(key);
    }
  }

  void _addRepeatsToQueue(DateTime now) {
    if (now.millisecondsSinceEpoch - _last_repetition_check_ms < REPETITION_PERIOD_MS ||
        _held_keys.isEmpty) {
      return;
    }
    _last_repetition_check_ms = now.millisecondsSinceEpoch;

    Key key = null;
    int max_ts = 0;
    for (Key k in _held_keys.keys) {
      if (_held_keys[k] <= max_ts) {
        continue;
      }
      max_ts = _held_keys[k];
      key = k;
    }
    assert(key != null);
    if (!_key_queue.contains(key)) {
      _key_queue.add(key);
    }
  }
}

class InputHandler {  // TODO: Rename to describe the type of inputhandler and maybe generic class?
  static final List<Key> DIRECTION_KEYS = [Key.UP, Key.DOWN, Key.RIGHT, Key.LEFT];

  bool IsDirectionKey(Key key) {
    return DIRECTION_KEYS.contains(key);
  }
}