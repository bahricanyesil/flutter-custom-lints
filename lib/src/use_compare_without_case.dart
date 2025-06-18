import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart'
    show CustomLintContext, CustomLintResolver, DartLintRule, LintCode;

class UseCompareWithoutCase extends DartLintRule {
  const UseCompareWithoutCase() : super(code: _code);

  static const LintCode _code = LintCode(
    name: 'use_compare_without_case',
    problemMessage:
        '''Create an extension method named compareWithoutCase() and use it instead of == for string comparisons.''',
    errorSeverity: ErrorSeverity.WARNING,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addBinaryExpression((BinaryExpression node) {
      if (node.operator.type.isEqualityOperator) {
        final DartType? leftType = node.leftOperand.staticType;
        final DartType? rightType = node.rightOperand.staticType;

        final bool isLeftString = leftType?.isDartCoreString ?? false;
        final bool isRightString = rightType?.isDartCoreString ?? false;
        if (isLeftString && isRightString) {
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
      }
    });
  }
}
