// ignore_for_file: unused_local_variable

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
  dynamic data = 'Hello World';

  // ❌ This will trigger no_as_type_assertion lint
  // var str = data as String;

  // ✅ Better approach
  if (data is String) {
    var str = data; // Safe type promotion
    print('Safe cast: $str');
  }
}

void demonstrateDirectIterableAccess() {
  List<String> items = ['apple', 'banana', 'cherry'];
  List<String> emptyList = [];

  // ❌ This will trigger no_direct_iterable_access lint for empty lists
  // var first = emptyList.first; // Would throw at runtime

  // ✅ Better approaches
  var safeFirst = items.isNotEmpty ? items.first : null;
  print('Safe first item: $safeFirst');

  // Alternative safe access
  String? firstOrNull = emptyList.isEmpty ? null : emptyList.first;
  print('First or null: $firstOrNull');
}

void demonstrateNullForce() {
  String? nullableString = 'Hello';
  String? actuallyNull;

  // ❌ This will trigger no_null_force lint
  // var forced = actuallyNull!; // Would throw at runtime

  // ✅ Better approach
  var safe = nullableString; // Null-promoted
  print('Safe value: $safe');
}

void demonstrateStringComparison() {
  String str1 = 'Hello';
  String str2 = 'HELLO';

  // ❌ This will trigger use_compare_without_case lint
  // if (str1.toLowerCase() == str2.toLowerCase()) {
  //   print('Strings match (case insensitive)');
  // }

  // ✅ Better approach would be to use compareWithoutCase extension
  // For now, using standard comparison
  if (str1.toLowerCase() == str2.toLowerCase()) {
    print('Strings match (case insensitive)');
  }
}
