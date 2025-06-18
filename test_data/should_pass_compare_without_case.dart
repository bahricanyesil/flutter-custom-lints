// ignore_for_file: prefer-match-file-name, unused_local_variable

import 'extensions/string_util_extensions.dart';

void main() {
  // Using compareWithoutCase
  const String a = 'x21';
  const String b = 'cc45';
  if (a.compareWithoutCase(b)) {
    // ignore: avoid_print
    print('equal');
  }

  // Using compareWithoutCase in a function
  // ignore: unused_element
  bool compareStrings(String str1, String str2) {
    return str1.compareWithoutCase(str2);
  }

  // Non-string comparisons should pass
  // ignore: unused_element
  void otherComparisons() {
    const int num1 = 1;
    const int num2 = 2;
    if (num1 == num2) {
      // ignore: avoid_print
      print('numbers equal');
    }

    // Null checks should pass
    // ignore: unused_local_variable
    String? nullableStr;
    // ignore: avoid_print
    print('is null');
  }
}

// Using compareWithoutCase in a class
class StringComparer {
  bool compare(String a, String b) {
    return a.compareWithoutCase(b);
  }
}
