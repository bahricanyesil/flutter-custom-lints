import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart'
    show CustomLintContext, CustomLintResolver, DartLintRule, LintCode;

class NoAsTypeAssertion extends DartLintRule {
  const NoAsTypeAssertion() : super(code: _code);

  static const LintCode _code = LintCode(
    name: 'no_as_type_assertion',
    problemMessage:
        '''Avoid using "as" type assertions. Consider using proper type checking or pattern matching instead.''',
    errorSeverity: ErrorSeverity.ERROR,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addAsExpression((AsExpression node) {
      // Get the parent statement
      final AstNode? parent = node.parent;
      if (parent == null) {
        reporter.reportError(
          AnalysisError.forValues(
            source: reporter.source,
            offset: node.offset,
            length: node.length,
            errorCode: _code,
            message: _code.problemMessage,
          ),
        );
        return;
      }

      // Check if this is inside an if statement
      final IfStatement? ifStatement = parent
          .thisOrAncestorOfType<IfStatement>();
      if (ifStatement == null) {
        reporter.reportError(
          AnalysisError.forValues(
            source: reporter.source,
            offset: node.offset,
            length: node.length,
            errorCode: _code,
            message: _code.problemMessage,
          ),
        );
        return;
      }

      // Get the condition of the if statement
      final Expression condition = ifStatement.expression;

      // Skip type parameter comparisons (T == Type)
      if (condition is BinaryExpression &&
          condition.leftOperand is TypeLiteral &&
          condition.rightOperand is TypeLiteral) {
        return;
      }

      if (condition is! IsExpression) {
        reporter.reportError(
          AnalysisError.forValues(
            source: reporter.source,
            offset: node.offset,
            length: node.length,
            errorCode: _code,
            message: _code.problemMessage,
          ),
        );
        return;
      }

      // Check if the is check is for the same type as the as assertion
      final DartType? isType = condition.type.type;
      final DartType? asType = node.type.type;
      if (isType != asType) {
        reporter.reportError(
          AnalysisError.forValues(
            source: reporter.source,
            offset: node.offset,
            length: node.length,
            errorCode: _code,
            message: _code.problemMessage,
          ),
        );
        return;
      }

      // Check if the is check is for the same expression as the as assertion
      final Expression isExpression = condition.expression;
      final Expression asExpression = node.expression;
      if (isExpression.toString() != asExpression.toString()) {
        reporter.reportError(
          AnalysisError.forValues(
            source: reporter.source,
            offset: node.offset,
            length: node.length,
            errorCode: _code,
            message: _code.problemMessage,
          ),
        );
        return;
      }
    });
  }
}
