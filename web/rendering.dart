import 'dart:html';
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

Element renderTile(Tile tile) {
  Element span = new Element.span();
  span.style.setProperty('color', tile.color);
  if (tile.bold) {
    span.style.setProperty('font-weight', 'bold');
  }
  span.appendText(tile.symbol);
  return span;
}