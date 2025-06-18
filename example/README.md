# Flutter Custom Lints Example

This example demonstrates how to use `flutter_custom_lints` in your project.

## Setup

1. Add the dependencies to your `pubspec.yaml`:

```yaml
dev_dependencies:
  custom_lint: ^0.7.5
  flutter_custom_lints: ^1.0.0
```

2. Create or update your `analysis_options.yaml`:

```yaml
analyzer:
  plugins:
    - custom_lint

custom_lint:
  rules:
    - no_as_type_assertion
    - no_direct_iterable_access
    - no_null_force
    - use_compare_without_case
```

3. Run `dart pub get`

4. Run the lints: `dart run custom_lint`

## Example Code

See the files in this directory for examples of code that will trigger the custom lints and how to fix them.
