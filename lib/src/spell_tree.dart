class SpellTreeNode<T> {
  T? match;
  final Map<int, SpellTreeNode<T>> children = {};

  bool get isLeaf => children.isEmpty;

  SpellTreeNode([this.match]);

  T? findMatch(String text, int idx) {
    if (idx >= text.length) return null;

    if (children[text.codeUnitAt(idx)] case final matchedNode?) {
      return matchedNode.isLeaf
          ? matchedNode.match
          : matchedNode.findMatch(text, idx + 1) ?? matchedNode.match;
    }
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
    entries.sort((a, b) {
      var res = a.$1.length - b.$1.length;
      return res != 0 ? res : a.$1.compareTo(b.$1);
    });
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
