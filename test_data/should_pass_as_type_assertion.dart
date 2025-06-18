// ignore_for_file: avoid-dynamic

void main() {
  const dynamic value = 'test';
  if (value is String) {
    // ignore: unused_local_variable
    const String str = value;
  }
}
