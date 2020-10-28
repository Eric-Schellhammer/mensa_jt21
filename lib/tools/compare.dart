class CascadedComparator {
  final _left;
  final _right;
  final List<dynamic Function(dynamic)> _getters = List();

  CascadedComparator(this._left, this._right);

  CascadedComparator then(dynamic Function(dynamic) getter) {
    _getters.add(getter);
    return this;
  }

  int calculate() {
    for (int index = 0; index < _getters.length; index++) {
      final comparison = _getters[index];
      final result = comparison(_left).compareTo(comparison(_right));
      if (result != 0) return result;
    }
    return 0;
  }
}
