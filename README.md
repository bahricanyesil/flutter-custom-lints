# Flutter Custom Lints

[![pub package](https://img.shields.io/pub/v/flutter_custom_lints.svg)](https://pub.dev/packages/flutter_custom_lints)

A collection of custom lint rules for Flutter and Dart projects that enforce best practices and prevent common coding mistakes.

## Installation

Add `flutter_custom_lints` to your `dev_dependencies` in `pubspec.yaml`:

```yaml
dev_dependencies:
  custom_lint:
  flutter_custom_lints:
```

Then run:

```bash
dart pub get
```

## Setup

Add the following to your `analysis_options.yaml`:

```yaml
analyzer:
  plugins:
    - custom_lint

custom_lint:
  rules:
    # Enable specific rules
    - no_as_type_assertion
    - no_direct_iterable_access
    - no_null_force
    - use_compare_without_case
```

## Comprehensive Analysis Options

This package provides a comprehensive analysis options configuration with enterprise-grade linting rules that you can use in your Flutter projects:

```yaml
include: package:flutter_custom_lints/analysis_options_comprehensive.yaml
```

This comprehensive configuration includes:

- **180+ linter rules** covering all aspects of Flutter and Dart development
- **Flutter Lints** as the base configuration
- **Dart Code Metrics** with complexity analysis and code quality metrics
- **Strict type safety** and null safety enforcement
- **Performance optimizations** and best practices
- **Advanced code style** enforcement
- **Custom lint rules** from this package automatically enabled

### Usage

In your project's `analysis_options.yaml`, simply include:

```yaml
include: package:flutter_custom_lints/analysis_options_comprehensive.yaml

# You can still override specific rules if needed:
linter:
  rules:
    # Disable a specific rule if it's too strict for your project
    avoid_print: false

    # Add additional rules
    - custom_rule_name

# Add project-specific analyzer configurations
analyzer:
  exclude:
    - lib/generated/**
    - lib/specific_folder/**
```

**Note:** This preset already includes the `custom_lint` plugin configuration and enables all custom lint rules from this package automatically.

## Available Lints

### `no_as_type_assertion`

Prevents using `as` for type assertions which can cause runtime errors.

**❌ Bad:**

```dart
var user = data as User; // Can throw at runtime
```

**✅ Good:**

```dart
if (data is User) {
  var user = data; // Safe type promotion
}
```

### `no_direct_iterable_access`

Prevents direct access to iterables without null checks.

**❌ Bad:**

```dart
var first = list.first; // Can throw if list is empty
```

**✅ Good:**

```dart
var first = list.isNotEmpty ? list.first : null;
// or create your own safe extension:
extension SafeIterable<T> on Iterable<T> {
  T? get safeFirst => isEmpty ? null : first;
  T? safeAt(int index) => index < 0 || index >= length ? null : elementAt(index);
}
```

### `no_null_force`

Prevents force unwrapping of nullable values.

**❌ Bad:**

```dart
String value = nullableString!; // Can throw at runtime
```

**✅ Good:**

```dart
String? value = nullableString;
if (value != null) {
  // Use value safely
}
```

### `use_compare_without_case`

Suggests using case-insensitive string comparison methods.

**❌ Bad:**

```dart
if (str1.toLowerCase() == str2.toLowerCase()) {
  // Less efficient
}
```

**✅ Good:**

```dart
// Create your own extension method:
extension StringComparisonExtension on String {
  bool compareWithoutCase(String other) =>
    toLowerCase() == other.toLowerCase();
}

// Then use it:
if (str1.compareWithoutCase(str2)) {
  // More efficient and readable
}
```

## Running Lints

After setup, you can run the lints using:

```bash
dart run custom_lint
```

For Flutter projects:

```bash
flutter packages pub run custom_lint
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
