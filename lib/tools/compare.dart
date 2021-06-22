class CascadedComparator<T> {
  final T _left;
  final T _right;
  final List<dynamic Function(T)> _getters = List.empty(growable: true);

  CascadedComparator(this._left, this._right);

  CascadedComparator then(dynamic Function(T) getter) {
    _getters.add(getter);
    return this;
  }

  int calculate() {
    for (int index = 0; index < _getters.length; index++) {
      final currentGetter = _getters[index];
      final result = currentGetter(_left).compareTo(currentGetter(_right));
      if (result != 0) return result;
    }
    return 0;
  }
}
