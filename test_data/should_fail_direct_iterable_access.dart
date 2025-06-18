// ignore_for_file: unused_local_variable, unused_element

void main() {
  final List<int> list = <int>[1, 2, 3];

  // These should trigger the lint
  final int first = list[0];
  final int second = list[1];
  final int third = list[2];

  // Using in a function
  void processList(List<int> items) {
    final int item = items[0];
  }

  // Using with Iterable
  final Iterable<int> iterable = list.where((int x) => x > 1);
  final int firstGreaterThanOne = iterable.first;
  final int lastGreaterThanOne = iterable.last;
}
