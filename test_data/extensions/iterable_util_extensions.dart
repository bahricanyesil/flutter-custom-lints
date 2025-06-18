extension IterableUtilExtensions<T> on Iterable<T> {
  T? safeAt(int index) {
    if (index < 0 || index >= length) return null;
    return elementAt(index);
  }

  T? get safeFirst {
    if (isEmpty) return null;
    return first;
  }

  T? get safeLast {
    if (isEmpty) return null;
    return last;
  }
}
