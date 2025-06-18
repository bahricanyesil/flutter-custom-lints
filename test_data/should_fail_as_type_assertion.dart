// ignore_for_file: unused_local_variable, avoid-dynamic

void main() {
  const dynamic value = 'test';
  final String? string = getTypedData<String>();
}

T? getTypedData<T>() {
  if (T == String) {
    return getString() as T?;
  }
  return null;
}

String? getString() {
  return 'test';
}
