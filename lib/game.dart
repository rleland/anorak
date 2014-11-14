library game;

import 'package:anorak/mob.dart';
import 'package:anorak/common.dart';
import 'package:anorak/events.dart';
import 'package:anorak/fight.dart';
import 'package:anorak/input.dart';
import 'package:anorak/level.dart';
import 'package:anorak/messages.dart';
import 'package:anorak/player.dart';

class Game implements GameState {
  static final Map<Key, Pos> MOVES =
    {Key.UP: Pos.MOVE_UP,
     Key.DOWN: Pos.MOVE_DOWN,
     Key.LEFT: Pos.MOVE_LEFT,
     Key.RIGHT: Pos.MOVE_RIGHT};

  final Level _level;
  final KeyboardListener _kl;
  final Player _player;
  final InputHandler _input_handler;
  final MessageLog _log;
  bool _need_redraw = true;  // Force first draw.
  final List<Npc> _npcs = new List<Mob>();

  Level get level => _level;

  Game(KeyboardListener this._kl, Level this._level, MessageLog this._log, Player this._player)
      : _input_handler = new InputHandler() {
    _level.addMob(_player, _player.pos);
  }

  Pos get player_pos => _player.pos;

  bool isPassable(Pos pos) {
    return _level.isPassable(pos);
  }

  void addMob(Mob c) {
    _npcs.add(c);
    _level.addMob(c, c.pos);
  }

  bool loop(DateTime now) {
    while (_kl.hasKeysToProcess(now)) {
      Key key = _kl.consumeKeyFromQueue();
      if (_input_handler.IsDirectionKey(key)) {
        _updatePlayer(now, key);
      }
    }
    for (Npc npc in _npcs) {
      Pos new_pos = npc.getMove(now, this);
      if (new_pos != null &&
          _level.isPassable(new_pos)) {
        _need_redraw = true;
        _level.moveMobTile(npc.pos, new_pos);
        npc.move(new_pos);
      }
    }

    _triggerEvents(now, _player);
    _npcs.forEach((m) => _triggerEvents(now, m));

    _player.checkBuffs(_log, now);
    _npcs.forEach((m) => m.checkBuffs(_log, now));

    // TODO: Check if player is alive.
    int xp_gain = 0;
    for (Npc npc in _npcs) {
      if (npc.is_alive) {
        continue;
      }
      _log.write(Messages.Dead(npc.name));
      _level.removeMobTile(npc.pos);
      xp_gain += npc.xp_reward;
      _need_redraw = true;
    }
    _npcs.removeWhere((Mob m) => !m.is_alive);

    if (_player.gainXp(xp_gain)) {
      _log.write(Messages.LevelUp(_player.level));
    }

    // Don't waste resources unnecessarily.
    if (_need_redraw) {
      _need_redraw = false;
      return true;
    } else {
      return false;
    }
  }

  void _triggerEvents(DateTime now, Mob mob) {
    // TODO: Currently if the mob itself has an event associated with it a mob will continuously try
    // to trigger its own event.
    Event e = _level.getEvent(mob.pos);
    if (e == null) {
      return;
    }
    if (e.type == Event.TYPE_MOB) {
      (e as MobEvent).process(now, mob);
    }
  }

  void _updatePlayer(DateTime now, Key key) {
    assert(MOVES.containsKey(key));
    Pos new_pos = MOVES[key] + _player.pos;

    if (_level.isPassable(new_pos) && _player.canMove(now)) {
      _level.moveMobTile(_player.pos, new_pos);
      _player.move(new_pos);
      _need_redraw = true;
    } else if (_level.hasMob(new_pos)) {
      Mob mob = _level.mobAt(new_pos);
      if (mob.attackable && _player.canAttack(now)) {
        Attack(_player, mob, _log);
      }
    }
    // TODO: Interact with new tile regardless of whether it's passable.
  }
}