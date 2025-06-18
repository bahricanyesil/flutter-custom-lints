extension StringUtilExtensions on String {
  bool compareWithoutCase(String other) {
    return toLowerCase() == other.toLowerCase();
  }
}
