// ignore_for_file: unused_local_variable, unused_element

void main() {
  final List<int> list = <int>[1, 2, 3];

  // These should not trigger the lint as they use safeAt
  final int? first = list.safeAt(0);
  final int? second = list.safeAt(1);
  final int? third = list.safeAt(2);

  // Using in a function
  void processList(List<int> items) {
    final int? item = items.safeAt(0);
  }

  // Using with Iterable
  final Iterable<int> iterable = list.where((int x) => x > 1);
  // Using safeFirst and safeLast instead of direct access
  final int? firstGreaterThanOne = iterable.safeFirst;
  final int? lastGreaterThanOne = iterable.safeLast;
}

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
