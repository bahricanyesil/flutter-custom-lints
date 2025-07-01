/// A collection of custom lint rules for Flutter and Dart projects.
///
/// This library provides lint rules that enforce best practices and prevent
/// common coding mistakes, including:
///
/// - [DisposeControllers]: Ensures controllers are properly disposed
/// - [NoAsTypeAssertion]: Prevents unsafe type casting with `as`
/// - [NoDirectIterableAccess]: Prevents unsafe collection access
/// - [NoNullForce]: Prevents force unwrapping of nullable values
/// - [UseCompareWithoutCase]: Suggests efficient string comparison
library;

import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'src/dispose_controllers.dart';
import 'src/no_as_type_assertion.dart';
import 'src/no_direct_iterable_access.dart';
import 'src/no_null_force.dart';
import 'src/use_compare_without_case.dart';

PluginBase createPlugin() => _FlutterCustomLintsPlugin();

// ignore: prefer-match-file-name
class _FlutterCustomLintsPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => <LintRule>[
    const DisposeControllers(),
    const NoAsTypeAssertion(),
    const NoNullForce(),
    const NoDirectIterableAccess(),
    const UseCompareWithoutCase(),
  ];
}
