import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart' show TokenType;
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart'
    show CustomLintContext, CustomLintResolver, DartLintRule, LintCode;

class NoNullForce extends DartLintRule {
  const NoNullForce() : super(code: _code);

  static const LintCode _code = LintCode(
    name: 'no_null_force',
    problemMessage:
        '''Avoid using the null force operator (!). Consider using null-aware operators or proper null checking instead.''',
    errorSeverity: ErrorSeverity.ERROR,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addPostfixExpression((PostfixExpression node) {
      if (node.operator.type == TokenType.BANG) {
        // Check if the expression is part of a null check
        final AstNode? parent = node.parent;

        // Case 1: Check for "x == null || x!.method()" pattern
        if (parent is BinaryExpression) {
          final Expression leftOperand = parent.leftOperand;
          if (leftOperand is BinaryExpression &&
              leftOperand.operator.type == TokenType.EQ_EQ &&
              leftOperand.rightOperand is NullLiteral) {
            return;
          }
        }

        // Case 2: Check if we're inside an if statement that checks for null
        AstNode? currentNode = node;
        while (currentNode != null) {
          if (currentNode is IfStatement) {
            final Expression condition = currentNode.expression;
            if (condition is BinaryExpression &&
                condition.operator.type == TokenType.EQ_EQ &&
                condition.rightOperand is NullLiteral) {
              final String? checkedVar = _getVariableName(
                condition.leftOperand,
              );
              final String? forcedVar = _getVariableName(node.operand);

              if (checkedVar != null &&
                  forcedVar != null &&
                  checkedVar == forcedVar) {
                return;
              }
            }
          }
          currentNode = currentNode.parent;
        }

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

  String? _getVariableName(Expression? expression) {
    if (expression is SimpleIdentifier) {
      return expression.name;
    }
    return null;
  }
}
