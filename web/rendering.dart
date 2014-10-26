import 'dart:html';
import 'package:anorak/level.dart';
import 'package:anorak/tile.dart';

void clearElement(Element e) {
  while (e.hasChildNodes()) {
    e.firstChild.remove();
  }
}

void debug(String s) {
  Element dbg = querySelector('#debug');
  List<Node> children = new List<Node>();
  children.add(new Text(s));
  children.add(new Element.br());
  children.addAll(dbg.childNodes);
  clearElement(dbg);
  for (Node child in children) {
    dbg.append(child);
  }
}

class LevelRendererImpl implements LevelRenderer {
  final Element _outer;

  LevelRendererImpl() : _outer = new Element.div() {
    _outer.style.setProperty('font-family', 'monospace');
  }

  void AddTile(Tile tile) {
    _outer.append(_renderTile(tile));
  }

  void NewRow() {
    _outer.append(new Element.br());
  }

  Element get rendered => _outer;

  Element _renderTile(Tile tile) {
    Element span = new Element.span();
    span.style.setProperty('color', tile.color);
    if (tile.bold) {
      span.style.setProperty('font-weight', 'bold');
    }
    span.appendText(tile.symbol);
    return span;
  }
}

void redraw(Level level) {
  LevelRendererImpl renderer = new LevelRendererImpl();
  level.render(renderer);

  Element world = querySelector('#world');
  clearElement(world);
  world.append(renderer.rendered);
}