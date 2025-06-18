// ignore_for_file: unused_local_variable, avoid_print, unnecessary_type_check

void main() {
  // Examples that will trigger lint warnings
  print('Flutter Custom Lints Example');

  // Example 1: no_as_type_assertion
  demonstrateAsTypeAssertion();

  // Example 2: no_direct_iterable_access
  demonstrateDirectIterableAccess();

  // Example 3: no_null_force
  demonstrateNullForce();

  // Example 4: use_compare_without_case
  demonstrateStringComparison();
}

void demonstrateAsTypeAssertion() {
  const Object data = 'Hello World';

  // ❌ This will trigger no_as_type_assertion lint
  // const String str = data as String;

  // ✅ Better approach
  const String safeStr = data is String ? data : ''; // Safe type promotion
  print('Safe cast: $safeStr');
}

void demonstrateDirectIterableAccess() {
  final List<String> items = <String>['apple', 'banana', 'cherry'];
  final List<String> emptyList = <String>[];

  // ❌ This will trigger no_direct_iterable_access lint for empty lists
  // ignore: no_direct_iterable_access
  final String first = emptyList.first; // Would throw at runtime

  // ✅ Better approaches
  final String? safeFirst = items.isNotEmpty ? items.safeFirst : null;
  print('Safe first item: $safeFirst');
}

void demonstrateNullForce() {
  const String nullableString = 'Hello';
  String? actuallyNull;

  // ❌ This will trigger no_null_force lint
  // final String forced = actuallyNull!; // Would throw at runtime

  // ✅ Better approach
  const String safe = nullableString; // Null-promoted
  print('Safe value: $safe');
}

void demonstrateStringComparison() {
  const String str1 = 'Hello';
  const String str2 = 'HELLO';

  // ❌ This will trigger use_compare_without_case lint
  // if (str1 == str2) {
  //   print('Strings match (case insensitive)');
  // }

  // ✅ Better approach would be to use compareWithoutCase extension
  // For now, using standard comparison
  if (str1.compareWithoutCase(str2)) {
    print('Strings match (case insensitive)');
  }
}

extension on String {
  bool compareWithoutCase(String other) {
    // ignore: use_compare_without_case
    return toLowerCase() == other.toLowerCase();
  }
}

// ignore: prefer-match-file-name
extension IterableUtilExtensions<T> on Iterable<T> {
  T? get safeFirst {
    if (isEmpty) return null;
    return first;
  }
}
