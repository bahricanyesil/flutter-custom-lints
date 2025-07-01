import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
// ignore: implementation_imports
import 'package:analyzer/src/dart/ast/ast.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart'
    show CustomLintContext, CustomLintResolver, DartLintRule, LintCode;

class NoDirectIterableAccess extends DartLintRule {
  const NoDirectIterableAccess() : super(code: _code);

  static const LintCode _code = LintCode(
    name: 'no_direct_iterable_access',
    problemMessage:
        '''Direct read access on Iterable is not safe. Create an extension method named safeAt() and use it instead.''',
    errorSeverity: ErrorSeverity.ERROR,
  );

  bool _isIterableType(DartType? type) {
    if (type == null) return false;
    return type.isDartCoreIterable || type.isDartCoreList;
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Check for index access (only flag READ operations, not assignments)
    context.registry.addIndexExpression((IndexExpression node) {
      if (node.target == null) return;

      // Skip if this is an assignment target (left-hand side of assignment)
      final AstNode? parent = node.parent;
      if (parent is AssignmentExpression && parent.leftHandSide == node) {
        return; // This is a write operation, allow it
      }

      final DartType? targetType = node.target?.staticType;
      if (_isIterableType(targetType)) {
        reporter.reportError(
          AnalysisError.forValues(
            source: reporter.source,
            offset: node.offset,
            length: node.length,
            errorCode: _code,
            message: _code.problemMessage,
          ),
        );
      }
    });

    // Check for property access (first, last)
    context.registry.addPropertyAccess((PropertyAccess node) {
      if (node.propertyName.name != 'first' &&
          node.propertyName.name != 'last') {
        return;
      }

      final DartType? targetType = node.target?.staticType;
      if (_isIterableType(targetType)) {
        reporter.reportError(
          AnalysisError.forValues(
            source: reporter.source,
            offset: node.offset,
            length: node.length,
            errorCode: _code,
            message: _code.problemMessage,
          ),
        );
      }
    });

    // Check for prefixed identifier access (iterable.first, iterable.last)
    context.registry.addPrefixedIdentifier((PrefixedIdentifier node) {
      if (node.identifier.name != 'first' && node.identifier.name != 'last') {
        return;
      }

      final DartType? targetType = node.prefix.staticType;
      if (_isIterableType(targetType)) {
        reporter.reportError(
          AnalysisError.forValues(
            source: reporter.source,
            offset: node.offset,
            length: node.length,
            errorCode: _code,
            message: _code.problemMessage,
          ),
        );
      }
    });
  }
}
