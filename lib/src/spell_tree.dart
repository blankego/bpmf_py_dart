import 'py_maps.dart';

class SpellTreeNode<T> {
  T? match;
  final Map<int, SpellTreeNode<T>> children = {};

  bool get isLeaf => children.isEmpty;

  SpellTreeNode([this.match]);

  (T, int)? findMatch(String txt, int idx) {
    if (idx >= txt.length) return null;

    //look it up in the childlist of curr node
    if (children[txt.codeUnitAt(idx)] case final foundNode?) {
      //found curr letter then move the idx to point to the next letter
      idx++;

      //if the found node is no leaf look further
      if (!foundNode.isLeaf) {
        if (foundNode.findMatch(txt, idx) case (T deepMatch?, int deepIdx)?) {
          return (deepMatch, deepIdx);
        }
      }
      //if not found in the deeper branch
      if (foundNode.match case T m?) {
        return (m, idx);
      }
    }

    // no find, the idx stays the same
    return null;
  }

  void insert(String term, int idx, T match) {
    final child = children.putIfAbsent(term.codeUnitAt(idx++),
        () => SpellTreeNode<T>(idx == term.length ? match : null));
    if (idx < term.length) {
      child.insert(term, idx, match);
    } else if (child.match == null && match != null) {
      child.match = match;
    }
  }

  static SpellTreeNode<T> assembleTree<T>(List<(String, T)> entries) {
    //no need to sort it first
    // entries.sort((a, b) {
    //   var res = a.$1.length - b.$1.length;
    //   return res != 0 ? res : a.$1.compareTo(b.$1);
    // });
    final root = SpellTreeNode<T>(null);
    for (final (term, match) in entries) {
      root.insert(term, 0, match);
    }
    return root;
  }

  @override
  String toString() => display(0);
  String display(int tabDepth) {
    if (isLeaf) return '';
    String tabs = '\t' * tabDepth;
    final buf = StringBuffer();
    for (final MapEntry(:key, value: child) in children.entries) {
      buf
        ..write(tabs)
        ..write('- ')
        ..writeCharCode(key);
      if (child.match != null) buf.write('*');
      buf
        ..write('\n')
        ..write(child.display(tabDepth + 1));
    }
    return buf.toString();
  }
}

final SpellTreeNode<(int, int)> ascPyRimeTree =
    SpellTreeNode.assembleTree(untonedFinalsToMedRime);

final SpellTreeNode<(int, int, int)> pyRimeTree =
    SpellTreeNode.assembleTree(tonedFinalsToMedRimetone);
