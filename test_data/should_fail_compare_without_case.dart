// This file contains examples that should trigger
// the use_compare_without_case lint

// ignore_for_file: prefer-match-file-name

void main() {
  // Direct string comparison with ==
  const String a = 'x21';
  const String b = 'cc45';
  if (a == b) {
    // ignore: avoid_print
    print('equal');
  }

  // Direct string comparison with !=
  if (a != b) {
    // ignore: avoid_print
    print('not equal');
  }

  // String comparison in a function
  // ignore: unused_element
  bool compareStrings(String str1, String str2) {
    return str1 == str2;
  }
}

// String comparison in a class
class StringComparer {
  bool compare(String a, String b) {
    return a == b;
  }
}
